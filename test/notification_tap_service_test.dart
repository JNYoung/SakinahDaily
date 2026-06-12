import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';
import 'package:sakinah_daily/core/services/content_service.dart';
import 'package:sakinah_daily/core/services/local_push_receiver.dart';
import 'package:sakinah_daily/core/services/notification_tap_service.dart';

void main() {
  late NotificationTapService service;

  setUp(() {
    service = NotificationTapService(
      localPushReceiver: LocalPushReceiver(
        contentService: ContentService(
          seedRepository: SeedContentRepository(SeedContent.demo()),
          cacheRepository: ContentCacheRepository(InMemoryContentCacheStore()),
        ),
      ),
    );
  });

  test('prayer notification payload resolves to prayer route', () async {
    final result = await service.resolveRawPayload(jsonEncode({
      'type': 'prayer',
      'contentId': 'prayer',
      'fallbackRoute': '/prayer',
    }));

    expect(result.handled, isTrue);
    expect(result.route, '/prayer');
    expect(result.analyticsContentType, 'prayer');
    expect(result.flags, contains('notification_tap_fallback_prayer'));
  });

  test('daily session payload resolves through local push receiver', () async {
    final result = await service.resolveRawPayload(_localPushPayloadJson(
      type: 'daily_session',
      contentId: 'session_morning_ease',
    ));

    expect(result.handled, isTrue);
    expect(result.route, '/session/session_morning_ease');
    expect(result.analyticsContentType, 'daily_session');
    expect(result.flags, isEmpty);
  });

  test('quran payload resolves through local push receiver to verse detail',
      () async {
    final result = await service.resolveRawPayload(_localPushPayloadJson(
      type: 'quran',
      contentId: '94:5',
    ));

    expect(result.handled, isTrue);
    expect(result.route, '/quran/94:5');
    expect(result.analyticsContentType, 'quran');
    expect(result.flags, isEmpty);
  });

  test('malformed notification payload is not handled', () async {
    final result = await service.resolveRawPayload('{"type": 7}');

    expect(result.handled, isFalse);
    expect(result.route, isNull);
    expect(result.analyticsContentType, isNull);
    expect(result.flags, contains('malformed_payload'));
  });

  test('missing content uses safe fallback without inventing content',
      () async {
    final result = await service.resolveRawPayload(_localPushPayloadJson(
      type: 'daily_session',
      contentId: 'missing_session',
      fallbackRoute: '/home',
    ));

    expect(result.handled, isTrue);
    expect(result.route, '/home');
    expect(result.analyticsContentType, 'daily_session');
    expect(result.flags, contains('missing_content'));
    expect(result.flags, contains('fallback_route_used'));
  });

  test('notification payload does not include women exact status', () {
    final payload = NotificationTapPayload.prayer().toJson();

    expect(payload.keys, isNot(contains('womenIbadahMode')));
    expect(payload.keys, isNot(contains('womenStatus')));
    expect(payload.keys, isNot(contains('cycleStatus')));
  });
}

String _localPushPayloadJson({
  required String type,
  required String contentId,
  String fallbackRoute = '/home',
}) {
  return jsonEncode({
    'id': 'tap_test',
    'type': type,
    'contentId': contentId,
    'bundleHint': 'daily_session_detail_$contentId',
    'languageCode': 'en',
    'title': 'Begin softly',
    'body': 'A short Sakinah session is ready.',
    'lockScreenSafe': true,
    'fallbackRoute': fallbackRoute,
    'data': {
      'type': type,
      'contentId': contentId,
      'bundleHint': 'daily_session_detail_$contentId',
    },
  });
}
