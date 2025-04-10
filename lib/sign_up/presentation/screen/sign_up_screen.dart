import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/faculty/presentation/screen/faculty_screen.dart';
import 'package:scheduler/student/presentation/screen/student_screen.dart';
import 'package:toastification/toastification.dart';

enum RegisterType {
  none,
  student,
  faculty;

  bool get isStudent => this == student;
  bool get isFaculty => this == faculty;
}

class SignUpScreen extends HookWidget {
  const SignUpScreen({super.key, required this.registerType});

  final RegisterType registerType;

  static const route = '/sign-up';
  static const routeName = 'sign-up';

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final idController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    // Student-specific fields
    final selectedCourse = useState<String?>(null);
    final selectedYear = useState<int?>(1);
    final selectedSection = useState<String?>("A");

    // Fetch course codes from Firestore
    final courseCodes = useState<List<String>>([]);
    final isLoadingCourses = useState(true);

    useEffect(() {
      if (registerType.isStudent) {
        FirebaseFirestore.instance
            .collection('course_code')
            .get()
            .then((snapshot) {
              final codes =
                  snapshot.docs
                      .map((doc) => doc.data()['code'] as String)
                      .toList();
              courseCodes.value = codes;
              isLoadingCourses.value = false;
              if (codes.isNotEmpty) {
                selectedCourse.value = codes[0];
              }
            })
            .catchError((error) {
              isLoadingCourses.value = false;
              showToast(
                'Error',
                'Failed to load courses: $error',
                ToastificationType.error,
              );
            });
      }
      return null;
    }, []);

    void handleSignUp() {
      if (formKey.currentState?.validate() ?? false) {
        // Validate student-specific fields
        if (registerType.isStudent) {
          if (selectedCourse.value == null) {
            showToast(
              'Error',
              'Please select a course',
              ToastificationType.error,
            );
            return;
          }
          if (selectedYear.value == null) {
            showToast(
              'Error',
              'Please select a year level',
              ToastificationType.error,
            );
            return;
          }
          if (selectedSection.value == null) {
            showToast(
              'Error',
              'Please select a section',
              ToastificationType.error,
            );
            return;
          }
        }

        context.read<AuthBloc>().add(
          AuthSignUpEvent(
            name: nameController.text,
            id: idController.text,
            email: emailController.text,
            password: passwordController.text,
            role: registerType.isFaculty ? UserRole.faculty : UserRole.student,
            course: registerType.isStudent ? selectedCourse.value : null,
            yearLevel: registerType.isStudent ? selectedYear.value : null,
            section: registerType.isStudent ? selectedSection.value : null,
          ),
        );
      }
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.authenticated) {
          showToast(
            'Success',
            'Account created successfully',
            ToastificationType.success,
          );

          if (registerType.isFaculty) {
            context.pushReplacementNamed(FacultyScreen.routeName);
          } else {
            context.pushReplacementNamed(StudentScreen.routeName);
          }

          return;
        }

        if (state.errorMessage != null) {
          showToast(
            'Error',
            state.errorMessage ?? 'An unknown error occurred',
            ToastificationType.error,
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            40,
            24,
            40 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              const _Header(),
              const SizedBox(height: 40),
              _FormSection(
                formKey: formKey,
                nameController: nameController,
                idController: idController,
                emailController: emailController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                registerType: registerType,
                selectedCourse: selectedCourse,
                selectedYear: selectedYear,
                selectedSection: selectedSection,
                courseCodes: courseCodes.value,
                isLoadingCourses: isLoadingCourses.value,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                width: double.infinity,
                onPressed: handleSignUp,
                text: 'Sign Up',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign Up', style: context.textStyles.heading1.textPrimary),
            Text(
              'Create an account to get started',
              style: context.textStyles.subtitle2.textPrimary,
            ),
          ],
        ),
        const SizedBox(width: 16),
        context.icons.logo,
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.formKey,
    required this.nameController,
    required this.idController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.registerType,
    required this.selectedCourse,
    required this.selectedYear,
    required this.selectedSection,
    required this.courseCodes,
    required this.isLoadingCourses,
  });

  final Key formKey;
  final TextEditingController nameController;
  final TextEditingController idController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final RegisterType registerType;
  final ValueNotifier<String?> selectedCourse;
  final ValueNotifier<int?> selectedYear;
  final ValueNotifier<String?> selectedSection;
  final List<String> courseCodes;
  final bool isLoadingCourses;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You must be pre-registered by an administrator to create an account. Please enter your university ID as registered.',
                    style: context.textStyles.body2.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryTextField(
            labelText: 'Name',
            controller: nameController,
            hintText: 'John Doe',
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          PrimaryTextField(
            labelText: 'ID',
            controller: idController,
            hintText: '123456',
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ID is required';
              }
              if (value.length != 6) {
                return 'ID must be 6 digits';
              }
              return null;
            },
          ),
          PrimaryTextField(
            labelText: 'Email',
            controller: emailController,
            hintText: 'email.@bisu.edu.ph',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Invalid email';
              }
              if (!value.endsWith('@bisu.edu.ph')) {
                return 'Email must end with @bisu.edu.ph';
              }
              return null;
            },
          ),

          // Student-specific fields
          if (registerType.isStudent) ...[
            const SizedBox(height: 16),
            Text(
              'Student Information',
              style: context.textStyles.subtitle1.textPrimary,
            ),
            const SizedBox(height: 8),

            // Course dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child:
                  isLoadingCourses
                      ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select Course'),
                          value: selectedCourse.value,
                          items:
                              courseCodes.map((code) {
                                return DropdownMenuItem(
                                  value: code,
                                  child: Text(code),
                                );
                              }).toList(),
                          onChanged: (value) {
                            selectedCourse.value = value;
                          },
                        ),
                      ),
            ),

            const SizedBox(height: 16),

            // Year level dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select Year Level'),
                  value: selectedYear.value,
                  items:
                      [1, 2, 3, 4].map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text('Year $year'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    selectedYear.value = value;
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select Section'),
                  value: selectedSection.value,
                  items:
                      ['A', 'B', 'C', 'D', 'E'].map((section) {
                        return DropdownMenuItem(
                          value: section,
                          child: Text('Section $section'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    selectedSection.value = value;
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          PrimaryTextField(
            labelText: 'Password',
            controller: passwordController,
            hintText: 'Create a password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value != confirmPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          PrimaryTextField(
            controller: confirmPasswordController,
            hintText: 'Confirm password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm password is required';
              }
              if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
