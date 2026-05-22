import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
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
        final route = result.route;
        if (result.handled && route != null && route.isNotEmpty) {
          final router = widget.router;
          if (router != null) {
            router.go(route);
          } else {
            context.go(route);
          }
        }
        ref.read(notificationTapResultProvider.notifier).state = null;
        _scheduledResult = null;
      });
    }
    return widget.child;
  }
}
