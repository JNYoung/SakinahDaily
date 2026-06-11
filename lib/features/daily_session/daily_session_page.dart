import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/audio_player_bar.dart';
import '../../shared/widgets/dhikr_counter_circle.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/source_chip.dart';

class DailySessionPage extends ConsumerStatefulWidget {
  const DailySessionPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<DailySessionPage> createState() => _DailySessionPageState();
}

class _DailySessionPageState extends ConsumerState<DailySessionPage> {
  int index = 0;
  int dhikrCount = 0;
  bool resumedFromProgress = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(analyticsServiceProvider)
        .track(AnalyticsEventCatalog.dailySessionStarted, {
      'session_id': widget.sessionId,
    });
    unawaited(_startOrResumeSession());
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(contentRepositoryProvider);
    final preferences = ref.watch(userPreferencesProvider);
    final l10n = SakinahLocalizations.of(context);
    final session = repo.getDailySession(widget.sessionId);
    final womenModeDecision = ref
        .watch(womenModeContentPolicyProvider)
        .evaluate(preferences.womenIbadahMode);

    if (session == null) {
      return LanguageAwareScaffold(
        title: l10n.t('session'),
        body: Center(child: Text(l10n.t('sessionUnavailable'))),
      );
    }

    final step = session.steps[index];
    final stepTitle = step.title.resolve(preferences.languageCode);
    final showWomenModeNote = preferences.womenIbadahMode.enabled &&
        womenModeDecision.flags.any(
          (flag) =>
              flag == 'prefer_dua_dhikr_reflection' ||
              flag == 'gentle_support' ||
              flag == 'privacy_safe_copy',
        );

    return LanguageAwareScaffold(
      title: session.title.resolve(preferences.languageCode),
      darkPattern: true,
      showAppBar: false,
      selectedNavIndex: 2,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            session.title.resolve(preferences.languageCode),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.stepProgress(index + 1, session.steps.length, stepTitle),
            style: const TextStyle(color: Colors.white70),
          ),
          if (resumedFromProgress) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Chip(
                key: SakinahKeys.sessionResumeBadge,
                label: Text(l10n.t('resumeSession')),
              ),
            ),
          ],
          if (showWomenModeNote) ...[
            const SizedBox(height: 12),
            AppCard(
              key: SakinahKeys.sessionWomenModeNote,
              color: SakinahColors.navyCard,
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: SakinahColors.sandGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.t('womenModeSessionNoteTitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.t('womenModeSessionNoteBody'),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          ClipRRect(
            key: SakinahKeys.sessionProgressBar,
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (index + 1) / session.steps.length,
              minHeight: 8,
              color: SakinahColors.sandGold,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: _StepContent(
                step: step,
                languageCode: preferences.languageCode,
                dhikrCount: dhikrCount,
                onDhikrTap: () => setState(() => dhikrCount += 1),
              ),
            ),
          ),
          PrimaryButton(
            key: index == session.steps.length - 1
                ? SakinahKeys.sessionFinishButton
                : SakinahKeys.sessionNextButton,
            label: index == session.steps.length - 1
                ? l10n.t('finish')
                : l10n.t('next'),
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              if (index == session.steps.length - 1) {
                unawaited(_finishSession(session, preferences.languageCode));
                return;
              }
              final nextIndex = index + 1;
              setState(() {
                index = nextIndex;
                resumedFromProgress = false;
              });
              unawaited(
                ref
                    .read(sessionProgressControllerProvider.notifier)
                    .updateStep(session.id, nextIndex),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startOrResumeSession() async {
    final session =
        ref.read(contentRepositoryProvider).getDailySession(widget.sessionId);
    if (session == null) {
      return;
    }
    final languageCode = ref.read(userPreferencesProvider).languageCode;
    final progress = await ref
        .read(sessionProgressControllerProvider.notifier)
        .startSession(session, languageCode: languageCode);
    if (!mounted) {
      return;
    }
    final maxIndex = (session.steps.length - 1).clamp(0, session.steps.length);
    final nextIndex = progress.currentStepIndex.clamp(0, maxIndex).toInt();
    setState(() {
      index = nextIndex;
      resumedFromProgress = nextIndex > 0;
    });
  }

  Future<void> _finishSession(
    DailySession session,
    String languageCode,
  ) async {
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.dailySessionCompleted,
      {'session_id': widget.sessionId},
    );
    await ref
        .read(sessionProgressControllerProvider.notifier)
        .completeSession(session, languageCode: languageCode);
    if (!mounted) {
      return;
    }
    context.go('/session/${session.id}/completed');
  }
}

class _StepContent extends ConsumerWidget {
  const _StepContent({
    required this.step,
    required this.languageCode,
    required this.dhikrCount,
    required this.onDhikrTap,
  });

  final DailySessionStep step;
  final String languageCode;
  final int dhikrCount;
  final VoidCallback onDhikrTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(contentRepositoryProvider);
    final audioPolicyService = ref.watch(audioPolicyServiceProvider);
    final audioPlayer = ref.watch(audioPlayerProvider);
    final l10n = SakinahLocalizations.of(context);
    final title = step.title.resolve(languageCode);

    if (step.type == 'quran') {
      final ayah = repo.getQuranAyah(step.contentId ?? '');
      final audio = ayah?.audioAssetId == null
          ? null
          : repo.getAudioAsset(ayah!.audioAssetId!);
      final policy = audioPolicyService.evaluate(audio);
      return Column(
        children: [
          AppCard(
            color: SakinahColors.navyCard,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 26),
                Text(
                  ayah?.arabicText ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.quranVerseLabel(ayah?.verseKey ?? ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: SakinahColors.sandGold),
                ),
                const SizedBox(height: 18),
                Text(
                  ayah?.translations.resolve(languageCode) ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  policy.textOnlyFallback
                      ? l10n.t('textOnlyFallback')
                      : l10n.recitedBy(
                          audio?.displayVoiceName ?? l10n.t('approvedReciter'),
                        ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (audio != null)
            AudioPlayerBar(
              key: SakinahKeys.sessionAudioPlayerBar,
              asset: audio,
              policy: policy,
              player: audioPlayer,
            ),
          const SizedBox(height: 20),
          AppCard(
            key: SakinahKeys.sessionSafetyCard,
            color: SakinahColors.navyCard,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    color: SakinahColors.sandGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('quranSafetyTitle'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.t('quranSafetyDescription'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (step.type == 'dua') {
      final dua = repo.getDua(step.contentId ?? '');
      return AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(dua?.arabicText ?? '', textAlign: TextAlign.end),
            const SizedBox(height: 8),
            Text(dua?.transliteration ?? ''),
            const SizedBox(height: 8),
            Text(dua?.translations.resolve(languageCode) ?? ''),
            const SizedBox(height: 12),
            if (dua != null)
              SourceChip(
                  source: dua.source, reviewStatus: dua.reviewStatus.name),
          ],
        ),
      );
    }

    if (step.type == 'dhikr') {
      final dhikr = repo.getDhikr(step.contentId ?? '');
      return AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(dhikr?.arabicText ?? ''),
            const SizedBox(height: 16),
            DhikrCounterCircle(
              key: SakinahKeys.sessionDhikrCounter,
              count: dhikrCount,
              target: step.targetCount ?? dhikr?.targetCount ?? 33,
              onTap: onDhikrTap,
            ),
          ],
        ),
      );
    }

    if (step.type == 'reflection') {
      final reflection = repo.getReflection(step.contentId ?? '');
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(reflection?.prompt.resolve(languageCode) ?? ''),
            const SizedBox(height: 18),
            Container(
              key: SakinahKeys.sessionReflectionSafetyCard,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : SakinahColors.ivory,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: SakinahColors.sandGold.withValues(alpha: 0.36),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: SakinahColors.sandGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.t('reflectionSafetyTitle'),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(l10n.t('reflectionSafetyDescription')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(l10n.t('completionFallback')),
        ],
      ),
    );
  }
}
