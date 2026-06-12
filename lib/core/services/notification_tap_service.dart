import 'dart:convert';

import 'local_push_receiver.dart';

class NotificationTapPayload {
  const NotificationTapPayload({
    required this.id,
    required this.type,
    required this.data,
    this.contentId,
    this.bundleHint,
    this.fallbackRoute,
  });

  final String id;
  final String type;
  final String? contentId;
  final String? bundleHint;
  final String? fallbackRoute;
  final Map<String, String> data;

  factory NotificationTapPayload.prayer() {
    return const NotificationTapPayload(
      id: 'prayer',
      type: 'prayer',
      contentId: 'prayer',
      fallbackRoute: '/prayer',
      data: {
        'type': 'prayer',
        'contentId': 'prayer',
        'fallbackRoute': '/prayer',
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      if (contentId != null) 'contentId': contentId,
      if (bundleHint != null) 'bundleHint': bundleHint,
      if (fallbackRoute != null) 'fallbackRoute': fallbackRoute,
      'data': data,
    };
  }
}

class NotificationTapResult {
  const NotificationTapResult({
    required this.handled,
    required this.flags,
    this.analyticsContentType,
    this.route,
  });

  final bool handled;
  final String? route;
  final String? analyticsContentType;
  final List<String> flags;
}

class NotificationTapService {
  const NotificationTapService({this.localPushReceiver});

  final LocalPushReceiver? localPushReceiver;

  NotificationTapPayload? parseNotificationPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final type = _stringValue(decoded['type']);
      if (type == null) {
        return null;
      }
      final data = decoded['data'] is Map<String, dynamic>
          ? (decoded['data'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, '$value'))
          : const <String, String>{};
      return NotificationTapPayload(
        id: _stringValue(decoded['id']) ?? data['id'] ?? '',
        type: type,
        contentId: _stringValue(decoded['contentId']) ?? data['contentId'],
        bundleHint: _stringValue(decoded['bundleHint']) ?? data['bundleHint'],
        fallbackRoute:
            _stringValue(decoded['fallbackRoute']) ?? data['fallbackRoute'],
        data: data,
      );
    } on Object {
      return null;
    }
  }

  Future<NotificationTapResult> resolveRawPayload(String? rawPayload) async {
    final payload = parseNotificationPayload(rawPayload);
    if (payload == null) {
      return const NotificationTapResult(
        handled: false,
        flags: ['malformed_payload'],
      );
    }
    return resolveTapRoute(payload, rawPayload: rawPayload);
  }

  Future<NotificationTapResult> resolveTapRoute(
    NotificationTapPayload payload, {
    String? rawPayload,
  }) async {
    if (payload.type == 'prayer') {
      return const NotificationTapResult(
        handled: true,
        route: '/prayer',
        analyticsContentType: 'prayer',
        flags: ['notification_tap_fallback_prayer'],
      );
    }

    if (_usesLocalPushReceiver(payload.type) && rawPayload != null) {
      final receiver = localPushReceiver;
      if (receiver != null && payload.contentId != null) {
        final result = await receiver.receiveJson(rawPayload);
        if (result.accepted && result.routeAvailable && result.route != null) {
          return NotificationTapResult(
            handled: true,
            route: result.route,
            analyticsContentType: _analyticsContentType(payload.type),
            flags: result.flags,
          );
        }
        if (payload.fallbackRoute != null) {
          return NotificationTapResult(
            handled: true,
            route: payload.fallbackRoute,
            analyticsContentType: _analyticsContentType(payload.type),
            flags: [...result.flags, 'fallback_route_used'],
          );
        }
        final directRoute = _directFallbackRoute(payload);
        if (directRoute != null) {
          return NotificationTapResult(
            handled: true,
            route: directRoute,
            analyticsContentType: _analyticsContentType(payload.type),
            flags: [...result.flags, 'direct_route_fallback'],
          );
        }
        return NotificationTapResult(
          handled: false,
          flags: result.flags,
        );
      }
    }

    final directRoute = _directFallbackRoute(payload);
    if (directRoute != null) {
      return NotificationTapResult(
        handled: true,
        route: directRoute,
        analyticsContentType: _analyticsContentType(payload.type),
        flags: const ['direct_route_fallback'],
      );
    }

    if (payload.fallbackRoute != null) {
      return NotificationTapResult(
        handled: true,
        route: payload.fallbackRoute,
        analyticsContentType: _analyticsContentType(payload.type),
        flags: const ['fallback_route_used'],
      );
    }

    return const NotificationTapResult(
      handled: false,
      flags: ['notification_tap_missing_content'],
    );
  }

  bool _usesLocalPushReceiver(String type) {
    return switch (type) {
      'daily_session' || 'dailySession' || 'dua' || 'dhikr' || 'quran' => true,
      _ => false,
    };
  }

  String? _analyticsContentType(String type) {
    return switch (type) {
      'daily_session' || 'dailySession' => 'daily_session',
      'prayer' => 'prayer',
      'quran' => 'quran',
      'dua' => 'dua',
      'dhikr' => 'dhikr',
      _ => null,
    };
  }

  String? _directFallbackRoute(NotificationTapPayload payload) {
    final contentId = payload.contentId;
    if (contentId == null || contentId.isEmpty) {
      return null;
    }
    return switch (payload.type) {
      'dua' => '/dua/$contentId',
      'dhikr' => '/dhikr/$contentId',
      _ => null,
    };
  }
}

String? _stringValue(Object? value) => value is String ? value : null;
