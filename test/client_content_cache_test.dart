import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';
import 'package:sakinah_daily/core/services/content_service.dart';

void main() {
  test('active manifest saves and loads from fake persistent store', () async {
    final repository = ContentCacheRepository(InMemoryContentCacheStore());
    const manifest = ContentManifest(
      id: 'manifest-fixture',
      schemaVersion: 1,
      language: 'en',
      market: 'global',
      sourceCorpusVersions: {'quran': 'fixture-corpus-v1'},
      revokedContentIds: ['revoked_session'],
      bundles: [],
    );

    await repository.saveActiveManifest(manifest);

    final restored = await repository.loadActiveManifest();
    expect(restored, isNotNull);
    expect(restored!.id, 'manifest-fixture');
    expect(restored.sourceCorpusVersions['quran'], 'fixture-corpus-v1');
    expect(restored.revokedContentIds, contains('revoked_session'));
  });

  test('approved bundle saves and loads from fake persistent store', () async {
    final repository = ContentCacheRepository(InMemoryContentCacheStore());
    final bundle = ContentBundle.fromJson(
      _bundleJson(
        bundleId: 'home_bundle_fixture',
        payload: {
          'dailySessions': [_dailySessionJson('cached_session')],
        },
      ),
    );

    await repository
        .saveBundle(CacheEntry.fromBundle(bundle, sha256: 'abc123'));

    final restored = await repository.loadBundle('home_bundle_fixture');
    expect(restored, isNotNull);
    expect(restored!.bundle.id, 'home_bundle_fixture');
    expect(restored.bundle.payload['dailySessions'], isA<List<dynamic>>());
  });

  test('hash mismatch discards bundle', () async {
    final store = InMemoryContentCacheStore();
    final service = _contentService(store);
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
      },
    );

    final accepted = await service.validateAndCacheBundle(
      const BundleRef(
        id: 'home_bundle_fixture',
        url: 'memory://home_bundle_fixture',
        sha256: 'wrong',
        schemaVersion: 1,
      ),
      raw,
    );

    expect(accepted, isFalse);
    expect(service.loadDailySession('cached_session'), isNull);
  });

  test('unsupported schema discards bundle', () async {
    final service = _contentService(InMemoryContentCacheStore());
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      schemaVersion: 2,
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
      },
    );

    final accepted = await service.validateAndCacheBundle(
      BundleRef(
        id: 'home_bundle_fixture',
        url: 'memory://home_bundle_fixture',
        sha256: _sha256(raw),
        schemaVersion: 2,
      ),
      raw,
    );

    expect(accepted, isFalse);
    expect(service.loadDailySession('cached_session'), isNull);
  });

  test('unapproved bundle is rejected', () async {
    final service = _contentService(InMemoryContentCacheStore());
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      reviewStatus: 'draft',
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
      },
    );

    final accepted = await service.validateAndCacheBundle(
      BundleRef(
        id: 'home_bundle_fixture',
        url: 'memory://home_bundle_fixture',
        sha256: _sha256(raw),
        schemaVersion: 1,
      ),
      raw,
    );

    expect(accepted, isFalse);
    expect(service.loadDailySession('cached_session'), isNull);
  });

  test('required bundles sync from fake remote client', () async {
    final store = InMemoryContentCacheStore();
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
      },
    );
    final ref = BundleRef(
      id: 'home_bundle_fixture',
      bundleType: 'home_bundle',
      url: 'memory://home_bundle_fixture',
      sha256: _sha256(raw),
      schemaVersion: 1,
      required: true,
    );
    final service = _contentService(
      store,
      remoteClient: FakeRemoteManifestClient(
        manifest: ContentManifest(
          id: 'manifest-fixture',
          schemaVersion: 1,
          bundles: [ref],
        ),
        bundles: {'home_bundle_fixture': raw},
      ),
    );

    await service.syncRequiredBundles(
      ContentManifest(id: 'manifest-fixture', schemaVersion: 1, bundles: [ref]),
    );

    expect(service.loadDailySession('cached_session'), isNotNull);
  });

  test('seed fallback works when no cache exists', () {
    final service = _contentService(InMemoryContentCacheStore());

    expect(service.loadHomeContent(), isNotEmpty);
    expect(service.loadDailySession('session_morning_ease'), isNotNull);
  });

  test('cached home content loads after fake app restart', () async {
    final store = InMemoryContentCacheStore();
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
      },
    );
    final ref = BundleRef(
      id: 'home_bundle_fixture',
      url: 'memory://home_bundle_fixture',
      sha256: _sha256(raw),
      schemaVersion: 1,
    );

    expect(
        await _contentService(store).validateAndCacheBundle(ref, raw), isTrue);

    final restartedService = _contentService(store);
    await restartedService.restoreCachedContent();
    expect(restartedService.loadHomeContent().first.id, 'cached_session');
  });

  test('stale cache fallback returns cached bundle within allowed stale window',
      () async {
    final store = InMemoryContentCacheStore();
    final repository = ContentCacheRepository(store);
    await repository.saveActiveManifest(
      ContentManifest(
        id: 'manifest-fixture',
        schemaVersion: 1,
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        fallback: const {'allowStale': true, 'maxStaleSeconds': 3600},
        bundles: const [],
      ),
    );
    final service = _contentService(store);
    await service.restoreCachedContent();
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
      },
    );

    expect(
      await service.validateAndCacheBundle(
        BundleRef(
          id: 'home_bundle_fixture',
          url: 'memory://home_bundle_fixture',
          sha256: _sha256(raw),
          schemaVersion: 1,
        ),
        raw,
      ),
      isTrue,
    );

    expect(service.loadDailySession('cached_session'), isNotNull);
  });

  test('revoked daily session and dua are not returned', () async {
    final store = InMemoryContentCacheStore();
    final service = _contentService(store);
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
        'duas': [_duaJson('cached_dua')],
      },
    );

    await service.validateAndCacheBundle(
      BundleRef(
        id: 'home_bundle_fixture',
        url: 'memory://home_bundle_fixture',
        sha256: _sha256(raw),
        schemaVersion: 1,
      ),
      raw,
    );
    await service.handleRevocations(['cached_session', 'cached_dua']);

    expect(service.loadDailySession('cached_session'), isNull);
    expect(service.loadDua('cached_dua'), isNull);
  });

  test('revoked bundle is not activated', () async {
    final store = InMemoryContentCacheStore();
    final service = _contentService(store);
    await service.handleRevocations(['home_bundle_fixture']);
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
      },
    );

    final accepted = await service.validateAndCacheBundle(
      BundleRef(
        id: 'home_bundle_fixture',
        url: 'memory://home_bundle_fixture',
        sha256: _sha256(raw),
        schemaVersion: 1,
      ),
      raw,
    );

    expect(accepted, isFalse);
    expect(service.loadDailySession('cached_session'), isNull);
  });

  test('draft and in-review content inside approved bundle is filtered out',
      () async {
    final store = InMemoryContentCacheStore();
    final service = _contentService(store);
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      payload: {
        'dailySessions': [
          _dailySessionJson('cached_session'),
          _dailySessionJson('draft_session', reviewStatus: 'draft'),
        ],
        'duas': [
          _duaJson('cached_dua'),
          _duaJson('review_dua', reviewStatus: 'inReview'),
        ],
      },
    );

    await service.validateAndCacheBundle(
      BundleRef(
        id: 'home_bundle_fixture',
        url: 'memory://home_bundle_fixture',
        sha256: _sha256(raw),
        schemaVersion: 1,
      ),
      raw,
    );

    expect(service.loadDailySession('cached_session'), isNotNull);
    expect(service.loadDailySession('draft_session'), isNull);
    expect(service.loadDua('cached_dua'), isNotNull);
    expect(service.loadDua('review_dua'), isNull);
  });

  test('language and market incompatible bundle is rejected', () async {
    final service = _contentService(
      InMemoryContentCacheStore(),
      context: const ContentRequestContext(
        languageCode: 'en',
        market: 'id',
        womenIbadahMode: WomenIbadahMode(enabled: false),
      ),
    );
    final raw = _encodedBundle(
      bundleId: 'home_bundle_fixture',
      language: 'id',
      market: 'global',
      payload: {
        'dailySessions': [_dailySessionJson('cached_session')],
      },
    );

    final accepted = await service.validateAndCacheBundle(
      BundleRef(
        id: 'home_bundle_fixture',
        language: 'id',
        market: 'global',
        url: 'memory://home_bundle_fixture',
        sha256: _sha256(raw),
        schemaVersion: 1,
      ),
      raw,
    );

    expect(accepted, isFalse);
    expect(service.loadDailySession('cached_session'), isNull);
  });

  test('source item bundle exposes source item and Quran ayah payloads',
      () async {
    final store = InMemoryContentCacheStore();
    final service = _contentService(store);
    final raw = _encodedBundle(
      bundleId: 'source_item_bundle_fixture',
      bundleType: 'source_item_bundle',
      payload: {
        'sourceItems': [_sourceItemJson('source_item_cached')],
        'quranAyahs': [_quranAyahJson('99:1')],
      },
    );

    await service.validateAndCacheBundle(
      BundleRef(
        id: 'source_item_bundle_fixture',
        bundleType: 'source_item_bundle',
        url: 'memory://source_item_bundle_fixture',
        sha256: _sha256(raw),
        schemaVersion: 1,
      ),
      raw,
    );

    expect(service.loadSourceItem('source_item_cached'), isNotNull);
    expect(service.loadQuranVerse('99:1'), isNotNull);
  });
}

class FakeRemoteManifestClient implements RemoteManifestClient {
  FakeRemoteManifestClient({
    required this.manifest,
    required this.bundles,
    this.bundleHints = const {},
  });

  final ContentManifest manifest;
  final Map<String, String> bundles;
  final Map<String, BundleRef> bundleHints;

  @override
  Future<ContentManifest> loadManifest(ContentRequestContext context) async {
    return manifest;
  }

  @override
  Future<String> downloadBundle(BundleRef ref) async {
    final raw = bundles[ref.id];
    if (raw == null) {
      throw StateError('Missing fake bundle: ${ref.id}');
    }
    return raw;
  }

  @override
  Future<BundleRef?> resolveBundleHint(String bundleHint) async {
    return bundleHints[bundleHint];
  }
}

ContentService _contentService(
  ContentCacheStore store, {
  RemoteManifestClient? remoteClient,
  ContentRequestContext context = const ContentRequestContext(
    languageCode: 'en',
    womenIbadahMode: WomenIbadahMode(enabled: false),
  ),
}) {
  return ContentService(
    seedRepository: SeedContentRepository(SeedContent.demo()),
    cacheRepository: ContentCacheRepository(store),
    remoteClient: remoteClient,
    defaultContext: context,
  );
}

String _encodedBundle({
  required String bundleId,
  required Map<String, dynamic> payload,
  String bundleType = 'home_bundle',
  int schemaVersion = 1,
  String language = 'en',
  String market = 'global',
  String status = 'published',
  String reviewStatus = 'approved',
}) {
  return jsonEncode(_bundleJson(
    bundleId: bundleId,
    bundleType: bundleType,
    schemaVersion: schemaVersion,
    language: language,
    market: market,
    status: status,
    reviewStatus: reviewStatus,
    payload: payload,
  ));
}

Map<String, dynamic> _bundleJson({
  required String bundleId,
  required Map<String, dynamic> payload,
  String bundleType = 'home_bundle',
  int schemaVersion = 1,
  String language = 'en',
  String market = 'global',
  String status = 'published',
  String reviewStatus = 'approved',
}) {
  return {
    'bundleId': bundleId,
    'bundleType': bundleType,
    'schemaVersion': schemaVersion,
    'language': language,
    'market': market,
    'status': status,
    'reviewStatus': reviewStatus,
    'sourceCorpusVersions': {'quran': 'fixture-corpus-v1'},
    'payload': payload,
  };
}

Map<String, dynamic> _dailySessionJson(
  String id, {
  String reviewStatus = 'approved',
}) {
  return {
    'id': id,
    'title': {'en': 'Fixture session'},
    'subtitle': {'en': 'Fixture subtitle'},
    'steps': [
      {
        'id': 'step_fixture',
        'type': 'reflection',
        'title': {'en': 'Fixture step'},
      }
    ],
    'status': 'published',
    'reviewStatus': reviewStatus,
  };
}

Map<String, dynamic> _duaJson(String id, {String reviewStatus = 'approved'}) {
  return {
    'id': id,
    'category': 'fixture',
    'arabicText': 'Fixture source text',
    'transliteration': 'Fixture transliteration',
    'translations': {'en': 'Fixture meaning'},
    'source': 'Fixture source',
    'status': 'published',
    'reviewStatus': reviewStatus,
  };
}

Map<String, dynamic> _sourceItemJson(String id) {
  return {
    'id': id,
    'clusterId': 'fixture_cluster',
    'ritualMoment': 'morning',
    'status': 'published',
    'reviewStatus': 'approved',
    'translations': {'en': 'Fixture source item'},
  };
}

Map<String, dynamic> _quranAyahJson(String verseKey) {
  return {
    'verseKey': verseKey,
    'surah': 99,
    'ayah': 1,
    'arabicText': 'Fixture source text',
    'translations': {'en': 'Fixture meaning'},
    'source': 'Fixture source',
    'status': 'published',
    'reviewStatus': 'approved',
  };
}

String _sha256(String raw) => sha256.convert(utf8.encode(raw)).toString();
