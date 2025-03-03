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
        appBar: FacultyAppBar(title: 'Semesters'),
        drawer: const FacultyDrawer(currentRoute: route),
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
                      'Academic Semesters',
                      style: context.textStyles.heading1.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a semester to view and manage your assigned courses',
                      style: context.textStyles.body2.textSecondary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FirestoreListView<Map<String, dynamic>>(
                  query: semestersQuery,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, snapshot) {
                    final semester = snapshot.data();
                    semester['id'] = snapshot.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SemesterCard(
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
                      ),
                    );
                  },
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
                              'Loading semesters...',
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
                                'Unable to Load Semesters',
                                style: context.textStyles.subtitle1.error,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'We encountered an error while loading the semesters. Please try again.',
                                style: context.textStyles.body2.textSecondary,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  emptyBuilder: (context) => const EmptySemesterView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
