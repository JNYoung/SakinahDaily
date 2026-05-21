import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/sakinah_models.dart';
import '../repositories/content_cache_repository.dart';
import '../repositories/content_repository.dart';

abstract class RemoteManifestClient {
  Future<ContentManifest> loadManifest(ContentRequestContext context);
  Future<String> downloadBundle(BundleRef ref);

  Future<BundleRef?> resolveBundleHint(String bundleHint) async => null;
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

class ContentService implements ContentRepository {
  ContentService({
    required this.seedRepository,
    required this.cacheRepository,
    this.remoteClient,
    this.supportedSchemaVersion = 1,
    this.defaultContext = const ContentRequestContext(
      languageCode: 'en',
      womenIbadahMode: WomenIbadahMode(enabled: false),
    ),
  });

  final ContentRepository seedRepository;
  final ContentCacheRepository cacheRepository;
  final RemoteManifestClient? remoteClient;
  final int supportedSchemaVersion;
  final ContentRequestContext defaultContext;

  ContentManifest? _activeManifest;
  List<CacheEntry> _entries = const [];
  Set<String> _revoked = const {};

  Future<void> restoreCachedContent() async {
    _activeManifest = await cacheRepository.loadActiveManifest();
    _revoked = await cacheRepository.revokedContentIds();
    _entries = await cacheRepository.listBundles();
  }

  Future<ContentManifest> loadActiveManifest() async {
    final manifest = await cacheRepository.loadActiveManifest();
    if (manifest != null) {
      _activeManifest = manifest;
      _revoked = await cacheRepository.revokedContentIds();
      return manifest;
    }
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
    final manifest = await remoteClient!.loadManifest(context);
    await cacheRepository.saveActiveManifest(manifest);
    _activeManifest = manifest;
    await handleRevocations(manifest.revokedContentIds);
    return manifest;
  }

  Future<void> syncRequiredBundles(ContentManifest manifest) async {
    if (remoteClient == null) {
      return;
    }
    await cacheRepository.saveActiveManifest(manifest);
    _activeManifest = manifest;
    await handleRevocations(manifest.revokedContentIds);
    for (final ref in manifest.bundles.where((ref) => ref.required)) {
      try {
        final raw = await remoteClient!.downloadBundle(ref);
        await validateAndCacheBundle(ref, raw);
      } on Object {
        continue;
      }
    }
  }

  @override
  List<DailySession> getDailySessions() => loadHomeContent();

  List<DailySession> loadHomeContent() {
    final cached = _cachedDailySessions();
    if (cached.isNotEmpty) {
      return cached;
    }
    return seedRepository
        .getDailySessions()
        .where((session) => !_isRevoked(session.id))
        .toList();
  }

  @override
  DailySession? getDailySession(String id) => loadDailySession(id);

  DailySession? loadDailySession(String sessionId) {
    if (_isRevoked(sessionId)) {
      return null;
    }
    return _cachedDailySessions()
            .where((session) => session.id == sessionId)
            .firstOrNull ??
        seedRepository.getDailySession(sessionId);
  }

  DailySession? loadSessionContainingContent(String contentId) {
    if (_isRevoked(contentId)) {
      return null;
    }
    return loadHomeContent().where((session) {
      if (_isRevoked(session.id)) {
        return false;
      }
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

  @override
  List<DuaItem> getDuas() {
    final cached = _cachedDuas();
    if (cached.isNotEmpty) {
      return cached;
    }
    return seedRepository
        .getDuas()
        .where((dua) => !_isRevoked(dua.id))
        .toList();
  }

  @override
  DuaItem? getDua(String id) => loadDua(id);

  DuaItem? loadDua(String duaId) {
    if (_isRevoked(duaId)) {
      return null;
    }
    return _cachedDuas().where((dua) => dua.id == duaId).firstOrNull ??
        seedRepository.getDua(duaId);
  }

  @override
  List<DhikrItem> getDhikrs() {
    final cached = _cachedDhikrs();
    if (cached.isNotEmpty) {
      return cached;
    }
    return seedRepository
        .getDhikrs()
        .where((dhikr) => !_isRevoked(dhikr.id))
        .toList();
  }

  @override
  DhikrItem? getDhikr(String id) => loadDhikr(id);

  DhikrItem? loadDhikr(String dhikrId) {
    if (_isRevoked(dhikrId)) {
      return null;
    }
    return _cachedDhikrs().where((dhikr) => dhikr.id == dhikrId).firstOrNull ??
        seedRepository.getDhikr(dhikrId);
  }

  @override
  QuranAyah? getQuranAyah(String verseKey) => loadQuranVerse(verseKey);

  QuranAyah? loadQuranVerse(String verseKey) {
    if (_isRevoked(verseKey)) {
      return null;
    }
    return _cachedQuranAyahs()
            .where((ayah) => ayah.verseKey == verseKey)
            .firstOrNull ??
        seedRepository.getQuranAyah(verseKey);
  }

  @override
  ReflectionItem? getReflection(String id) {
    if (_isRevoked(id)) {
      return null;
    }
    return seedRepository.getReflection(id);
  }

  @override
  List<SourceItem> getSourceItems() {
    final cached = _cachedSourceItems();
    if (cached.isNotEmpty) {
      return cached;
    }
    return seedRepository
        .getSourceItems()
        .where((item) => !_isRevoked(item.id))
        .toList();
  }

  SourceItem? loadSourceItem(String sourceItemId) {
    if (_isRevoked(sourceItemId)) {
      return null;
    }
    return _cachedSourceItems()
            .where((item) => item.id == sourceItemId)
            .firstOrNull ??
        seedRepository
            .getSourceItems()
            .where((item) => item.id == sourceItemId)
            .firstOrNull;
  }

  @override
  List<PushTemplate> getPushTemplates() {
    return seedRepository
        .getPushTemplates()
        .where((template) => !_isRevoked(template.id))
        .toList();
  }

  @override
  AudioAsset? getAudioAsset(String id) {
    if (_isRevoked(id)) {
      return null;
    }
    return seedRepository.getAudioAsset(id);
  }

  Future<void> handleRevocations(Iterable<String> contentIds) async {
    final cleanIds = contentIds.where((id) => id.isNotEmpty).toList();
    if (cleanIds.isEmpty) {
      return;
    }
    await cacheRepository.markRevoked(cleanIds);
    _revoked = await cacheRepository.revokedContentIds();
    for (final id in cleanIds) {
      await cacheRepository.deleteBundle(id);
    }
    _entries = _entries
        .where((entry) => !_revoked.contains(entry.bundleId))
        .toList();
  }

  Future<bool> validateAndCacheBundle(BundleRef ref, String rawJson) async {
    if (_isRevoked(ref.id)) {
      return false;
    }
    final actualHash = sha256.convert(utf8.encode(rawJson)).toString();
    if (actualHash != ref.sha256) {
      return false;
    }
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      return false;
    }
    final bundle = ContentBundle.fromJson(decoded);
    if (bundle.schemaVersion != supportedSchemaVersion ||
        ref.schemaVersion != supportedSchemaVersion) {
      return false;
    }
    if (!bundle.isApproved) {
      return false;
    }
    if (!_compatible(ref.language, bundle.language, defaultContext.languageCode)) {
      return false;
    }
    if (!_compatibleMarket(ref.market, bundle.market, defaultContext.market)) {
      return false;
    }
    if (_isRevoked(bundle.id)) {
      return false;
    }
    final entry = CacheEntry.fromBundle(
      bundle,
      sha256: actualHash,
      sizeBytes: ref.sizeBytes,
    );
    await cacheRepository.saveBundle(entry);
    _entries = [
      ..._entries.where((cached) => cached.bundleId != bundle.id),
      entry,
    ];
    return true;
  }

  Future<PushDeepLinkResult> recoverPushDeepLink(
    String sessionId, {
    String? bundleHint,
  }) async {
    final localSession = loadDailySession(sessionId);
    if (localSession != null) {
      return PushDeepLinkResult(
        available: true,
        message: 'Loaded from local content cache',
        session: localSession,
      );
    }

    if (bundleHint != null && remoteClient != null) {
      try {
        final ref = await remoteClient!.resolveBundleHint(bundleHint);
        if (ref != null) {
          final raw = await remoteClient!.downloadBundle(ref);
          final accepted = await validateAndCacheBundle(ref, raw);
          final recovered = loadDailySession(sessionId);
          if (accepted && recovered != null) {
            return PushDeepLinkResult(
              available: true,
              message: 'Loaded from detail bundle',
              session: recovered,
            );
          }
        }
      } on Object {
        // Missing or invalid detail bundles fall through to safe fallback.
      }
    }

    return const PushDeepLinkResult(
      available: false,
      message: 'This session is not available offline yet.',
    );
  }

  List<SourceItem> lockScreenSafeSourceItems(ContentRequestContext context) {
    return getSourceItems().where((item) {
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

  List<DailySession> _cachedDailySessions() {
    return _parseCachedList(
      'dailySessions',
      DailySession.fromJson,
      (session) => session.id,
      (session) => session.isApproved,
    );
  }

  List<DuaItem> _cachedDuas() {
    return _parseCachedList(
      'duas',
      DuaItem.fromJson,
      (dua) => dua.id,
      (dua) => dua.isApproved,
    );
  }

  List<DhikrItem> _cachedDhikrs() {
    return _parseCachedList(
      'dhikrs',
      DhikrItem.fromJson,
      (dhikr) => dhikr.id,
      (dhikr) => dhikr.isApproved,
    );
  }

  List<SourceItem> _cachedSourceItems() {
    return _parseCachedList(
      'sourceItems',
      SourceItem.fromJson,
      (item) => item.id,
      (item) => item.isApproved,
    );
  }

  List<QuranAyah> _cachedQuranAyahs() {
    return _parseCachedList(
      'quranAyahs',
      QuranAyah.fromJson,
      (ayah) => ayah.verseKey,
      (ayah) => ayah.isApproved,
    );
  }

  List<T> _parseCachedList<T>(
    String payloadKey,
    T Function(Map<String, dynamic>) parse,
    String Function(T) idOf,
    bool Function(T) approved,
  ) {
    if (!_cacheUsable()) {
      return <T>[];
    }
    final items = <T>[];
    final seen = <String>{};
    for (final entry in _entries.where(_entryUsable)) {
      final rawItems = entry.bundle.payload[payloadKey];
      if (rawItems is! List<dynamic>) {
        continue;
      }
      for (final rawItem in rawItems) {
        if (rawItem is! Map<String, dynamic>) {
          continue;
        }
        try {
          final item = parse(rawItem);
          final id = idOf(item);
          if (!_isRevoked(id) && approved(item) && seen.add(id)) {
            items.add(item);
          }
        } on Object {
          continue;
        }
      }
    }
    return items;
  }

  bool _entryUsable(CacheEntry entry) {
    return entry.bundle.isApproved &&
        entry.bundle.schemaVersion == supportedSchemaVersion &&
        !_isRevoked(entry.bundleId);
  }

  bool _cacheUsable() {
    final manifest = _activeManifest;
    if (manifest == null) {
      return true;
    }
    return manifest.schemaVersion == supportedSchemaVersion &&
        manifest.staleAllowed(DateTime.now());
  }

  bool _isRevoked(String id) => _revoked.contains(id);

  bool _compatible(String refLanguage, String bundleLanguage, String language) {
    return _languageMatches(refLanguage, language) &&
        _languageMatches(bundleLanguage, language);
  }

  bool _languageMatches(String candidate, String language) {
    return candidate == language || candidate == 'all';
  }

  bool _compatibleMarket(String refMarket, String bundleMarket, String market) {
    return _marketMatches(refMarket, market) &&
        _marketMatches(bundleMarket, market);
  }

  bool _marketMatches(String candidate, String market) {
    return candidate == market || candidate == 'global' || candidate == 'all';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
