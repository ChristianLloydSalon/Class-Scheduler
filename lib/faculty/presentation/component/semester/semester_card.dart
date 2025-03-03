import 'package:flutter/material.dart';

class SemesterCard extends StatelessWidget {
  final Map<String, dynamic> semester;
  final VoidCallback onTap;

  const SemesterCard({super.key, required this.semester, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getStatusColor() {
      switch ((semester['status'] as String?)?.toLowerCase()) {
        case 'active':
          return Colors.green;
        case 'upcoming':
          return Colors.blue;
        case 'completed':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semester ${semester['semester'] as int? ?? 0}, Year ${semester['year'] as int? ?? 0}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Year ${semester['year'] as int? ?? 0} - ${semester['semester'] as int? ?? 0}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            semester['status'] as String? ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: getStatusColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
