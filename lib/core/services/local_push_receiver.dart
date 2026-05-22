import '../models/local_push_payload.dart';
import '../models/sakinah_models.dart';
import 'content_service.dart';

class LocalPushReceiveResult {
  const LocalPushReceiveResult({
    required this.accepted,
    required this.routeAvailable,
    required this.message,
    required this.flags,
    this.route,
  });

  final bool accepted;
  final bool routeAvailable;
  final String? route;
  final String message;
  final List<String> flags;
}

class LocalPushReceiver {
  const LocalPushReceiver({required this.contentService});

  final ContentService contentService;

  Future<LocalPushReceiveResult> receiveJson(
    String rawJson, {
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    final flags = <String>[];
    final payload = LocalPushPayload.tryParseJson(rawJson);
    if (payload == null) {
      return _rejected(
        flags: ['malformed_payload', 'missing_required_fields'],
        message: 'This push payload could not be opened safely.',
      );
    }

    if (!payload.hasRequiredFields) {
      flags.add('missing_required_fields');
    }
    if (!payload.lockScreenSafe) {
      flags.add('lock_screen_not_safe');
    }
    if (_hasCycleSensitiveCopy(payload) &&
        womenIbadahMode.enabled &&
        womenIbadahMode.hideCycleSensitiveLockScreenCopy) {
      flags.add('cycle_sensitive_lock_screen_copy');
    }
    if (flags.isNotEmpty) {
      return _rejected(
        flags: flags,
        message: 'This push payload could not be opened safely.',
      );
    }

    return switch (payload.type) {
      LocalPushType.dailySession => await _resolveDailySession(payload),
      LocalPushType.dua => await _resolveDua(payload),
      LocalPushType.dhikr => await _resolveDhikr(payload),
      LocalPushType.quran => await _resolveQuran(payload),
      LocalPushType.unknown => _rejected(
          flags: const ['unknown_type'],
          message: 'This push type is not supported yet.',
        ),
    };
  }

  Future<LocalPushReceiveResult> _resolveDailySession(
    LocalPushPayload payload,
  ) async {
    final result = await contentService.recoverPushDeepLink(
      payload.contentId,
      bundleHint: payload.bundleHint,
    );
    if (!result.available || result.session == null) {
      return _missingContent();
    }
    return _accepted('/session/${result.session!.id}');
  }

  Future<LocalPushReceiveResult> _resolveDua(LocalPushPayload payload) async {
    final dua = contentService.loadDua(payload.contentId);
    if (dua == null) {
      return _missingContent();
    }
    return _accepted('/dua/${dua.id}');
  }

  Future<LocalPushReceiveResult> _resolveDhikr(LocalPushPayload payload) async {
    final dhikr = contentService.loadDhikr(payload.contentId);
    if (dhikr == null) {
      return _missingContent();
    }
    return _accepted('/dhikr');
  }

  Future<LocalPushReceiveResult> _resolveQuran(LocalPushPayload payload) async {
    final session = contentService.loadSessionContainingContent(
      payload.contentId,
    );
    if (session != null) {
      return _accepted('/session/${session.id}');
    }
    final verse = contentService.loadQuranVerse(payload.contentId);
    if (verse != null) {
      return LocalPushReceiveResult(
        accepted: true,
        routeAvailable: true,
        route: '/quran/${verse.verseKey}',
        message: 'Push content is available locally.',
        flags: const [],
      );
    }
    return _missingContent();
  }

  LocalPushReceiveResult _accepted(String route) {
    return LocalPushReceiveResult(
      accepted: true,
      routeAvailable: true,
      route: route,
      message: 'Push content is available locally.',
      flags: const [],
    );
  }

  LocalPushReceiveResult _missingContent() {
    return _rejected(
      flags: const ['missing_content'],
      message: 'This push content is not available offline yet.',
    );
  }

  LocalPushReceiveResult _rejected({
    required List<String> flags,
    required String message,
  }) {
    return LocalPushReceiveResult(
      accepted: false,
      routeAvailable: false,
      message: message,
      flags: List.unmodifiable(flags),
    );
  }

  bool _hasCycleSensitiveCopy(LocalPushPayload payload) {
    final copy = '${payload.title} ${payload.body}'.toLowerCase();
    return _cycleSensitiveTerms.any(copy.contains);
  }
}

const _cycleSensitiveTerms = [
  'menstruating',
  'menstruation',
  'period',
  'cycle',
  'postpartum',
  'nifas',
  'haidh',
  'الحيض',
  'النفاس',
];
