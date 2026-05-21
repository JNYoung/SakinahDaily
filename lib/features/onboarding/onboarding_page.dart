import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final controller = ref.read(userPreferencesProvider.notifier);

    return LanguageAwareScaffold(
      title: l10n.t('appTitle'),
      body: ListView(
        children: [
          Text(
            l10n.t('onboardingTitle'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.t('onboardingSubtitle')),
          const SizedBox(height: 24),
          Text(l10n.t('language'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('English')),
              ButtonSegment(value: 'id', label: Text('Indonesia')),
              ButtonSegment(value: 'ar', label: Text('العربية')),
            ],
            selected: {preferences.languageCode},
            onSelectionChanged: (selection) {
              controller.setLanguage(selection.first);
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('genderMode'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<GenderMode>(
            initialValue: preferences.genderMode,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              DropdownMenuItem(
                value: GenderMode.male,
                child: Text(l10n.t('genderMale')),
              ),
              DropdownMenuItem(
                value: GenderMode.female,
                child: Text(l10n.t('genderFemale')),
              ),
              DropdownMenuItem(
                value: GenderMode.preferNotToSay,
                child: Text(l10n.t('genderPreferNotToSay')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.setGenderMode(value);
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('audioPreference'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<AudioPreference>(
            initialValue: preferences.audioPreference,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              DropdownMenuItem(
                value: AudioPreference.recitationOnly,
                child: Text(l10n.t('audioRecitationOnly')),
              ),
              DropdownMenuItem(
                value: AudioPreference.quietGuidance,
                child: Text(l10n.t('audioQuietGuidance')),
              ),
              DropdownMenuItem(
                value: AudioPreference.textFirst,
                child: Text(l10n.t('audioTextFirst')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.setAudioPreference(value);
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('prayerReminderConsent'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            key: SakinahKeys.onboardingContinueButton,
            label: l10n.t('continueLabel'),
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}
