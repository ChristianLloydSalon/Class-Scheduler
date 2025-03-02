import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/admin/presentation/screen/course_screen.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class DepartmentListItem extends StatelessWidget {
  final QueryDocumentSnapshot department;
  final String semesterId;
  final String departmentId;

  const DepartmentListItem({
    super.key,
    required this.department,
    required this.semesterId,
    required this.departmentId,
  });

  @override
  Widget build(BuildContext context) {
    final data = department.data() as Map<String, dynamic>;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.success.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CourseScreen(
                    semesterId: semesterId,
                    departmentId: departmentId,
                  ),
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
                  color: context.colors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.school_outlined,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: context.textStyles.body1.textPrimary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Department',
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
