import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/privacy/privacy_data_inventory.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';

class PrivacyDataInventoryPage extends ConsumerWidget {
  const PrivacyDataInventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final categories = ref.watch(privacyDataInventoryProvider);

    return LanguageAwareScaffold(
      key: SakinahKeys.privacyDataInventoryPage,
      title: l10n.t('dataInventoryTitle'),
      selectedNavIndex: 3,
      body: ListView.separated(
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(l10n.t('dataInventoryBody'));
          }
          return _InventoryCard(category: categories[index - 1]);
        },
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.category});

  final PrivacyDataCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      radius: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t(category.displayNameKey),
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: _storageLabel(l10n, category.storageLocation)),
              _Tag(label: _sensitivityLabel(l10n, category.sensitivity)),
              _Tag(
                label: category.leavesDevice
                    ? l10n.t('leavesDeviceShort')
                    : l10n.t('localOnlyShort'),
              ),
              if (category.userCanDelete)
                _Tag(label: l10n.t('userCanDeleteShort')),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.t(category.notesKey)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

String _storageLabel(
  SakinahLocalizations l10n,
  PrivacyStorageLocation storageLocation,
) {
  return switch (storageLocation) {
    PrivacyStorageLocation.localDevice => l10n.t('storageLocalDevice'),
    PrivacyStorageLocation.remoteOptional => l10n.t('storageRemoteOptional'),
    PrivacyStorageLocation.notCollected => l10n.t('storageNotCollected'),
  };
}

String _sensitivityLabel(
  SakinahLocalizations l10n,
  PrivacySensitivity sensitivity,
) {
  return switch (sensitivity) {
    PrivacySensitivity.low => l10n.t('sensitivityLow'),
    PrivacySensitivity.medium => l10n.t('sensitivityMedium'),
    PrivacySensitivity.high => l10n.t('sensitivityHigh'),
  };
}
