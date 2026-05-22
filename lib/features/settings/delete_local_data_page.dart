import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class DeleteLocalDataPage extends ConsumerStatefulWidget {
  const DeleteLocalDataPage({super.key});

  @override
  ConsumerState<DeleteLocalDataPage> createState() =>
      _DeleteLocalDataPageState();
}

class _DeleteLocalDataPageState extends ConsumerState<DeleteLocalDataPage> {
  bool _deleting = false;
  bool _deleted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);

    return LanguageAwareScaffold(
      key: SakinahKeys.deleteLocalDataPage,
      title: l10n.t('deleteLocalDataTitle'),
      selectedNavIndex: 3,
      body: ListView(
        children: [
          AppCard(
            radius: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.t('deleteLocalDataBody')),
                const SizedBox(height: 12),
                Text(l10n.t('deleteLocalDataKeepsSeed')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            key: SakinahKeys.deleteLocalDataButton,
            label: _deleting
                ? l10n.t('deleteLocalDataDeleting')
                : l10n.t('deleteLocalDataConfirm'),
            icon: Icons.delete_outline,
            onPressed: _deleting ? null : () => _confirmDelete(context, l10n),
          ),
          if (_deleted) ...[
            const SizedBox(height: 16),
            AppCard(
              radius: 8,
              child: Text(l10n.t('deleteLocalDataSuccess')),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SakinahLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.t('deleteLocalDataDialogTitle')),
          content: Text(l10n.t('deleteLocalDataDialogBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.t('deleteLocalDataCancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.t('deleteLocalDataConfirm')),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _deleting = true);
    await ref.read(localDataDeletionServiceProvider).deleteLocalData();
    await ref.read(userPreferencesProvider.notifier).resetToDefaults();
    ref.read(notificationPermissionFeedbackProvider.notifier).state = null;
    ref.invalidate(contentServiceProvider);
    ref.invalidate(contentRepositoryProvider);
    if (!mounted) {
      return;
    }
    setState(() {
      _deleting = false;
      _deleted = true;
    });
  }
}
