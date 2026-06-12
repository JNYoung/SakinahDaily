import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';

class ClosedTestingGuidePage extends ConsumerWidget {
  const ClosedTestingGuidePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final testingFeedbackChannel =
        ref.watch(appEnvironmentConfigProvider).testingFeedbackChannel;
    final preferences = ref.watch(userPreferencesProvider);
    final preferencesController = ref.read(userPreferencesProvider.notifier);
    final analytics = ref.watch(analyticsServiceProvider);

    return LanguageAwareScaffold(
      key: SakinahKeys.closedTestingGuidePage,
      title: l10n.t('closedTestingGuideTitle'),
      selectedNavIndex: 3,
      body: ListView(
        children: [
          AppCard(
            radius: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('closedTestingGuideIntroTitle'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(l10n.t('closedTestingGuideIntroBody')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            radius: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('closedTestingGuideChecklistTitle'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final key in _checklistKeys) ...[
                  _ChecklistItem(text: l10n.t(key)),
                  if (key != _checklistKeys.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            radius: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('closedTestingPromptTitle'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(l10n.t('closedTestingPromptBody')),
                const SizedBox(height: 12),
                for (final spec in _promptSpecs) ...[
                  _PromptItem(
                    key: spec.itemKey,
                    copyButtonKey: spec.copyButtonKey,
                    completedCheckboxKey: spec.completedCheckboxKey,
                    l10n: l10n,
                    dayLabel: l10n.t(spec.labelKey),
                    text: l10n.t(spec.textKey),
                    themeKey: spec.themeKey,
                    testingFeedbackChannel: testingFeedbackChannel,
                    isFeedbackSent: preferences.isClosedTestingPromptCompleted(
                      spec.promptDayId,
                    ),
                    onPromptCopied: () => _trackClosedTestingPrompt(
                      analytics,
                      AnalyticsEventCatalog.closedTestPromptCopied,
                      spec,
                    ),
                    onFeedbackSentChanged: (completed) {
                      unawaited(
                        preferencesController.setClosedTestingPromptCompleted(
                          spec.promptDayId,
                          completed,
                        ),
                      );
                      if (completed) {
                        _trackClosedTestingPrompt(
                          analytics,
                          AnalyticsEventCatalog.closedTestPromptMarkedSent,
                          spec,
                        );
                      }
                    },
                  ),
                  if (spec != _promptSpecs.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            radius: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.t('closedTestingFeedbackTitle'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (testingFeedbackChannel == null) ...[
                  Text(l10n.t('closedTestingFeedbackMissing')),
                ] else ...[
                  Text(l10n.t('closedTestingFeedbackBody')),
                  const SizedBox(height: 12),
                  SelectableText(testingFeedbackChannel),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton.icon(
                      key: SakinahKeys.closedTestingFeedbackCopyButton,
                      onPressed: () => _copyTestingFeedbackChannel(
                        context,
                        l10n,
                        testingFeedbackChannel,
                      ),
                      icon: const Icon(Icons.copy),
                      label: Text(l10n.t('copyTestingFeedback')),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _checklistKeys = [
  'closedTestingChecklistDailyOpen',
  'closedTestingChecklistPrayer',
  'closedTestingChecklistReminder',
  'closedTestingChecklistSession',
  'closedTestingChecklistPrivacy',
  'closedTestingChecklistFeedback',
];

const _promptSpecs = [
  _ClosedTestingPromptSpec(
    promptDayId: 'day1',
    itemKey: SakinahKeys.closedTestingPromptDay1,
    copyButtonKey: SakinahKeys.closedTestingPromptDay1CopyButton,
    completedCheckboxKey: SakinahKeys.closedTestingPromptDay1CompletedCheckbox,
    labelKey: 'closedTestingPromptDay1Label',
    textKey: 'closedTestingPromptDay1',
    themeKey: 'onboarding_location_clarity',
  ),
  _ClosedTestingPromptSpec(
    promptDayId: 'day3',
    itemKey: SakinahKeys.closedTestingPromptDay3,
    copyButtonKey: SakinahKeys.closedTestingPromptDay3CopyButton,
    completedCheckboxKey: SakinahKeys.closedTestingPromptDay3CompletedCheckbox,
    labelKey: 'closedTestingPromptDay3Label',
    textKey: 'closedTestingPromptDay3',
    themeKey: 'prayer_time_trust',
  ),
  _ClosedTestingPromptSpec(
    promptDayId: 'day7',
    itemKey: SakinahKeys.closedTestingPromptDay7,
    copyButtonKey: SakinahKeys.closedTestingPromptDay7CopyButton,
    completedCheckboxKey: SakinahKeys.closedTestingPromptDay7CompletedCheckbox,
    labelKey: 'closedTestingPromptDay7Label',
    textKey: 'closedTestingPromptDay7',
    themeKey: 'retention_reason_to_return',
  ),
  _ClosedTestingPromptSpec(
    promptDayId: 'day14',
    itemKey: SakinahKeys.closedTestingPromptDay14,
    copyButtonKey: SakinahKeys.closedTestingPromptDay14CopyButton,
    completedCheckboxKey: SakinahKeys.closedTestingPromptDay14CompletedCheckbox,
    labelKey: 'closedTestingPromptDay14Label',
    textKey: 'closedTestingPromptDay14',
    themeKey: 'retention_reason_to_return',
  ),
];

class _ClosedTestingPromptSpec {
  const _ClosedTestingPromptSpec({
    required this.promptDayId,
    required this.itemKey,
    required this.copyButtonKey,
    required this.completedCheckboxKey,
    required this.labelKey,
    required this.textKey,
    required this.themeKey,
  });

  final String promptDayId;
  final Key itemKey;
  final Key copyButtonKey;
  final Key completedCheckboxKey;
  final String labelKey;
  final String textKey;
  final String themeKey;
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _PromptItem extends StatelessWidget {
  const _PromptItem({
    super.key,
    required this.copyButtonKey,
    required this.completedCheckboxKey,
    required this.l10n,
    required this.dayLabel,
    required this.text,
    required this.themeKey,
    required this.testingFeedbackChannel,
    required this.isFeedbackSent,
    required this.onPromptCopied,
    required this.onFeedbackSentChanged,
  });

  final Key copyButtonKey;
  final Key completedCheckboxKey;
  final SakinahLocalizations l10n;
  final String dayLabel;
  final String text;
  final String themeKey;
  final String? testingFeedbackChannel;
  final bool isFeedbackSent;
  final VoidCallback onPromptCopied;
  final ValueChanged<bool> onFeedbackSentChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final testingFeedbackChannel = this.testingFeedbackChannel;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.rate_review_outlined, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(text),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.t('closedTestingPromptCopyThemeLabel')}: '
                    '$themeKey',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (testingFeedbackChannel != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        key: copyButtonKey,
                        onPressed: () => _copyTestingFeedbackPrompt(
                          context,
                          l10n,
                          dayLabel: dayLabel,
                          prompt: text,
                          themeKey: themeKey,
                          testingFeedbackChannel: testingFeedbackChannel,
                          onCopied: onPromptCopied,
                        ),
                        icon: const Icon(Icons.copy),
                        label: Text(l10n.t('copyTestingFeedbackPrompt')),
                      ),
                    ),
                    CheckboxListTile(
                      key: completedCheckboxKey,
                      value: isFeedbackSent,
                      onChanged: (value) =>
                          onFeedbackSentChanged(value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(l10n.t('closedTestingPromptFeedbackSent')),
                      subtitle:
                          Text(l10n.t('closedTestingPromptLocalOnlyStatus')),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _copyTestingFeedbackChannel(
  BuildContext context,
  SakinahLocalizations l10n,
  String testingFeedbackChannel,
) {
  Clipboard.setData(ClipboardData(text: testingFeedbackChannel));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(l10n.t('testingFeedbackCopied'))),
    );
}

void _copyTestingFeedbackPrompt(
  BuildContext context,
  SakinahLocalizations l10n, {
  required String dayLabel,
  required String prompt,
  required String themeKey,
  required String testingFeedbackChannel,
  required VoidCallback onCopied,
}) {
  final clipboardText = [
    l10n.t('closedTestingPromptCopyHeader'),
    dayLabel,
    '${l10n.t('closedTestingPromptCopyPromptLabel')}: $prompt',
    '${l10n.t('closedTestingPromptCopyThemeLabel')}: $themeKey',
    '${l10n.t('closedTestingPromptCopyChannelLabel')}: '
        '$testingFeedbackChannel',
    l10n.t('closedTestingPromptCopyPrivacyLine'),
  ].join('\n');

  Clipboard.setData(ClipboardData(text: clipboardText));
  onCopied();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(l10n.t('closedTestingPromptCopied'))),
    );
}

void _trackClosedTestingPrompt(
  AnalyticsService analytics,
  String eventName,
  _ClosedTestingPromptSpec spec,
) {
  analytics.track(eventName, {
    'prompt_day': spec.promptDayId,
    'theme_key': spec.themeKey,
    'source': 'closed_testing_guide',
  });
}
