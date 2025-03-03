import 'package:flutter/material.dart';

class EmptyExamView extends StatelessWidget {
  final String message;

  const EmptyExamView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // Refresh action
              },
              icon: const Icon(Icons.refresh),
              label: Text('Refresh', style: theme.textTheme.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
}
