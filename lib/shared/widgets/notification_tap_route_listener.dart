import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/notification_tap_service.dart';

class NotificationTapRouteListener extends ConsumerStatefulWidget {
  const NotificationTapRouteListener({
    required this.child,
    this.router,
    super.key,
  });

  final Widget child;
  final GoRouter? router;

  @override
  ConsumerState<NotificationTapRouteListener> createState() =>
      _NotificationTapRouteListenerState();
}

class _NotificationTapRouteListenerState
    extends ConsumerState<NotificationTapRouteListener> {
  NotificationTapResult? _scheduledResult;
  bool _launchPayloadChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_resolveLaunchPayload());
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(notificationTapResultProvider);
    if (result != null && !identical(_scheduledResult, result)) {
      _scheduledResult = result;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final current = ref.read(notificationTapResultProvider);
        if (!identical(current, result)) {
          return;
        }
        _trackLocalPushResolutionResult(result);
        _trackNotificationTapResult(result);
        final route = result.route;
        if (result.handled && route != null && route.isNotEmpty) {
          final router = widget.router;
          if (router != null) {
            router.go(route);
          } else {
            context.go(route);
          }
          _trackNotificationTapOpened(result);
        }
        ref.read(notificationTapResultProvider.notifier).state = null;
        _scheduledResult = null;
      });
    }
    return widget.child;
  }

  void _trackNotificationTapResult(NotificationTapResult result) {
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.notificationTapResult,
      {
        'content_type': _notificationTapContentType(result),
        'source': 'local_notification',
        'change_type': _notificationTapChangeType(result),
      },
    );
  }

  void _trackLocalPushResolutionResult(NotificationTapResult result) {
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.localPushResolutionResult,
      {
        'content_type': _notificationTapContentType(result),
        'source': 'local_notification',
        'change_type': _notificationTapChangeType(result),
      },
    );
  }

  void _trackNotificationTapOpened(NotificationTapResult result) {
    final contentType = result.analyticsContentType;
    if (contentType == null || contentType.isEmpty) {
      return;
    }
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.notificationTapOpened,
      {
        'content_type': contentType,
        'source': 'local_notification',
      },
    );
  }

  String _notificationTapContentType(NotificationTapResult result) {
    final contentType = result.analyticsContentType;
    if (contentType == null || contentType.isEmpty) {
      return 'unknown';
    }
    return contentType;
  }

  String _notificationTapChangeType(NotificationTapResult result) {
    final route = result.route;
    if (result.handled && route != null && route.isNotEmpty) {
      return 'opened';
    }

    for (final flag in result.flags) {
      final changeType = switch (flag) {
        'malformed_payload' => 'malformed_payload',
        'notification_tap_missing_content' => 'missing_content',
        'fallback_route_used' => 'fallback_route_used',
        'direct_route_fallback' => 'direct_route_fallback',
        _ => null,
      };
      if (changeType != null) {
        return changeType;
      }
    }

    return result.handled ? 'missing_route' : 'unhandled';
  }

  Future<void> _resolveLaunchPayload() async {
    if (_launchPayloadChecked) {
      return;
    }
    _launchPayloadChecked = true;

    final launchPayload =
        await ref.read(notificationServiceProvider).takeLaunchPayload();
    if (!mounted || launchPayload == null || launchPayload.trim().isEmpty) {
      return;
    }

    final result = await ref
        .read(notificationTapServiceProvider)
        .resolveRawPayload(launchPayload);
    if (!mounted) {
      return;
    }
    ref.read(notificationTapResultProvider.notifier).state = result;
  }
}
