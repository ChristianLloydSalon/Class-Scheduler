import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/student/presentation/component/announcement_card.dart';

class StudentAnnouncementsTab extends StatelessWidget {
  final String semesterId;

  const StudentAnnouncementsTab({super.key, required this.semesterId});

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

        // Query announcements for all enrolled courses
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('announcements')
                  .where('courseId', whereIn: courseIds)
                  .where('semesterId', isEqualTo: semesterId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
          builder: (context, announcementsSnapshot) {
            if (announcementsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              );
            }

            if (announcementsSnapshot.hasError) {
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
                      'Error loading announcements',
                      style: context.textStyles.body1.error,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcementsSnapshot.error.toString(),
                      style: context.textStyles.caption1.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final announcements = announcementsSnapshot.data?.docs ?? [];

            if (announcements.isEmpty) {
              return _buildEmptyState(
                context,
                'No announcements',
                'There are no announcements for your enrolled courses',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcementData =
                    announcements[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnnouncementCard(announcement: announcementData),
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
              Icons.campaign_outlined,
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
