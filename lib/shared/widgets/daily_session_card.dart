import 'package:flutter/material.dart';

import '../../core/models/sakinah_models.dart';
import 'app_card.dart';
import 'primary_button.dart';

class DailySessionCard extends StatelessWidget {
  const DailySessionCard({
    required this.session,
    required this.languageCode,
    required this.startLabel,
    required this.onStart,
    super.key,
  });

  final DailySession session;
  final String languageCode;
  final String startLabel;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title.resolve(languageCode),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(session.subtitle.resolve(languageCode)),
          const SizedBox(height: 16),
          PrimaryButton(
            label: startLabel,
            icon: Icons.play_arrow_rounded,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}
