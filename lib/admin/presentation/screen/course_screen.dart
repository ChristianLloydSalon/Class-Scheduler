import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/admin/presentation/component/course_list.dart';
import 'package:scheduler/admin/presentation/screen/add_course_screen.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class CourseScreen extends HookWidget {
  const CourseScreen({
    super.key,
    required this.semesterId,
    required this.departmentId,
  });

  final String semesterId;
  final String departmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses',
          style: context.textStyles.heading3.textPrimary.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Expanded(
              child: CourseList(
                semesterId: semesterId,
                departmentId: departmentId,
              ),
            ),
            PrimaryButton(
              width: double.infinity,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddCourseScreen(
                          semesterId: semesterId,
                          departmentId: departmentId,
                        ),
                  ),
                );
              },
              text: 'Add Course',
            ),
          ],
        ),
      ),
    );
  }
}
