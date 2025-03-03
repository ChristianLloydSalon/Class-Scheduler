import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/student/presentation/component/exam_card.dart';

class StudentExamTab extends StatelessWidget {
  final String semesterId;

  const StudentExamTab({super.key, required this.semesterId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // First get the student's enrolled courses for this semester
    final enrollmentsQuery = FirebaseFirestore.instance
        .collection('class_students')
        .where('studentId', isEqualTo: userId)
        .where('semesterId', isEqualTo: semesterId);

    return FirestoreListView<Map<String, dynamic>>(
      query: enrollmentsQuery,
      emptyBuilder:
          (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: context.colors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No exam schedules found',
                  style: context.textStyles.subtitle1.textPrimary,
                ),
              ],
            ),
          ),
      errorBuilder:
          (context, error, _) => Center(
            child: Text('Error: $error', style: context.textStyles.body1.error),
          ),
      loadingBuilder:
          (context) => Center(
            child: CircularProgressIndicator(color: context.colors.primary),
          ),
      itemBuilder: (context, enrollmentSnapshot) {
        final enrollmentData = enrollmentSnapshot.data();
        final courseId = enrollmentData['courseId'] as String;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('exam_schedules')
                  .where('courseId', isEqualTo: courseId)
                  .where('semesterId', isEqualTo: semesterId)
                  .orderBy('date')
                  .snapshots(),
          builder: (context, examSnapshot) {
            if (!examSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final exams = examSnapshot.data?.docs ?? [];
            if (exams.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children:
                  exams.map((exam) {
                    final data = exam.data() as Map<String, dynamic>;
                    return ExamCard(exam: data);
                  }).toList(),
            );
          },
        );
      },
    );
  }
}
