import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/content_api_config.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';
import 'package:sakinah_daily/core/services/content_service.dart';
import 'package:sakinah_daily/core/services/remote_content_api_client.dart';

import 'support/fake_content_http_client.dart';

void main() {
  test('disabled config produces no remote client and seed fallback works', () {
    final container = ProviderContainer(
      overrides: [
        contentApiConfigProvider.overrideWithValue(
          const ContentApiConfig.disabled(),
        ),
        contentCacheStoreProvider.overrideWithValue(
          InMemoryContentCacheStore(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(remoteManifestClientProvider), isNull);
    expect(
        container.read(contentServiceProvider).loadHomeContent(), isNotEmpty);
  });

  test('enabled config builds manifest URI with content query params',
      () async {
    final http = FakeContentHttpClient({
      _manifestUri().toString(): ContentHttpResponse.ok(_manifestJson()),
    });
    final client = _client(http);

    final manifest = await client.loadManifest(_context());

    expect(manifest.id, 'manifest_en_global_001');
    expect(http.requests.single.uri, _manifestUri());
  });

  test('manifest request omits women mode status and gender fields', () async {
    final http = FakeContentHttpClient({
      _manifestUri().toString(): ContentHttpResponse.ok(_manifestJson()),
    });
    final client = _client(http);

    await client.loadManifest(const ContentRequestContext(
      languageCode: 'en',
      market: 'global',
      appVersion: '0.1.0',
      womenIbadahMode: WomenIbadahMode(
        enabled: true,
        status: WomenIbadahStatus.menstruating,
      ),
    ));

    final uri = http.requests.single.uri;
    expect(
      uri.queryParameters.keys,
      unorderedEquals(['app_version', 'language', 'market', 'schema_version']),
    );
    expect(uri.toString(), isNot(contains('women')));
    expect(uri.toString(), isNot(contains('gender')));
    expect(uri.toString(), isNot(contains('menstruating')));
    expect(uri.toString(), isNot(contains('postpartum')));
    expect(uri.toString(), isNot(contains('pregnancy')));
  });

  test('token is sent as authorization header when configured', () async {
    final http = FakeContentHttpClient({
      _manifestUri().toString(): ContentHttpResponse.ok(_manifestJson()),
    });
    final client = _client(http, token: 'test-token');

    await client.loadManifest(_context());

    expect(http.requests.single.headers['Authorization'], 'Bearer test-token');
  });

  test('manifest JSON parses into ContentManifest', () async {
    final http = FakeContentHttpClient({
      _manifestUri().toString(): ContentHttpResponse.ok(_manifestJson()),
    });
    final manifest = await _client(http).loadManifest(_context());

    expect(manifest.schemaVersion, 1);
    expect(manifest.language, 'en');
    expect(manifest.market, 'global');
    expect(manifest.sourceCorpusVersions['quran'], 'fixture-corpus-v1');
    expect(manifest.bundles.single.id, 'home_bundle_en_global_001');
  });

  test('bundle JSON downloads through fake HTTP only', () async {
    final raw = _bundleJson('home_bundle_en_global_001');
    final http = FakeContentHttpClient({
      'https://cdn.example.test/bundles/home_bundle_en_global_001.json':
          ContentHttpResponse.ok(raw),
    });

    final downloaded = await _client(http).downloadBundle(BundleRef(
      id: 'home_bundle_en_global_001',
      url: 'https://cdn.example.test/bundles/home_bundle_en_global_001.json',
      sha256: _sha256(raw),
      schemaVersion: 1,
    ));

    expect(downloaded, raw);
    expect(http.requests.single.uri.host, 'cdn.example.test');
  });

  test('required bundles sync and become available after validation', () async {
    final raw = _bundleJson('home_bundle_en_global_001');
    final manifest = _manifestJson(bundleSha256: _sha256(raw));
    final http = FakeContentHttpClient({
      _manifestUri().toString(): ContentHttpResponse.ok(manifest),
      'https://cdn.example.test/bundles/home_bundle_en_global_001.json':
          ContentHttpResponse.ok(raw),
    });
    final cacheStore = InMemoryContentCacheStore();
    final container = ProviderContainer(
      overrides: [
        contentApiConfigProvider.overrideWithValue(_config()),
        contentHttpClientProvider.overrideWithValue(http),
        contentCacheStoreProvider.overrideWithValue(cacheStore),
      ],
    );
    addTearDown(container.dispose);

    final service = container.read(contentServiceProvider);
    await service.refreshRemoteContent(_context());

    expect(service.loadDailySession('remote_session'), isNotNull);
    expect(
        await ContentCacheRepository(cacheStore)
            .loadBundle('home_bundle_en_global_001'),
        isNotNull);
  });

  test('remote fetch failure keeps seed fallback', () async {
    final service = _service(
      FakeContentHttpClient({
        _manifestUri().toString(): const ContentHttpResponse(
          statusCode: 503,
          body: '{"error":"offline"}',
        ),
      }),
    );

    await service.refreshRemoteContent(_context());

    expect(service.loadDailySession('session_morning_ease'), isNotNull);
  });

  test('invalid hash rejects remote bundle', () async {
    final raw = _bundleJson('home_bundle_en_global_001');
    final service = _service(
      FakeContentHttpClient({
        _manifestUri().toString(): ContentHttpResponse.ok(
          _manifestJson(bundleSha256: 'wrong'),
        ),
        'https://cdn.example.test/bundles/home_bundle_en_global_001.json':
            ContentHttpResponse.ok(raw),
      }),
    );

    await service.refreshRemoteContent(_context());

    expect(service.loadDailySession('remote_session'), isNull);
    expect(service.loadDailySession('session_morning_ease'), isNotNull);
  });

  test('unapproved remote bundle is rejected', () async {
    final raw = _bundleJson(
      'home_bundle_en_global_001',
      reviewStatus: 'draft',
    );
    final service = _service(
      FakeContentHttpClient({
        _manifestUri().toString(): ContentHttpResponse.ok(
          _manifestJson(bundleSha256: _sha256(raw)),
        ),
        'https://cdn.example.test/bundles/home_bundle_en_global_001.json':
            ContentHttpResponse.ok(raw),
      }),
    );

    await service.refreshRemoteContent(_context());

    expect(service.loadDailySession('remote_session'), isNull);
  });

  test('incompatible language and market bundle is rejected', () async {
    final raw = _bundleJson(
      'home_bundle_en_global_001',
      language: 'id',
      market: 'global',
    );
    final service = _service(
      FakeContentHttpClient({
        _manifestUri().toString(): ContentHttpResponse.ok(
          _manifestJson(bundleSha256: _sha256(raw), bundleLanguage: 'id'),
        ),
        'https://cdn.example.test/bundles/home_bundle_en_global_001.json':
            ContentHttpResponse.ok(raw),
      }),
    );

    await service.refreshRemoteContent(_context());

    expect(service.loadDailySession('remote_session'), isNull);
  });

  test('revoked content from remote manifest is hidden', () async {
    final raw = _bundleJson('home_bundle_en_global_001');
    final service = _service(
      FakeContentHttpClient({
        _manifestUri().toString(): ContentHttpResponse.ok(
          _manifestJson(
            bundleSha256: _sha256(raw),
            revokedContentIds: ['remote_session'],
          ),
        ),
        'https://cdn.example.test/bundles/home_bundle_en_global_001.json':
            ContentHttpResponse.ok(raw),
      }),
    );

    await service.refreshRemoteContent(_context());

    expect(service.loadDailySession('remote_session'), isNull);
  });

  test('detail endpoint resolves bundle hint into BundleRef', () async {
    final raw = _bundleJson('detail_remote_session');
    final http = FakeContentHttpClient({
      _detailUri('detail_remote_session').toString():
          ContentHttpResponse.ok(jsonEncode({
        'bundleRef': {
          'bundleId': 'detail_remote_session',
          'bundleType': 'daily_session_bundle',
          'url': 'https://cdn.example.test/bundles/detail_remote_session.json',
          'sha256': _sha256(raw),
          'schemaVersion': 1,
          'required': false,
          'language': 'en',
          'market': 'global',
        },
      })),
    });

    final ref = await _client(http).resolveBundleHint('detail_remote_session');

    expect(ref, isNotNull);
    expect(ref!.id, 'detail_remote_session');
    expect(http.requests.single.uri, _detailUri('detail_remote_session'));
  });
}

HttpRemoteManifestClient _client(
  ContentHttpClient http, {
  String? token,
}) {
  return HttpRemoteManifestClient(
    config: _config(token: token),
    httpClient: http,
  );
}

ContentService _service(ContentHttpClient http) {
  return ContentService(
    seedRepository: SeedContentRepository(SeedContent.demo()),
    cacheRepository: ContentCacheRepository(InMemoryContentCacheStore()),
    remoteClient: _client(http),
  );
}

ContentApiConfig _config({String? token}) {
  return ContentApiConfig(
    enabled: true,
    provider: 'generic',
    baseUri: Uri.parse('https://content.example.test'),
    token: token,
    manifestPath: '/manifest',
    bundlePath: '/bundles',
    detailBundlePath: '/detail-bundle',
  );
}

ContentRequestContext _context() {
  return const ContentRequestContext(
    languageCode: 'en',
    market: 'global',
    appVersion: '0.1.0',
    womenIbadahMode: WomenIbadahMode(enabled: false),
  );
}

Uri _manifestUri() {
  return Uri.parse('https://content.example.test/manifest').replace(
    queryParameters: const {
      'app_version': '0.1.0',
      'language': 'en',
      'market': 'global',
      'schema_version': '1',
    },
  );
}

Uri _detailUri(String hint) {
  return Uri.parse('https://content.example.test/detail-bundle').replace(
    queryParameters: {
      'bundle_hint': hint,
      'language': 'en',
      'market': 'global',
      'schema_version': '1',
    },
  );
}

String _manifestJson({
  String bundleSha256 = 'placeholder',
  String bundleLanguage = 'en',
  List<String> revokedContentIds = const [],
}) {
  return jsonEncode({
    'manifestId': 'manifest_en_global_001',
    'schemaVersion': 1,
    'language': 'en',
    'market': 'global',
    'generatedAt': '2026-05-21T00:00:00Z',
    'expiresAt': '2026-05-22T00:00:00Z',
    'sourceCorpusVersions': {'quran': 'fixture-corpus-v1'},
    'revokedContentIds': revokedContentIds,
    'fallback': {'allowStale': true, 'maxStaleSeconds': 604800},
    'bundles': [
      {
        'bundleId': 'home_bundle_en_global_001',
        'bundleType': 'home_bundle',
        'url':
            'https://cdn.example.test/bundles/home_bundle_en_global_001.json',
        'sha256': bundleSha256,
        'schemaVersion': 1,
        'required': true,
        'language': bundleLanguage,
        'market': 'global',
      },
    ],
  });
}

String _bundleJson(
  String bundleId, {
  String language = 'en',
  String market = 'global',
  String status = 'published',
  String reviewStatus = 'approved',
}) {
  return jsonEncode({
    'bundleId': bundleId,
    'bundleType': 'home_bundle',
    'schemaVersion': 1,
    'language': language,
    'market': market,
    'status': status,
    'reviewStatus': reviewStatus,
    'sourceCorpusVersions': {'quran': 'fixture-corpus-v1'},
    'payload': {
      'dailySessions': [
        {
          'id': 'remote_session',
          'title': {'en': 'Remote fixture session'},
          'subtitle': {'en': 'Remote fixture subtitle'},
          'steps': [
            {
              'id': 'step_remote',
              'type': 'reflection',
              'title': {'en': 'Remote fixture step'},
            }
          ],
          'status': 'published',
          'reviewStatus': 'approved',
        }
      ],
      'duas': [],
      'dhikrs': [],
      'sourceItems': [],
      'quranAyahs': [],
    },
  });
}

String _sha256(String raw) => sha256.convert(utf8.encode(raw)).toString();
