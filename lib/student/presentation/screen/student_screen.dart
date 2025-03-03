import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/login/presentation/screen/login_screen.dart';
import 'package:scheduler/student/presentation/component/semester_card.dart';
import 'package:scheduler/student/presentation/component/student_drawer.dart';
import 'package:scheduler/student/presentation/screen/student_semester_screen.dart';

class StudentScreen extends StatefulWidget {
  static const route = '/student';
  static const routeName = 'student';

  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!state.authenticated) {
          context.pushReplacementNamed(LoginScreen.routeName);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: context.colors.textPrimary),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(
            'Semesters',
            style: context.textStyles.heading3.textPrimary,
          ),
        ),
        drawer: const StudentDrawer(),
        body: FirestoreListView<Map<String, dynamic>>(
          query: FirebaseFirestore.instance
              .collection('semesters')
              .orderBy('year', descending: true)
              .orderBy('semester'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          emptyBuilder:
              (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: context.colors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No semesters available',
                      style: context.textStyles.subtitle1.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait for admin to create semesters',
                      style: context.textStyles.body2.textSecondary,
                    ),
                  ],
                ),
              ),
          errorBuilder:
              (context, error, _) => Center(
                child: Text(
                  'Error: $error',
                  style: context.textStyles.body1.error,
                ),
              ),
          loadingBuilder:
              (context) => Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              ),
          itemBuilder: (context, snapshot) {
            final data = snapshot.data();
            return SemesterCard(
              semester: data,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            StudentSemesterScreen(semesterId: snapshot.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
