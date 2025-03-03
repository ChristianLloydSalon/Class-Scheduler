import 'package:flutter/material.dart';

class EmptySemesterView extends StatelessWidget {
  const EmptySemesterView({super.key});

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
              Icons.calendar_today_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No semesters available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Semesters will appear here once they are created by an administrator.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // This would typically trigger a refresh
              },
              icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
              label: Text(
                'Refresh',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
