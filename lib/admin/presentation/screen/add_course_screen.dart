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
    final selectedYear = useState<int>(1);
    final selectedSection = useState<String>('A');

    // Define year and section options
    final yearOptions = [1, 2, 3, 4];
    final sectionOptions = ['A', 'B', 'C', 'D', 'E'];

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        // Check if the course already exists
        final courseRef = FirebaseFirestore.instance
            .collection('courses')
            .where('semesterId', isEqualTo: semesterId)
            .where('departmentId', isEqualTo: departmentId)
            .where('code', isEqualTo: codeController.text.trim())
            .where('year', isEqualTo: selectedYear.value.toString())
            .where('section', isEqualTo: selectedSection.value);

        final courseSnapshot = await courseRef.get();

        if (courseSnapshot.docs.isNotEmpty) {
          showToast('Error', 'Course already exists', ToastificationType.error);
          return;
        }

        final codeSnapshot =
            await FirebaseFirestore.instance
                .collection('course_code')
                .where('code', isEqualTo: codeController.text.trim())
                .get();

        if (codeSnapshot.docs.isEmpty) {
          /// Add course to the course_code collection
          await FirebaseFirestore.instance.collection('course_code').doc().set({
            'code': codeController.text.trim(),
          });
        }

        await FirebaseFirestore.instance.collection('courses').add({
          'code': codeController.text.trim(),
          'year': selectedYear.value.toString(),
          'section': selectedSection.value,
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
                      const SizedBox(height: 16),
                      Text('Year', style: context.textStyles.body1.textPrimary),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: selectedYear.value,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: context.textStyles.body1.textPrimary,
                            onChanged: (int? value) {
                              if (value != null) {
                                selectedYear.value = value;
                              }
                            },
                            items:
                                yearOptions.map<DropdownMenuItem<int>>((
                                  int value,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                      'Year $value',
                                      style:
                                          context.textStyles.body1.textPrimary,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Section',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedSection.value,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: context.textStyles.body1.textPrimary,
                            onChanged: (String? value) {
                              if (value != null) {
                                selectedSection.value = value;
                              }
                            },
                            items:
                                sectionOptions.map<DropdownMenuItem<String>>((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      'Section $value',
                                      style:
                                          context.textStyles.body1.textPrimary,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
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
