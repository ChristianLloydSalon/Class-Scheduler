import 'package:flutter/material.dart';
import 'package:scheduler/admin/presentation/screen/semester_screen.dart';
import 'package:scheduler/admin/presentation/screen/academic_resources_screen.dart';

class AdminScreensProvider extends StatelessWidget {
  final int selectedIndex;

  const AdminScreensProvider({super.key, required this.selectedIndex});

  static final List<Widget> _screens = const [
    SemesterScreen(),
    AcademicResourcesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: selectedIndex, children: _screens);
  }
}
