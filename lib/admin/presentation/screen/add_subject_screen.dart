import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class AddSubjectScreen extends HookWidget {
  const AddSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final codeController = useTextEditingController();
    final titleController = useTextEditingController();
    final labUnitsController = useTextEditingController();
    final lecUnitsController = useTextEditingController();

    // State variables for new dropdown selections
    final selectedSemesterId = useState<String?>(null);
    final selectedCourseId = useState<String?>(null);
    final selectedDepartmentId = useState<String?>(null);

    // Loading states
    final isLoadingSemesters = useState<bool>(true);
    final isLoadingCourses = useState<bool>(true);
    final isLoadingDepartments = useState<bool>(true);

    // Data states
    final semesters = useState<List<Map<String, dynamic>>>([]);
    final courses = useState<List<Map<String, dynamic>>>([]);
    final departments = useState<List<Map<String, dynamic>>>([]);

    // Year level options
    final yearLevelOptions = [1, 2, 3, 4];

    // Fetch semesters from Firestore
    useEffect(() {
      isLoadingSemesters.value = true;
      FirebaseFirestore.instance
          .collection('semesters')
          .get()
          .then((snapshot) {
            semesters.value =
                snapshot.docs
                    .map((doc) => {'id': doc.id, ...doc.data()})
                    .toList();
            isLoadingSemesters.value = false;
          })
          .catchError((error) {
            isLoadingSemesters.value = false;
            showToast(
              'Error',
              'Failed to load semesters',
              ToastificationType.error,
            );
          });
      return null;
    }, []);

    // Fetch courses for selected semester and department
    useEffect(() {
      if (selectedSemesterId.value == null ||
          selectedDepartmentId.value == null) {
        courses.value = [];
        isLoadingCourses.value = false;
        selectedCourseId.value = null;
        return null;
      }

      isLoadingCourses.value = true;
      FirebaseFirestore.instance
          .collection('courses')
          .where('semesterId', isEqualTo: selectedSemesterId.value)
          .where('departmentId', isEqualTo: selectedDepartmentId.value)
          .get()
          .then((snapshot) {
            courses.value =
                snapshot.docs
                    .map((doc) => {'id': doc.id, ...doc.data()})
                    .toList();
            isLoadingCourses.value = false;
            selectedCourseId.value =
                null; // Reset course selection when new results come in
          })
          .catchError((error) {
            isLoadingCourses.value = false;
            showToast(
              'Error',
              'Failed to load courses',
              ToastificationType.error,
            );
          });

      return null;
    }, [selectedSemesterId.value, selectedDepartmentId.value]);

    // Fetch departments for selected semester
    useEffect(() {
      if (selectedSemesterId.value == null) {
        departments.value = [];
        isLoadingDepartments.value = false;
        return null;
      }

      isLoadingDepartments.value = true;
      FirebaseFirestore.instance
          .collection('departments')
          .where('semesterId', isEqualTo: selectedSemesterId.value)
          .get()
          .then((snapshot) {
            departments.value =
                snapshot.docs
                    .map((doc) => {'id': doc.id, ...doc.data()})
                    .toList();
            isLoadingDepartments.value = false;
          })
          .catchError((error) {
            isLoadingDepartments.value = false;
            showToast(
              'Error',
              'Failed to load departments',
              ToastificationType.error,
            );
          });

      return null;
    }, [selectedSemesterId.value]);

    // When semester changes, reset department and course selections
    useEffect(() {
      selectedDepartmentId.value = null;
      selectedCourseId.value = null;
      return null;
    }, [selectedSemesterId.value]);

    // Get currently selected course
    Map<String, dynamic>? getSelectedCourse() {
      if (selectedCourseId.value == null) return null;
      return courses.value.firstWhere(
        (course) => course['id'] == selectedCourseId.value,
        orElse: () => <String, dynamic>{},
      );
    }

    Future<bool> isCodeExists(String code) async {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('subjects')
              .where('code', isEqualTo: code.toUpperCase())
              .get();
      return snapshot.docs.isNotEmpty;
    }

    Future<void> handleSubmit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      // Check if semester and course are selected
      if (selectedSemesterId.value == null) {
        showToast(
          'Error',
          'Please select a semester',
          ToastificationType.error,
        );
        return;
      }

      if (selectedCourseId.value == null) {
        showToast('Error', 'Please select a course', ToastificationType.error);
        return;
      }

      if (selectedDepartmentId.value == null) {
        showToast(
          'Error',
          'Please select a department',
          ToastificationType.error,
        );
        return;
      }

      try {
        final code = codeController.text.trim().toUpperCase();
        if (await isCodeExists(code)) {
          if (!context.mounted) return;
          showToast(
            'Error',
            'Subject code already exists',
            ToastificationType.error,
          );
          return;
        }

        // Get the selected course to extract year
        final selectedCourse = getSelectedCourse();
        final courseYear = selectedCourse?['year'] ?? '1';

        // Add new fields to the subject document
        await FirebaseFirestore.instance.collection('subjects').add({
          'code': code,
          'title': titleController.text.trim(),
          'units': {
            'lab': int.parse(labUnitsController.text.trim()),
            'lec': int.parse(lecUnitsController.text.trim()),
          },
          'title_search': titleController.text.trim().toLowerCase(),
          'semesterId': selectedSemesterId.value,
          'courseId': selectedCourseId.value,
          'departmentId': selectedDepartmentId.value,
          'yearLevel': courseYear,
        });

        if (!context.mounted) return;
        showToast(
          'Success',
          'Subject added successfully',
          ToastificationType.success,
        );
        Navigator.pop(context);
      } catch (e) {
        showToast('Error', 'Failed to add subject', ToastificationType.error);
      }
    }

    // Check if we can enable the submit button
    bool canSubmit() {
      return semesters.value.isNotEmpty &&
          courses.value.isNotEmpty &&
          departments.value.isNotEmpty &&
          selectedSemesterId.value != null &&
          selectedCourseId.value != null &&
          selectedDepartmentId.value != null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Subject',
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
                        'Create a new subject',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      const SizedBox(height: 24),

                      // Semester Selection
                      Text(
                        'Semester',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingSemesters.value)
                        Center(
                          child: CircularProgressIndicator(
                            color: context.colors.primary,
                          ),
                        )
                      else if (semesters.value.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.error),
                            borderRadius: BorderRadius.circular(8),
                            color: context.colors.error.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: context.colors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No semesters available. Please add a semester first.',
                                  style: context.textStyles.body2.error,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedSemesterId.value,
                              hint: Text(
                                'Select Semester',
                                style: context.textStyles.body1.textSecondary,
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              style: context.textStyles.body1.textPrimary,
                              onChanged: (String? value) {
                                if (value != null) {
                                  selectedSemesterId.value = value;
                                  selectedCourseId.value =
                                      null; // Reset course selection
                                }
                              },
                              items:
                                  semesters.value.map<
                                    DropdownMenuItem<String>
                                  >((Map<String, dynamic> semester) {
                                    return DropdownMenuItem<String>(
                                      value: semester['id'],
                                      child: Text(
                                        'Year ${semester['year']} - Semester ${semester['semester']}',
                                        style:
                                            context
                                                .textStyles
                                                .body1
                                                .textPrimary,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Department Selection
                      Text(
                        'Department',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      if (selectedSemesterId.value == null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(8),
                            color: context.colors.background,
                          ),
                          child: Text(
                            'Select a semester first',
                            style: context.textStyles.body2.textSecondary,
                          ),
                        )
                      else if (isLoadingDepartments.value)
                        Center(
                          child: CircularProgressIndicator(
                            color: context.colors.primary,
                          ),
                        )
                      else if (departments.value.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.error),
                            borderRadius: BorderRadius.circular(8),
                            color: context.colors.error.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: context.colors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No departments available for this semester. Please add a department first.',
                                  style: context.textStyles.body2.error,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedDepartmentId.value,
                              hint: Text(
                                'Select Department',
                                style: context.textStyles.body1.textSecondary,
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              style: context.textStyles.body1.textPrimary,
                              onChanged: (String? value) {
                                if (value != null) {
                                  selectedDepartmentId.value = value;
                                }
                              },
                              items:
                                  departments.value
                                      .map<DropdownMenuItem<String>>((
                                        Map<String, dynamic> department,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: department['id'],
                                          child: Text(
                                            department['name'],
                                            style:
                                                context
                                                    .textStyles
                                                    .body1
                                                    .textPrimary,
                                          ),
                                        );
                                      })
                                      .toList(),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Course Selection
                      Text(
                        'Course',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      if (selectedSemesterId.value == null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(8),
                            color: context.colors.background,
                          ),
                          child: Text(
                            'Select a semester first',
                            style: context.textStyles.body2.textSecondary,
                          ),
                        )
                      else if (selectedDepartmentId.value == null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(8),
                            color: context.colors.background,
                          ),
                          child: Text(
                            'Select a department first',
                            style: context.textStyles.body2.textSecondary,
                          ),
                        )
                      else if (isLoadingCourses.value)
                        Center(
                          child: CircularProgressIndicator(
                            color: context.colors.primary,
                          ),
                        )
                      else if (courses.value.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.error),
                            borderRadius: BorderRadius.circular(8),
                            color: context.colors.error.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: context.colors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No courses available for this semester. Please add a course first.',
                                  style: context.textStyles.body2.error,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedCourseId.value,
                              hint: Text(
                                'Select Course',
                                style: context.textStyles.body1.textSecondary,
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              style: context.textStyles.body1.textPrimary,
                              onChanged: (String? value) {
                                if (value != null) {
                                  selectedCourseId.value = value;
                                }
                              },
                              items:
                                  courses.value.map<DropdownMenuItem<String>>((
                                    Map<String, dynamic> course,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: course['id'],
                                      child: Text(
                                        '${course['code']} - Year ${course['year']} Section ${course['section']}',
                                        style:
                                            context
                                                .textStyles
                                                .body1
                                                .textPrimary,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

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
                    onPressed: () => handleSubmit(),
                    text: 'Add Subject',
                    state:
                        canSubmit()
                            ? PrimaryButtonState.idle
                            : PrimaryButtonState.disabled,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canSubmit()
                        ? 'Make sure all fields are filled correctly'
                        : 'You need to add semesters, courses, and departments before adding subjects',
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
