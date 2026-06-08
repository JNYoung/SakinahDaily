import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/prayer_calculation_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';
import 'device_location_flow.dart';

class ManualPrayerLocationPage extends ConsumerStatefulWidget {
  const ManualPrayerLocationPage({super.key});

  @override
  ConsumerState<ManualPrayerLocationPage> createState() =>
      _ManualPrayerLocationPageState();
}

class _ManualPrayerLocationPageState
    extends ConsumerState<ManualPrayerLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final _methodDropdownKey = GlobalKey<FormFieldState<String>>();
  late final TextEditingController _labelController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _timezoneController;
  late String _method;
  late String? _selectedPresetId;
  late List<PrayerLocationPreset> _cityPresets;
  bool _syncingPresetMethod = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(userPreferencesProvider).prayerSettings;
    _labelController = TextEditingController(text: settings.locationLabel);
    _latitudeController = TextEditingController(text: '${settings.latitude}');
    _longitudeController = TextEditingController(text: '${settings.longitude}');
    _timezoneController =
        TextEditingController(text: settings.timezoneId ?? '');
    _method = settings.method;
    _cityPresets = PrayerCalculationService.locationPresets;
    _selectedPresetId = _matchingPresetId(settings);
    unawaited(_loadRemoteCityPresets());
  }

  @override
  void dispose() {
    _labelController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final prayerService = ref.watch(prayerCalculationServiceProvider);
    final selectedPresetId =
        _cityPresets.any((preset) => preset.id == _selectedPresetId)
            ? _selectedPresetId
            : null;

    return LanguageAwareScaffold(
      title: l10n.t('manualPrayerLocationTitle'),
      selectedNavIndex: 3,
      body: Form(
        key: _formKey,
        child: ListView(
          key: SakinahKeys.manualPrayerLocationPage,
          children: [
            Text(
              l10n.t('manualPrayerLocationTitle'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.t('manualPrayerLocationBody')),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.t('devicePrayerLocationTitle'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.t('devicePrayerLocationBody')),
                  const SizedBox(height: 8),
                  Text(
                    l10n.t('deviceLocationPrivacyNote'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    key: SakinahKeys.manualUseDeviceLocationButton,
                    label: l10n.t('useDeviceLocation'),
                    icon: Icons.my_location_rounded,
                    onPressed: () => unawaited(_useDeviceLocation(l10n)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.t('choosePrayerCityTitle'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.t('choosePrayerCityBody')),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    key: SakinahKeys.manualLocationPresetDropdown,
                    initialValue: selectedPresetId,
                    decoration: InputDecoration(
                      labelText: l10n.t('prayerCityPreset'),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final preset in _cityPresets)
                        DropdownMenuItem(
                          value: preset.id,
                          child: Text(preset.label),
                        ),
                    ],
                    onChanged: (value) {
                      final preset = _cityPresets
                          .where((preset) => preset.id == value)
                          .firstOrNull;
                      if (preset != null) {
                        _applyPreset(preset);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.t('advancedLocationDetails'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: SakinahKeys.manualLocationLabelField,
                    controller: _labelController,
                    decoration: InputDecoration(
                      labelText: l10n.t('locationLabel'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return l10n.t('locationLabel');
                      }
                      return null;
                    },
                    onChanged: (_) => _clearPresetSelection(),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: SakinahKeys.manualLatitudeField,
                    controller: _latitudeController,
                    decoration: InputDecoration(
                      labelText: l10n.t('latitude'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [_CoordinateInputFormatter()],
                    onChanged: (_) => _clearPresetSelection(),
                    validator: (value) => _validateRange(
                      value,
                      min: -90,
                      max: 90,
                      message: l10n.t('invalidLatitude'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: SakinahKeys.manualLongitudeField,
                    controller: _longitudeController,
                    decoration: InputDecoration(
                      labelText: l10n.t('longitude'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [_CoordinateInputFormatter()],
                    onChanged: (_) => _clearPresetSelection(),
                    validator: (value) => _validateRange(
                      value,
                      min: -180,
                      max: 180,
                      message: l10n.t('invalidLongitude'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: SakinahKeys.manualTimezoneField,
                    controller: _timezoneController,
                    decoration: InputDecoration(
                      labelText: l10n.t('timezoneId'),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _clearPresetSelection(),
                  ),
                  const SizedBox(height: 14),
                  KeyedSubtree(
                    key: SakinahKeys.manualPrayerMethodDropdown,
                    child: DropdownButtonFormField<String>(
                      key: _methodDropdownKey,
                      initialValue: _method,
                      decoration: InputDecoration(
                        labelText: l10n.t('prayerMethod'),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final methodId
                            in PrayerCalculationService.supportedMethodIds)
                          DropdownMenuItem(
                            value: methodId,
                            child: Text(prayerService.methodLabel(methodId)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          if (_syncingPresetMethod) {
                            _method = value;
                            return;
                          }
                          setState(() {
                            _method = value;
                            _selectedPresetId = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(l10n.t('locationLocalOnly')),
            const SizedBox(height: 18),
            PrimaryButton(
              key: SakinahKeys.manualLocationSaveButton,
              label: l10n.t('saveLocation'),
              icon: Icons.save_outlined,
              onPressed: () => unawaited(_save(l10n)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(SakinahLocalizations l10n) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final timezone = _timezoneController.text.trim();
    final settings = PrayerSettings(
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      method: _method,
      locationLabel: _labelController.text.trim(),
      timezoneId: timezone.isEmpty ? null : timezone,
      locationMode: _selectedPresetId == null
          ? PrayerLocationMode.manual
          : PrayerLocationMode.preset,
    );
    await ref.read(userPreferencesProvider.notifier).setPrayerSettings(
          settings,
        );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('locationSaved'))),
    );
  }

  Future<void> _useDeviceLocation(SakinahLocalizations l10n) async {
    final saved = await requestAndSaveDevicePrayerLocation(
      context: context,
      ref: ref,
      l10n: l10n,
    );
    if (!saved || !mounted) {
      return;
    }
    final settings = ref.read(userPreferencesProvider).prayerSettings;
    setState(() {
      _labelController.text = settings.locationLabel;
      _latitudeController.text = '${settings.latitude}';
      _longitudeController.text = '${settings.longitude}';
      _timezoneController.text = settings.timezoneId ?? '';
      _method = settings.method;
      _selectedPresetId = _matchingPresetId(settings);
      _methodDropdownKey.currentState?.didChange(settings.method);
    });
  }

  Future<void> _loadRemoteCityPresets() async {
    final client = ref.read(remotePrayerLocationClientProvider);
    if (client == null) {
      return;
    }
    try {
      final presets = await client.searchCities(
        locale: ref.read(localeProvider).languageCode,
      );
      if (!mounted || presets.isEmpty) {
        return;
      }
      final settings = ref.read(userPreferencesProvider).prayerSettings;
      setState(() {
        _cityPresets = presets;
        _selectedPresetId = _matchingPresetId(settings);
      });
    } on Object {
      // Keep the bundled MVP presets as the offline fallback.
    }
  }

  void _applyPreset(PrayerLocationPreset preset) {
    _syncingPresetMethod = true;
    setState(() {
      _selectedPresetId = preset.id;
      _labelController.text = preset.label;
      _latitudeController.text = '${preset.latitude}';
      _longitudeController.text = '${preset.longitude}';
      _timezoneController.text = preset.timezoneId;
      _method = preset.method;
      _methodDropdownKey.currentState?.didChange(preset.method);
    });
    _syncingPresetMethod = false;
  }

  void _clearPresetSelection() {
    if (_selectedPresetId == null) {
      return;
    }
    setState(() => _selectedPresetId = null);
  }

  String? _matchingPresetId(PrayerSettings settings) {
    if (settings.locationMode != PrayerLocationMode.preset) {
      return null;
    }
    return _cityPresets
        .where(
          (preset) =>
              preset.label == settings.locationLabel &&
              preset.latitude == settings.latitude &&
              preset.longitude == settings.longitude &&
              preset.timezoneId == settings.timezoneId &&
              preset.method == settings.method,
        )
        .firstOrNull
        ?.id;
  }

  String? _validateRange(
    String? raw, {
    required double min,
    required double max,
    required String message,
  }) {
    final value = double.tryParse((raw ?? '').trim());
    if (value == null || value < min || value > max) {
      return message;
    }
    return null;
  }
}

class _CoordinateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (RegExp(r'^-?\d*\.?\d*$').hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
