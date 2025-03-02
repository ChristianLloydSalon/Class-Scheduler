import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/admin/presentation/screen/add_semester_screen.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import '../component/semester_list.dart';

class SemesterScreen extends HookWidget {
  const SemesterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Semester', style: context.textStyles.body1.textPrimary),
          const SizedBox(height: 16),
          const Expanded(child: SemesterList()),
          const SizedBox(height: 16),
          PrimaryButton(
            width: double.infinity,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSemesterScreen(),
                ),
              );
            },
            text: 'Add Semester',
          ),
        ],
      ),
    );
  }
}
