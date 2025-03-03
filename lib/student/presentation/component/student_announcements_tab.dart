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

    return FirestoreListView<Map<String, dynamic>>(
      query: enrollmentsQuery,
      emptyBuilder:
          (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 64,
                  color: context.colors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No announcements found',
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
                  .collection('announcements')
                  .where('courseId', isEqualTo: courseId)
                  .where('semesterId', isEqualTo: semesterId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
          builder: (context, announcementSnapshot) {
            if (!announcementSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final announcements = announcementSnapshot.data?.docs ?? [];
            if (announcements.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children:
                  announcements.map((announcement) {
                    final data = announcement.data() as Map<String, dynamic>;
                    return AnnouncementCard(announcement: data);
                  }).toList(),
            );
          },
        );
      },
    );
  }
}
