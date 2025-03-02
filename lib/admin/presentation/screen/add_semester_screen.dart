import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class AddSemesterScreen extends HookWidget {
  const AddSemesterScreen({super.key});

  static const route = '/admin/semester/add';
  static const routeName = 'add_semester';

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final yearController = useTextEditingController();
    final semesterController = useTextEditingController();

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        final year = int.parse(yearController.text);
        final semester = int.parse(semesterController.text);

        // Check if semester already exists
        final existingDoc =
            await FirebaseFirestore.instance
                .collection('semesters')
                .where('year', isEqualTo: year)
                .where('semester', isEqualTo: semester)
                .get();

        if (existingDoc.docs.isNotEmpty) {
          throw Exception('Semester already exists');
        }

        // Add new semester
        await FirebaseFirestore.instance.collection('semesters').add({
          'year': year,
          'semester': semester,
        });

        if (context.mounted) {
          showToast(
            'Semester Added',
            'Semester added successfully',
            ToastificationType.success,
          );

          Navigator.pop(context);
        }
      } catch (e) {
        Future(
          () => showToast(
            'Error',
            'Error: ${e.toString()}',
            ToastificationType.error,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Semester',
          style: context.textStyles.heading2.textPrimary,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter year and semester number',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      const SizedBox(height: 24),
                      PrimaryTextField(
                        controller: yearController,
                        labelText: 'Year',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Year is required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        controller: semesterController,
                        labelText: 'Semester',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Semester is required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid semester number';
                          }
                          final semester = int.parse(value);
                          if (semester < 1 || semester > 3) {
                            return 'Semester must be between 1 and 3';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    width: double.infinity,
                    onPressed: handleSubmit,
                    text: 'Confirm',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Make sure all fields are filled correctly',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
