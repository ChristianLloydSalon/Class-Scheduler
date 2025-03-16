import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/student/presentation/component/student_announcements_tab.dart';
import 'package:scheduler/student/presentation/component/student_exam_tab.dart';
import 'package:scheduler/student/presentation/component/student_schedule_tab.dart';

class StudentSemesterScreen extends StatelessWidget {
  final String semesterId;

  const StudentSemesterScreen({super.key, required this.semesterId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('semesters')
                  .doc(semesterId)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;
            return Text(
              data?['name'] ?? 'Semester Details',
              style: context.textStyles.heading3.textPrimary,
            );
          },
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: context.colors.surface,
              child: TabBar(
                labelStyle: context.textStyles.body1.regular,
                unselectedLabelStyle: context.textStyles.body2.regular,
                labelColor: colorScheme.primary,
                unselectedLabelColor: context.colors.textSecondary,
                indicatorColor: colorScheme.primary,
                tabs: const [
                  Tab(text: 'Schedule'),
                  Tab(text: 'Exams'),
                  Tab(text: 'Announcements'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StudentScheduleTab(semesterId: semesterId),
                  StudentExamTab(semesterId: semesterId),
                  StudentAnnouncementsTab(semesterId: semesterId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
