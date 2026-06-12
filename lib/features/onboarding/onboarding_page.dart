import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/prayer_calculation_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.onboardingStarted,
      const {
        'screen': 'onboarding',
        'source': 'onboarding',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final controller = ref.read(userPreferencesProvider.notifier);
    final selectedPrayerPresetId =
        _matchingPresetId(preferences.prayerSettings);

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
              final languageCode = selection.first;
              unawaited(controller.setLanguage(languageCode));
              _trackOnboardingEvent(
                ref,
                AnalyticsEventCatalog.languageSelected,
                {
                  'language_code': languageCode,
                },
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('prayerLocation'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.t('onboardingPrayerLocationBody')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: SakinahKeys.onboardingPrayerLocationDropdown,
            initialValue: selectedPrayerPresetId,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              for (final preset in PrayerCalculationService.locationPresets)
                DropdownMenuItem(
                  value: preset.id,
                  child: Text(preset.label),
                ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              final preset = PrayerCalculationService.locationPresets
                  .firstWhere((preset) => preset.id == value);
              unawaited(
                  controller.setPrayerSettings(preset.toPrayerSettings()));
              _trackOnboardingEvent(
                ref,
                AnalyticsEventCatalog.locationMethodSelected,
                const {
                  'location_method': 'preset',
                },
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('onboardingPrayerNoGps'),
            style: Theme.of(context).textTheme.bodySmall,
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
                unawaited(controller.setGenderMode(value));
                _trackOnboardingEvent(
                  ref,
                  AnalyticsEventCatalog.genderModeSelected,
                );
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
                unawaited(controller.setAudioPreference(value));
                _trackOnboardingEvent(
                  ref,
                  AnalyticsEventCatalog.audioPreferenceSelected,
                  {
                    'audio_preference': value.name,
                  },
                );
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
            onPressed: () async {
              await controller.saveCurrent();
              final savedPreferences = ref.read(userPreferencesProvider);
              _trackOnboardingEvent(
                ref,
                AnalyticsEventCatalog.onboardingCompleted,
                {
                  'language_code': savedPreferences.languageCode,
                  'location_method':
                      _locationMethodFor(savedPreferences.prayerSettings),
                  'audio_preference': savedPreferences.audioPreference.name,
                },
              );
              if (context.mounted) {
                context.go('/home');
              }
            },
          ),
        ],
      ),
    );
  }
}

String? _matchingPresetId(PrayerSettings settings) {
  for (final preset in PrayerCalculationService.locationPresets) {
    if (preset.label == settings.locationLabel &&
        preset.method == settings.method &&
        preset.latitude == settings.latitude &&
        preset.longitude == settings.longitude) {
      return preset.id;
    }
  }
  return null;
}

String _locationMethodFor(PrayerSettings settings) {
  return _matchingPresetId(settings) == null ? 'manual' : 'preset';
}

void _trackOnboardingEvent(
  WidgetRef ref,
  String eventName, [
  Map<String, Object?> properties = const {},
]) {
  ref.read(analyticsServiceProvider).track(
    eventName,
    {
      ...properties,
      'source': 'onboarding',
    },
  );
}
