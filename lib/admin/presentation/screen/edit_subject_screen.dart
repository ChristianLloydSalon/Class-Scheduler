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

    // State for related data
    final isLoadingSemester = useState<bool>(true);
    final isLoadingDepartment = useState<bool>(true);
    final isLoadingCourse = useState<bool>(true);

    final semesterData = useState<Map<String, dynamic>?>(null);
    final departmentData = useState<Map<String, dynamic>?>(null);
    final courseData = useState<Map<String, dynamic>?>(null);

    // Fetch semester data
    useEffect(() {
      final semesterId = subjectData['semesterId'];
      if (semesterId == null) {
        isLoadingSemester.value = false;
        return null;
      }

      FirebaseFirestore.instance
          .collection('semesters')
          .doc(semesterId)
          .get()
          .then((doc) {
            if (doc.exists) {
              semesterData.value = doc.data();
            }
            isLoadingSemester.value = false;
          })
          .catchError((error) {
            isLoadingSemester.value = false;
          });

      return null;
    }, []);

    // Fetch department data
    useEffect(() {
      final departmentId = subjectData['departmentId'];
      if (departmentId == null) {
        isLoadingDepartment.value = false;
        return null;
      }

      FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentId)
          .get()
          .then((doc) {
            if (doc.exists) {
              departmentData.value = doc.data();
            }
            isLoadingDepartment.value = false;
          })
          .catchError((error) {
            isLoadingDepartment.value = false;
          });

      return null;
    }, []);

    // Fetch course data
    useEffect(() {
      final courseId = subjectData['courseId'];
      if (courseId == null) {
        isLoadingCourse.value = false;
        return null;
      }

      FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get()
          .then((doc) {
            if (doc.exists) {
              courseData.value = doc.data();
            }
            isLoadingCourse.value = false;
          })
          .catchError((error) {
            isLoadingCourse.value = false;
          });

      return null;
    }, []);

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
              // Not updating semesterId, departmentId, courseId or yearLevel
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

    // Helper function to build info containers
    Widget _buildInfoContainer(String label, String value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: context.textStyles.body1.textPrimary),
              const SizedBox(width: 4),
              Icon(
                Icons.lock_outline,
                size: 14,
                color: context.colors.textHint,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.border),
              borderRadius: BorderRadius.circular(8),
              color: context.colors.background.withOpacity(0.6),
            ),
            child: Text(value, style: context.textStyles.body1.textPrimary),
          ),
        ],
      );
    }

    // Helper function to build loading/placeholder containers
    Widget _buildLoadingContainer(
      String label,
      bool isLoading,
      String placeholder,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: context.textStyles.body1.textPrimary),
              const SizedBox(width: 4),
              Icon(
                Icons.lock_outline,
                size: 14,
                color: context.colors.textHint,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading...',
                    style: context.textStyles.body2.textSecondary,
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.border),
                borderRadius: BorderRadius.circular(8),
                color: context.colors.background,
              ),
              child: Text(
                placeholder,
                style: context.textStyles.body2.textSecondary,
              ),
            ),
        ],
      );
    }

    String getSemesterText() {
      if (semesterData.value == null) return 'Not assigned';
      return 'Year ${semesterData.value?['year']} - Semester ${semesterData.value?['semester']}';
    }

    String getDepartmentText() {
      if (departmentData.value == null) return 'Not assigned';
      return departmentData.value?['name'] ?? 'Unknown';
    }

    String getCourseText() {
      if (courseData.value == null) return 'Not assigned';
      final code = courseData.value?['code'] ?? '';
      final year = courseData.value?['year'] ?? '';
      final section = courseData.value?['section'] ?? '';
      return '$code - Year $year Section $section';
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

                      // Notice about non-editable fields
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: context.colors.textHint.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: context.colors.textHint.withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: context.colors.textHint,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The semester, department, and course assignments cannot be edited. Please create a new subject if you need to change these associations.',
                                style:
                                    context.textStyles.caption1.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Display semester information (read-only)
                      isLoadingSemester.value
                          ? _buildLoadingContainer('Semester', true, '')
                          : _buildInfoContainer('Semester', getSemesterText()),
                      const SizedBox(height: 16),

                      // Display department information (read-only)
                      isLoadingDepartment.value
                          ? _buildLoadingContainer('Department', true, '')
                          : _buildInfoContainer(
                            'Department',
                            getDepartmentText(),
                          ),
                      const SizedBox(height: 16),

                      // Display course information (read-only)
                      isLoadingCourse.value
                          ? _buildLoadingContainer('Course', true, '')
                          : _buildInfoContainer('Course', getCourseText()),
                      const SizedBox(height: 16),

                      // Editable fields
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
