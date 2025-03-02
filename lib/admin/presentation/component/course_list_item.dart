import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/admin/presentation/screen/schedule_screen.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class CourseListItem extends StatelessWidget {
  final QueryDocumentSnapshot course;
  final String courseId;
  final String semesterId;
  final String departmentId;

  const CourseListItem({
    super.key,
    required this.course,
    required this.courseId,
    required this.semesterId,
    required this.departmentId,
  });

  @override
  Widget build(BuildContext context) {
    final data = course.data() as Map<String, dynamic>;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to add schedule screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ScheduleScreen(
                    courseId: courseId,
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
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${data['year']}${data['section']}',
                    style: context.textStyles.heading3.baseStyle.copyWith(
                      color: Colors.purple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${data['code']}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
