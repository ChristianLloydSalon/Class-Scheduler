import 'package:flutter/material.dart';

class EmptyCourseView extends StatelessWidget {
  final String message;

  const EmptyCourseView({super.key, this.message = 'No courses available'});

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
              Icons.school_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
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
