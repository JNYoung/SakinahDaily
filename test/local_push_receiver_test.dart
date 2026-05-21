import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/local_push_payload.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';
import 'package:sakinah_daily/core/services/content_service.dart';
import 'package:sakinah_daily/core/services/local_push_receiver.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/core/services/prayer_calculation_service.dart';

void main() {
  late LocalPushReceiver receiver;

  setUp(() {
    receiver = LocalPushReceiver(
      contentService: ContentService(
        seedRepository: SeedContentRepository(SeedContent.demo()),
        cacheRepository: ContentCacheRepository(InMemoryContentCacheStore()),
      ),
    );
  });

  test('daily_session push with existing seed session resolves to route',
      () async {
    final result = await receiver.receiveJson(_payloadJson(
      type: 'daily_session',
      contentId: 'session_morning_ease',
    ));

    expect(result.accepted, isTrue);
    expect(result.routeAvailable, isTrue);
    expect(result.route, '/session/session_morning_ease');
    expect(result.flags, isEmpty);
  });

  test('dua push with existing seed dua resolves to route', () async {
    final result = await receiver.receiveJson(_payloadJson(
      type: 'dua',
      contentId: 'dua_ease',
    ));

    expect(result.accepted, isTrue);
    expect(result.routeAvailable, isTrue);
    expect(result.route, '/dua/dua_ease');
  });

  test('missing content returns fallback and does not invent source text',
      () async {
    final result = await receiver.receiveJson(_payloadJson(
      type: 'dua',
      contentId: 'missing_dua',
    ));

    expect(result.accepted, isFalse);
    expect(result.routeAvailable, isFalse);
    expect(result.route, isNull);
    expect(result.message, 'This push content is not available offline yet.');
    expect(result.message, isNot(contains('Quran')));
    expect(result.message, isNot(contains('Hadith')));
    expect(result.flags, contains('missing_content'));
  });

  test('missing daily session fetches hinted detail bundle and resolves route',
      () async {
    final raw = _detailBundleJson('remote_session');
    final ref = BundleRef(
      id: 'detail_remote_session',
      bundleType: 'daily_session_bundle',
      url: 'memory://detail_remote_session',
      sha256: _sha256(raw),
      schemaVersion: 1,
      required: false,
    );
    final remote = _FakeRemoteManifestClient(
      bundleHints: {'detail_remote_session': ref},
      bundles: {'detail_remote_session': raw},
    );
    final receiver = LocalPushReceiver(
      contentService: ContentService(
        seedRepository: SeedContentRepository(SeedContent.demo()),
        cacheRepository: ContentCacheRepository(InMemoryContentCacheStore()),
        remoteClient: remote,
      ),
    );

    final result = await receiver.receiveJson(_payloadJson(
      type: 'daily_session',
      contentId: 'remote_session',
      bundleHint: 'detail_remote_session',
    ));

    expect(result.accepted, isTrue);
    expect(result.routeAvailable, isTrue);
    expect(result.route, '/session/remote_session');
  });

  test('missing hinted detail bundle returns fallback without inventing content',
      () async {
    final receiver = LocalPushReceiver(
      contentService: ContentService(
        seedRepository: SeedContentRepository(SeedContent.demo()),
        cacheRepository: ContentCacheRepository(InMemoryContentCacheStore()),
        remoteClient: _FakeRemoteManifestClient(),
      ),
    );

    final result = await receiver.receiveJson(_payloadJson(
      type: 'daily_session',
      contentId: 'missing_remote_session',
      bundleHint: 'missing_detail_bundle',
    ));

    expect(result.accepted, isFalse);
    expect(result.routeAvailable, isFalse);
    expect(result.route, isNull);
    expect(result.flags, contains('missing_content'));
    expect(result.message, isNot(contains('Quran')));
    expect(result.message, isNot(contains('Hadith')));
  });

  test('malformed payload is rejected with flags', () async {
    final result = await receiver.receiveJson('{"id": 1, "type": []}');

    expect(result.accepted, isFalse);
    expect(result.routeAvailable, isFalse);
    expect(result.flags, contains('malformed_payload'));
    expect(result.flags, contains('missing_required_fields'));
  });

  test('women mode lock-screen safety blocks cycle-sensitive payload copy',
      () async {
    final result = await receiver.receiveJson(
      _payloadJson(
        body: 'A private cycle reminder is ready.',
        lockScreenSafe: true,
      ),
      womenIbadahMode: const WomenIbadahMode(enabled: true),
    );

    expect(result.accepted, isFalse);
    expect(result.routeAvailable, isFalse);
    expect(result.flags, contains('cycle_sensitive_lock_screen_copy'));
  });

  test('English payload preserves localized title and body', () {
    final payload = LocalPushPayload.tryParseJson(_payloadJson(
      languageCode: 'en',
      title: 'Begin softly',
      body: 'A short Sakinah session is ready.',
    ));

    expect(payload, isNotNull);
    expect(payload!.title, 'Begin softly');
    expect(payload.body, 'A short Sakinah session is ready.');
    expect(payload.languageCode, 'en');
  });

  test('Indonesian payload preserves localized title and body', () {
    final payload = LocalPushPayload.tryParseJson(_payloadJson(
      languageCode: 'id',
      title: 'Mulai dengan lembut',
      body: 'Sesi Sakinah singkat sudah siap.',
    ));

    expect(payload, isNotNull);
    expect(payload!.title, 'Mulai dengan lembut');
    expect(payload.body, 'Sesi Sakinah singkat sudah siap.');
    expect(payload.languageCode, 'id');
  });

  test('Arabic payload preserves localized title and body', () {
    final payload = LocalPushPayload.tryParseJson(_payloadJson(
      languageCode: 'ar',
      title: 'ابدأ برفق',
      body: 'جلسة سكينة قصيرة جاهزة.',
    ));

    expect(payload, isNotNull);
    expect(payload!.title, 'ابدأ برفق');
    expect(payload.body, 'جلسة سكينة قصيرة جاهزة.');
    expect(payload.languageCode, 'ar');
  });

  test('notification permission denied produces no scheduled reminders',
      () async {
    const settings = PrayerSettings(
      latitude: 21.3891,
      longitude: 39.8579,
      method: 'umm_al_qura',
      locationLabel: 'Makkah',
      timezoneId: 'Asia/Riyadh',
    );
    final service = LocalNotificationServiceStub()..permissionGranted = false;
    final prayers = PrayerCalculationService()
        .calculateForDate(DateTime(2026, 5, 21), settings);

    final scheduled = await service.schedulePrayerReminders(settings, prayers);

    expect(scheduled, isEmpty);
    expect(service.scheduled, isEmpty);
  });
}

String _payloadJson({
  String type = 'daily_session',
  String contentId = 'session_morning_ease',
  String bundleHint = 'daily_session_detail_session_morning_ease',
  String languageCode = 'en',
  String title = 'Begin softly',
  String body = 'A short Sakinah session is ready.',
  bool lockScreenSafe = true,
}) {
  return jsonEncode({
    'id': 'local_push_test',
    'type': type,
    'contentId': contentId,
    'clusterId': 'calm_through_dhikr',
    'bundleHint': bundleHint,
    'languageCode': languageCode,
    'title': title,
    'body': body,
    'lockScreenSafe': lockScreenSafe,
    'data': {
      'type': type,
      'contentId': contentId,
      'clusterId': 'calm_through_dhikr',
      'bundleHint': bundleHint,
    },
  });
}

class _FakeRemoteManifestClient implements RemoteManifestClient {
  _FakeRemoteManifestClient({
    this.bundleHints = const {},
    this.bundles = const {},
  });

  final Map<String, BundleRef> bundleHints;
  final Map<String, String> bundles;

  @override
  Future<ContentManifest> loadManifest(ContentRequestContext context) async {
    return const ContentManifest(id: 'fixture', schemaVersion: 1, bundles: []);
  }

  @override
  Future<String> downloadBundle(BundleRef ref) async {
    final raw = bundles[ref.id];
    if (raw == null) {
      throw StateError('Missing fake bundle');
    }
    return raw;
  }

  @override
  Future<BundleRef?> resolveBundleHint(String bundleHint) async {
    return bundleHints[bundleHint];
  }
}

String _detailBundleJson(String sessionId) {
  return jsonEncode({
    'bundleId': 'detail_$sessionId',
    'bundleType': 'daily_session_bundle',
    'schemaVersion': 1,
    'language': 'en',
    'market': 'global',
    'status': 'published',
    'reviewStatus': 'approved',
    'sourceCorpusVersions': {'quran': 'fixture-corpus-v1'},
    'payload': {
      'dailySessions': [
        {
          'id': sessionId,
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
          'reviewStatus': 'approved',
        }
      ],
    },
  });
}

String _sha256(String raw) => sha256.convert(utf8.encode(raw)).toString();
