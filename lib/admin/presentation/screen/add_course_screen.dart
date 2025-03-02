import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class AddCourseScreen extends HookWidget {
  const AddCourseScreen({
    super.key,
    required this.semesterId,
    required this.departmentId,
  });

  final String semesterId;
  final String departmentId;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final codeController = useTextEditingController();
    final yearController = useTextEditingController();
    final sectionController = useTextEditingController();

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        // Check if the course already exists
        final courseRef = FirebaseFirestore.instance
            .collection('courses')
            .where('semesterId', isEqualTo: semesterId)
            .where('departmentId', isEqualTo: departmentId)
            .where('code', isEqualTo: codeController.text.trim())
            .where('year', isEqualTo: yearController.text.trim())
            .where('section', isEqualTo: sectionController.text.trim());

        final courseSnapshot = await courseRef.get();

        if (courseSnapshot.docs.isNotEmpty) {
          showToast('Error', 'Course already exists', ToastificationType.error);
          return;
        }

        await FirebaseFirestore.instance.collection('courses').add({
          'code': codeController.text.trim(),
          'year': yearController.text.trim(),
          'section': sectionController.text.trim(),
          'semesterId': semesterId,
          'departmentId': departmentId,
        });

        if (context.mounted) {
          showToast(
            'Course Added',
            'Course added successfully',
            ToastificationType.success,
          );

          Navigator.pop(context);
        }
      } catch (e) {
        showToast('Error', 'Error adding course', ToastificationType.error);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Course',
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
                        'Enter course details',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      const SizedBox(height: 24),
                      PrimaryTextField(
                        controller: codeController,
                        labelText: 'Code',
                        hintText: 'BSCS',
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Code is required';
                          }
                          if (value.trim().isEmpty) {
                            return 'Code cannot be only whitespace';
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'Only letters and spaces are allowed';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      PrimaryTextField(
                        controller: yearController,
                        labelText: 'Year',
                        hintText: '1, 2, 3, etc',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Year is required';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[1-9]')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      PrimaryTextField(
                        controller: sectionController,
                        labelText: 'Section',
                        hintText: 'A',
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Section is required';
                          }
                          if (value.trim().isEmpty) {
                            return 'Section cannot be only whitespace';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                        ],
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
