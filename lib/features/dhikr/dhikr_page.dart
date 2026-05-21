import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/dhikr_counter_circle.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/source_chip.dart';

class DhikrPage extends ConsumerStatefulWidget {
  const DhikrPage({super.key});

  @override
  ConsumerState<DhikrPage> createState() => _DhikrPageState();
}

class _DhikrPageState extends ConsumerState<DhikrPage> {
  String? selectedId;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    final dhikrs = ref.watch(dhikrsProvider);
    final languageCode = ref.watch(userPreferencesProvider).languageCode;
    final l10n = SakinahLocalizations.of(context);
    final selected = dhikrs
        .where((dhikr) => dhikr.id == (selectedId ?? dhikrs.first.id))
        .first;

    return LanguageAwareScaffold(
      title: l10n.t('dhikr'),
      selectedNavIndex: 2,
      body: ListView(
        children: [
          DropdownButtonFormField<DhikrItem>(
            initialValue: selected,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: dhikrs
                .map(
                  (dhikr) => DropdownMenuItem(
                    value: dhikr,
                    child: Text(dhikr.title.resolve(languageCode)),
                  ),
                )
                .toList(),
            onChanged: (dhikr) {
              if (dhikr != null) {
                setState(() {
                  selectedId = dhikr.id;
                  count = 0;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            selected.arabicText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(selected.transliteration, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Center(
            child: DhikrCounterCircle(
              key: SakinahKeys.dhikrCounter,
              count: count,
              target: selected.targetCount,
              onTap: () => setState(() => count += 1),
            ),
          ),
          const SizedBox(height: 24),
          SourceChip(
            source: selected.source,
            reviewStatus: selected.reviewStatus.name,
          ),
        ],
      ),
    );
  }
}
