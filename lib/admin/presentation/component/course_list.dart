import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/admin/presentation/component/course_list_item.dart';
import 'package:scheduler/common/component/communication/empty_display.dart';
import 'package:scheduler/common/component/communication/error_display.dart';

class CourseList extends StatelessWidget {
  const CourseList({
    super.key,
    required this.semesterId,
    required this.departmentId,
  });

  final String semesterId;
  final String departmentId;

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('courses')
        .where('semesterId', isEqualTo: semesterId)
        .where('departmentId', isEqualTo: departmentId);

    return FirestoreListView<Map<String, dynamic>>(
      query: query,
      loadingBuilder:
          (context) => const Center(child: CircularProgressIndicator()),
      errorBuilder:
          (context, error, _) => ErrorDisplay(
            title: 'Something went wrong',
            subtitle: 'Please try again later',
          ),
      emptyBuilder:
          (context) => EmptyDisplay(
            title: 'No Courses Available',
            subtitle: 'Please add a course to get started',
          ),
      itemBuilder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CourseListItem(
            semesterId: semesterId,
            departmentId: departmentId,
            courseId: snapshot.id,
            course: snapshot,
          ),
        );
      },
    );
  }
}
