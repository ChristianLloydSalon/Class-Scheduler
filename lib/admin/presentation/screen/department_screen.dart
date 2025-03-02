import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/admin/presentation/component/department_list.dart';
import 'package:scheduler/admin/presentation/screen/add_department_screen.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class DepartmentScreen extends HookWidget {
  const DepartmentScreen({super.key, required this.semesterId});

  final String semesterId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Department',
          style: context.textStyles.heading3.textPrimary,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Expanded(child: DepartmentList(semesterId: semesterId)),
            PrimaryButton(
              width: double.infinity,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddDepartmentScreen(semesterId: semesterId),
                  ),
                );
              },
              text: 'Add Department',
            ),
          ],
        ),
      ),
    );
  }
}
