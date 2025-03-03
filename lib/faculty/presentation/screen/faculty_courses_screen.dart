import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import '../component/faculty_app_bar.dart';
import '../component/faculty_drawer.dart';
import '../component/course/course_card.dart';
import '../component/course/empty_course_view.dart';
import 'faculty_course_schedules_screen.dart';

class FacultyCoursesScreen extends HookWidget {
  final String semesterId;
  final String semesterName;

  const FacultyCoursesScreen({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = useState(GlobalKey<ScaffoldState>());
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final schedulesQuery = FirebaseFirestore.instance
        .collection('schedules')
        .where('semesterId', isEqualTo: semesterId)
        .where('teacherId', isEqualTo: userId);

    return Scaffold(
      key: scaffoldKey.value,
      backgroundColor: context.colors.background,
      appBar: FacultyAppBar(title: semesterName, showBackButton: true),
      drawer: const FacultyDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  bottom: BorderSide(color: context.colors.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Courses',
                    style: context.textStyles.heading1.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your classes, schedules, and student records for $semesterName',
                    style: context.textStyles.body2.textSecondary,
                  ),
                ],
              ),
            ),
            if (userId == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 64,
                        color: context.colors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authentication Required',
                        style: context.textStyles.subtitle1.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You need to be logged in to view courses',
                        style: context.textStyles.body2.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          // Handle login or navigation
                        },
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: FirestoreListView<Map<String, dynamic>>(
                  query: schedulesQuery,
                  padding: const EdgeInsets.all(16),
                  loadingBuilder:
                      (context) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: context.colors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading your courses...',
                              style: context.textStyles.body2.textSecondary,
                            ),
                          ],
                        ),
                      ),
                  errorBuilder:
                      (context, error, stackTrace) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 64,
                                color: context.colors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Unable to Load Courses',
                                style: context.textStyles.subtitle1.error,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'We encountered an error while loading your courses. Please try again.',
                                style: context.textStyles.body2.textSecondary,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  emptyBuilder:
                      (context) => EmptyCourseView(
                        message:
                            'No courses assigned for $semesterName\n\nOnce courses are assigned to you, they will appear here.',
                      ),
                  itemBuilder: (context, snapshot) {
                    final scheduleData = snapshot.data();
                    final courseId = scheduleData['courseId'] as String?;

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('courses')
                              .doc(courseId)
                              .get(),
                      builder: (context, courseSnapshot) {
                        if (courseSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              height: 100,
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                          );
                        }

                        if (!courseSnapshot.hasData ||
                            courseSnapshot.data == null) {
                          return const SizedBox();
                        }

                        final courseData =
                            courseSnapshot.data!.data()
                                as Map<String, dynamic>?;
                        if (courseData == null) return const SizedBox();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CourseCard(
                            id: courseId ?? '',
                            code: courseData['code'] ?? '',
                            name:
                                '${courseData['code']} ${courseData['year']}-${courseData['section']}',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => FacultyCourseSchedulesScreen(
                                        semesterId: semesterId,
                                        courseId: courseId ?? '',
                                        courseName:
                                            '${courseData['code']} ${courseData['year']}-${courseData['section']}',
                                        courseCode: courseData['code'] ?? '',
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
