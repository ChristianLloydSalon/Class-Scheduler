import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
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
    final theme = Theme.of(context);
    final scaffoldKey = useState(GlobalKey<ScaffoldState>());
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Create a query for schedules where the current faculty is assigned
    final schedulesQuery = FirebaseFirestore.instance
        .collection('schedules')
        .where('semesterId', isEqualTo: semesterId)
        .where('teacherId', isEqualTo: userId);

    return Scaffold(
      key: scaffoldKey.value,
      backgroundColor: theme.colorScheme.background,
      appBar: FacultyAppBar(
        title: semesterName,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      drawer: const FacultyDrawer(),
      body: SafeArea(
        child:
            userId == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 60,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authentication Required',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You need to be logged in to view courses',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Handle login or navigation
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                )
                : FirestoreListView<Map<String, dynamic>>(
                  query: schedulesQuery,
                  padding: const EdgeInsets.all(16),
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
                          return const Card(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
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

                        return CourseCard(
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
                        );
                      },
                    );
                  },
                  loadingBuilder:
                      (context) => Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
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
                                Icons.error_outline,
                                size: 60,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading courses',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Force refresh
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  emptyBuilder:
                      (context) => const EmptyCourseView(
                        message: 'No courses assigned for this semester',
                      ),
                ),
      ),
    );
  }

  String _formatTime(Map<String, dynamic> time) {
    final hour = time['hour'] as int?;
    final minute = time['minute'] as int?;
    if (hour == null || minute == null) return '';

    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}
