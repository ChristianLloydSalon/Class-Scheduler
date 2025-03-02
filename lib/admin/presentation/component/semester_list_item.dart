import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/admin/presentation/screen/department_screen.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class SemesterListItem extends StatelessWidget {
  final QueryDocumentSnapshot semester;
  final String semesterId;

  const SemesterListItem({
    super.key,
    required this.semester,
    required this.semesterId,
  });

  @override
  Widget build(BuildContext context) {
    final data = semester.data() as Map<String, dynamic>;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DepartmentScreen(semesterId: semesterId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${data['semester']}',
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
                      'Year ${data['year']}',
                      style: context.textStyles.body1.textPrimary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Semester ${data['semester']}',
                      style: context.textStyles.caption1.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.colors.textHint.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
