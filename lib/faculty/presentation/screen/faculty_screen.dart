import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/login/presentation/screen/login_screen.dart';
import '../component/faculty_app_bar.dart';
import '../component/faculty_drawer.dart';
import '../component/semester/semester_card.dart';
import '../component/semester/empty_semester_view.dart';
import '../../../../common/theme/app_theme.dart';
import 'faculty_courses_screen.dart';

class FacultyScreen extends HookWidget {
  const FacultyScreen({super.key});

  static const route = '/faculty';
  static const routeName = 'faculty';

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = useState(GlobalKey<ScaffoldState>());
    final semestersQuery = FirebaseFirestore.instance.collection('semesters');

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!state.authenticated) {
          context.pushReplacementNamed(LoginScreen.routeName);
        }
      },
      child: Scaffold(
        key: scaffoldKey.value,
        backgroundColor: context.colors.background,
        appBar: FacultyAppBar(
          title: 'Semesters',
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: context.colors.textPrimary),
              onPressed: () {
                // Implement search functionality
              },
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: context.colors.textPrimary,
              ),
              onPressed: () {
                // Implement notifications
              },
            ),
          ],
        ),
        drawer: const FacultyDrawer(currentRoute: route),
        body: SafeArea(
          child: FirestoreListView<Map<String, dynamic>>(
            query: semestersQuery,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, snapshot) {
              final semester = snapshot.data();
              semester['id'] = snapshot.id;

              return SemesterCard(
                semester: semester,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FacultyCoursesScreen(
                              semesterId: semester['id'] as String,
                              semesterName:
                                  'Semester ${semester['semester']}, Year ${semester['year']}',
                            ),
                      ),
                    ),
              );
            },
            loadingBuilder:
                (context) => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
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
                          color: context.colors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading semesters',
                          style: context.textStyles.subtitle1.error,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: context.textStyles.body2.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            // Force refresh
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            foregroundColor: context.colors.surface,
                          ),
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'Retry',
                            style: context.textStyles.body2.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            emptyBuilder: (context) => const EmptySemesterView(),
          ),
        ),
      ),
    );
  }
}
