import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scheduler/admin/presentation/screen/semester_screen.dart';
import 'package:scheduler/admin/presentation/screen/academic_resources_screen.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';

class AdminScreensProvider extends StatelessWidget {
  final int selectedIndex;

  const AdminScreensProvider({super.key, required this.selectedIndex});

  static final List<Widget> _screens = const [
    SemesterScreen(),
    AcademicResourcesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.role.isAdmin) {
          return IndexedStack(index: selectedIndex, children: _screens);
        }

        if (state.role.isRegistrar) {
          return AcademicResourcesScreen();
        }

        return const SizedBox.shrink();
      },
    );
  }
}
