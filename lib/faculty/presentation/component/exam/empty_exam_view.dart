import 'package:flutter/material.dart';
import '../../../../common/theme/app_theme.dart';

class EmptyExamView extends StatelessWidget {
  const EmptyExamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: context.colors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No exam schedules yet',
            style: context.textStyles.subtitle1.textPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            'Add one by tapping the button below',
            style: context.textStyles.body2.textHint,
          ),
        ],
      ),
    );
  }
}
