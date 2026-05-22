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

class ManualPrayerLocationPage extends ConsumerStatefulWidget {
  const ManualPrayerLocationPage({super.key});

  @override
  ConsumerState<ManualPrayerLocationPage> createState() =>
      _ManualPrayerLocationPageState();
}

class _ManualPrayerLocationPageState
    extends ConsumerState<ManualPrayerLocationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _timezoneController;
  late String _method;

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
                children: [
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
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    key: SakinahKeys.manualPrayerMethodDropdown,
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
                        setState(() => _method = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(l10n.t('locationLocalOnlyNoGps')),
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
