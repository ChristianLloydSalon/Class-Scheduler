import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class SemesterCard extends StatelessWidget {
  final Map<String, dynamic> semester;
  final VoidCallback onTap;

  const SemesterCard({super.key, required this.semester, required this.onTap});

  String _getSemesterName() {
    final semesterNumber = semester['semester'] as int?;
    final year = semester['year'] as int?;

    if (semesterNumber == null || year == null) return 'Unknown Semester';

    String ordinal;
    switch (semesterNumber) {
      case 1:
        ordinal = 'First';
        break;
      case 2:
        ordinal = 'Second';
        break;
      case 3:
        ordinal = 'Summer';
        break;
      default:
        ordinal = '$semesterNumber';
    }

    return '$ordinal Semester $year';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    '${semester['semester'] ?? "?"}',
                    style: context.textStyles.heading3.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSemesterName(),
                      style: context.textStyles.subtitle1.textPrimary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Academic Year ${semester['year'] ?? "Unknown"}',
                      style: context.textStyles.body2.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
