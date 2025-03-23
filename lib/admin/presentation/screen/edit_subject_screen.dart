import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class EditSubjectScreen extends HookWidget {
  final String subjectId;
  final Map<String, dynamic> subjectData;

  const EditSubjectScreen({
    super.key,
    required this.subjectId,
    required this.subjectData,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final codeController = useTextEditingController(text: subjectData['code']);
    final titleController = useTextEditingController(
      text: subjectData['title'],
    );

    final units = subjectData['units'] as Map<String, dynamic>? ?? const {};
    final labUnitsController = useTextEditingController(
      text: units['lab']?.toString() ?? '0',
    );
    final lecUnitsController = useTextEditingController(
      text: units['lec']?.toString() ?? '0',
    );

    // Store original code to check if it changed during validation
    final originalCode = useState(subjectData['code']);

    Future<bool> isCodeExists(String code) async {
      if (code == originalCode.value) {
        // If code hasn't changed, no need to check
        return false;
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('subjects')
              .where('code', isEqualTo: code.toUpperCase())
              .get();
      return snapshot.docs.isNotEmpty;
    }

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        final code = codeController.text.trim().toUpperCase();

        if (code != originalCode.value && await isCodeExists(code)) {
          if (!context.mounted) return;
          showToast(
            'Error',
            'Subject code already exists',
            ToastificationType.error,
          );
          return;
        }

        await FirebaseFirestore.instance
            .collection('subjects')
            .doc(subjectId)
            .update({
              'code': code,
              'title': titleController.text.trim(),
              'units': {
                'lab': int.parse(labUnitsController.text.trim()),
                'lec': int.parse(lecUnitsController.text.trim()),
              },
              'title_search': titleController.text.trim().toLowerCase(),
            });

        if (!context.mounted) return;
        showToast(
          'Success',
          'Subject updated successfully',
          ToastificationType.success,
        );
        Navigator.pop(context);
      } catch (e) {
        showToast(
          'Error',
          'Failed to update subject',
          ToastificationType.error,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Subject',
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
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit subject details',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      const SizedBox(height: 24),
                      PrimaryTextField(
                        controller: titleController,
                        labelText: 'Subject Title',
                        hintText: 'Introduction to Computer Science',
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title is required';
                          }
                          if (value.trim().isEmpty) {
                            return 'Title cannot be only whitespace';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        controller: codeController,
                        labelText: 'Subject Code',
                        hintText: 'CS101',
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Code is required';
                          }
                          if (!RegExp(
                            r'^[A-Z0-9]+$',
                          ).hasMatch(value.toUpperCase())) {
                            return 'Code can only contain letters and numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Units',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryTextField(
                              controller: lecUnitsController,
                              labelText: 'Lecture',
                              hintText: '3',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final units = int.tryParse(value);
                                if (units == null || units < 0 || units > 6) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PrimaryTextField(
                              controller: labUnitsController,
                              labelText: 'Laboratory',
                              hintText: '1',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final units = int.tryParse(value);
                                if (units == null || units < 0 || units > 6) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
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
                    text: 'Update Subject',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure all fields are filled correctly',
                    style: context.textStyles.caption1.textSecondary,
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
