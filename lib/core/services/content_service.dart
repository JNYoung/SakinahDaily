import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/sakinah_models.dart';
import '../repositories/content_repository.dart';

abstract class RemoteManifestClient {
  Future<ContentManifest> loadManifest(ContentRequestContext context);
  Future<String> downloadBundle(BundleRef ref);
}

class InMemoryContentCache {
  final Map<String, CacheEntry> _entries = {};
  final Set<String> _revoked = {};

  CacheEntry? get(String bundleId) => _entries[bundleId];

  void put(CacheEntry entry) {
    if (!_revoked.contains(entry.bundleId)) {
      _entries[entry.bundleId] = entry;
    }
  }

  void revoke(Iterable<String> contentIds) {
    _revoked.addAll(contentIds);
    for (final id in contentIds) {
      _entries.remove(id);
    }
  }
}

class PushDeepLinkResult {
  const PushDeepLinkResult({
    required this.available,
    required this.message,
    this.session,
  });

  final bool available;
  final String message;
  final DailySession? session;
}

class ContentService {
  ContentService({
    required this.seedRepository,
    required this.cache,
    this.remoteClient,
    this.supportedSchemaVersion = 1,
  });

  final ContentRepository seedRepository;
  final InMemoryContentCache cache;
  final RemoteManifestClient? remoteClient;
  final int supportedSchemaVersion;

  Future<ContentManifest> loadActiveManifest() async {
    return ContentManifest(
      id: 'seed-manifest',
      schemaVersion: supportedSchemaVersion,
      bundles: const [],
    );
  }

  Future<ContentManifest> refreshManifest(ContentRequestContext context) async {
    if (remoteClient == null) {
      return loadActiveManifest();
    }
    return remoteClient!.loadManifest(context);
  }

  Future<void> syncRequiredBundles(ContentManifest manifest) async {
    if (remoteClient == null) {
      return;
    }
    for (final ref in manifest.bundles) {
      final raw = await remoteClient!.downloadBundle(ref);
      validateAndCacheBundle(ref, raw);
    }
  }

  List<DailySession> loadHomeContent() => seedRepository.getDailySessions();

  DailySession? loadDailySession(String sessionId) {
    return seedRepository.getDailySession(sessionId);
  }

  DailySession? loadSessionContainingContent(String contentId) {
    return seedRepository.getDailySessions().where((session) {
      return session.steps.any((step) => step.contentId == contentId);
    }).firstOrNull;
  }

  DailySession ensureDailySession(String sessionId) {
    final session = loadDailySession(sessionId);
    if (session == null) {
      throw StateError('Daily session not available: $sessionId');
    }
    return session;
  }

  SourceItem? loadSourceItem(String sourceItemId) {
    return seedRepository
        .getSourceItems()
        .where((item) => item.id == sourceItemId)
        .firstOrNull;
  }

  DuaItem? loadDua(String duaId) {
    return seedRepository.getDua(duaId);
  }

  DhikrItem? loadDhikr(String dhikrId) {
    return seedRepository.getDhikr(dhikrId);
  }

  QuranAyah? loadQuranVerse(String verseKey) {
    return seedRepository.getQuranAyah(verseKey);
  }

  void handleRevocations(Iterable<String> contentIds) {
    cache.revoke(contentIds);
  }

  bool validateAndCacheBundle(BundleRef ref, String rawJson) {
    final actualHash = sha256.convert(utf8.encode(rawJson)).toString();
    if (actualHash != ref.sha256) {
      return false;
    }
    final bundle = ContentBundle.fromJson(
      jsonDecode(rawJson) as Map<String, dynamic>,
    );
    if (bundle.schemaVersion != supportedSchemaVersion ||
        ref.schemaVersion != supportedSchemaVersion) {
      return false;
    }
    if (!bundle.isApproved) {
      return false;
    }
    cache.put(
      CacheEntry(
        bundleId: bundle.id,
        sha256: actualHash,
        cachedAt: DateTime.now(),
        bundle: bundle,
      ),
    );
    return true;
  }

  PushDeepLinkResult recoverPushDeepLink(String sessionId) {
    final session = loadDailySession(sessionId);
    if (session != null) {
      return PushDeepLinkResult(
        available: true,
        message: 'Loaded from seed cache',
        session: session,
      );
    }
    return const PushDeepLinkResult(
      available: false,
      message: 'This session is not available offline yet.',
    );
  }

  List<SourceItem> lockScreenSafeSourceItems(ContentRequestContext context) {
    return seedRepository.getSourceItems().where((item) {
      if (!context.lockScreenSafe) {
        return true;
      }
      return !(context.womenIbadahMode.enabled &&
          context.womenIbadahMode.hideCycleSensitiveLockScreenCopy &&
          item.cycleSensitiveHidden);
    }).toList();
  }

  bool audioHashValidOrTextFallback(AudioAsset asset, String? downloadedHash) {
    if (asset.sha256 == null || asset.sha256!.isEmpty) {
      return false;
    }
    return asset.sha256 == downloadedHash;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
