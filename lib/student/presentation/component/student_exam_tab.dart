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

    return StreamBuilder<QuerySnapshot>(
      stream: enrollmentsQuery.snapshots(),
      builder: (context, enrollmentsSnapshot) {
        if (enrollmentsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: context.colors.primary),
          );
        }

        if (enrollmentsSnapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading enrollments',
                  style: context.textStyles.body1.error,
                ),
                const SizedBox(height: 8),
                Text(
                  enrollmentsSnapshot.error.toString(),
                  style: context.textStyles.caption1.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final enrollments = enrollmentsSnapshot.data?.docs ?? [];

        if (enrollments.isEmpty) {
          return _buildEmptyState(
            context,
            'No courses found',
            'You are not enrolled in any courses for this semester',
          );
        }

        // Get list of course IDs
        final courseIds =
            enrollments
                .map((doc) => doc.data() as Map<String, dynamic>)
                .map((data) => data['courseId'] as String)
                .toList();

        // Query exams for all enrolled courses
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('exam_schedules')
                  .where('courseId', whereIn: courseIds)
                  .where('semesterId', isEqualTo: semesterId)
                  .orderBy('date')
                  .snapshots(),
          builder: (context, examsSnapshot) {
            if (examsSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              );
            }

            if (examsSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: context.colors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading exam schedules',
                      style: context.textStyles.body1.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      examsSnapshot.error.toString(),
                      style: context.textStyles.caption1.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final exams = examsSnapshot.data?.docs ?? [];

            if (exams.isEmpty) {
              return _buildEmptyState(
                context,
                'No exams scheduled',
                'There are no upcoming exams for your enrolled courses',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final examData = exams[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ExamCard(exam: examData),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 72,
              color: context.colors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.textStyles.heading3.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: context.textStyles.body2.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
