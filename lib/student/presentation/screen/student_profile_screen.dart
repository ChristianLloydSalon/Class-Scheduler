import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:toastification/toastification.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showChangePasswordDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Change Password',
              style: context.textStyles.subtitle1.textPrimary,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: context.textStyles.body2.textSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: context.textStyles.body2.textSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: context.textStyles.body2.textSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: context.textStyles.body1.textSecondary,
                ),
              ),
              FilledButton(
                onPressed: _isLoading ? null : _changePassword,
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: context.colors.surface,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Change Password',
                          style: context.textStyles.body1.surface,
                        ),
              ),
            ],
          ),
    );
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      showToast(
        'Error',
        'New passwords do not match',
        ToastificationType.error,
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      showToast(
        'Error',
        'Password must be at least 6 characters',
        ToastificationType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final credential = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: _currentPasswordController.text,
      );

      // Reauthenticate user before changing password
      await user?.reauthenticateWithCredential(credential);
      await user?.updatePassword(_newPasswordController.text);

      if (mounted) {
        Navigator.pop(context); // Close dialog
        showToast(
          'Success',
          'Password changed successfully',
          ToastificationType.success,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        case 'weak-password':
          message = 'New password is too weak';
          break;
        default:
          message = 'Failed to change password';
      }
      showToast('Error', message, ToastificationType.error);
    } catch (e) {
      showToast('Error', 'Something went wrong', ToastificationType.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    }
  }

  Future<void> _showChangeCourseDialog(
    String userId,
    String currentCourse,
  ) async {
    final courseController = TextEditingController(text: currentCourse);
    bool isLoading = false;
    List<String> availableCourses = [];

    // Function to update UI state
    void setDialogLoading(bool loading, StateSetter setDialogState) {
      setDialogState(() {
        isLoading = loading;
      });
    }

    // Function to update course in Firestore
    Future<void> updateCourse(String newCourse) async {
      try {
        // Begin transaction to ensure all updates are atomic
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Update user profile
          transaction.update(
            FirebaseFirestore.instance.collection('users').doc(userId),
            {'course': newCourse},
          );

          // Find all class_students entries for this user
          final classStudentsSnapshot =
              await FirebaseFirestore.instance
                  .collection('class_students')
                  .where('studentId', isEqualTo: userId)
                  .get();

          // Update each entry
          for (final doc in classStudentsSnapshot.docs) {
            transaction.update(doc.reference, {'course': newCourse});
          }
        });

        showToast(
          'Success',
          'Course updated successfully',
          ToastificationType.success,
        );

        Navigator.pop(context);
      } catch (e) {
        showToast(
          'Error',
          'Failed to update course: $e',
          ToastificationType.error,
        );
      }
    }

    await showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              // Fetch available courses when dialog opens
              if (availableCourses.isEmpty && !isLoading) {
                setDialogLoading(true, setDialogState);
                FirebaseFirestore.instance
                    .collection('course_code')
                    .get()
                    .then((snapshot) {
                      final courses =
                          snapshot.docs
                              .map((doc) => doc.data()['code'] as String)
                              .toList();
                      setDialogState(() {
                        availableCourses = courses;
                        isLoading = false;
                      });
                    })
                    .catchError((e) {
                      showToast(
                        'Error',
                        'Failed to load courses: $e',
                        ToastificationType.error,
                      );
                      setDialogLoading(false, setDialogState);
                    });
              }

              return AlertDialog(
                title: Text(
                  'Change Course',
                  style: context.textStyles.subtitle1.textPrimary,
                ),
                content:
                    isLoading
                        ? const Center(
                          heightFactor: 1,
                          child: CircularProgressIndicator(),
                        )
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select your new course:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value:
                                      availableCourses.contains(
                                            courseController.text,
                                          )
                                          ? courseController.text
                                          : (availableCourses.isNotEmpty
                                              ? availableCourses[0]
                                              : null),
                                  hint: const Text('Select Course'),
                                  items:
                                      availableCourses.map((code) {
                                        return DropdownMenuItem(
                                          value: code,
                                          child: Text(code),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      courseController.text = value ?? '';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: context.textStyles.body1.textSecondary,
                    ),
                  ),
                  FilledButton(
                    onPressed:
                        isLoading
                            ? null
                            : () => updateCourse(courseController.text),
                    child:
                        isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: context.colors.surface,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Update',
                              style: context.textStyles.body1.surface,
                            ),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _showChangeYearDialog(String userId, String currentYear) async {
    final yearOptions = ['1', '2', '3', '4'];
    String selectedYear = currentYear.isEmpty ? '1' : currentYear;
    bool isLoading = false;

    // Function to update year in Firestore
    Future<void> updateYear(String newYear) async {
      try {
        // Begin transaction to ensure all updates are atomic
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Update user profile
          transaction.update(
            FirebaseFirestore.instance.collection('users').doc(userId),
            {'yearLevel': newYear},
          );

          // Find all class_students entries for this user
          final classStudentsSnapshot =
              await FirebaseFirestore.instance
                  .collection('class_students')
                  .where('studentId', isEqualTo: userId)
                  .get();

          // Update each entry
          for (final doc in classStudentsSnapshot.docs) {
            transaction.update(doc.reference, {'yearLevel': newYear});
          }
        });

        showToast(
          'Success',
          'Year level updated successfully',
          ToastificationType.success,
        );

        Navigator.pop(context);
      } catch (e) {
        showToast(
          'Error',
          'Failed to update year level: $e',
          ToastificationType.error,
        );
      }
    }

    await showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  'Change Year Level',
                  style: context.textStyles.subtitle1.textPrimary,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select your new year level:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedYear,
                          items:
                              yearOptions.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text('Year $year'),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedYear = value ?? '1';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: context.textStyles.body1.textSecondary,
                    ),
                  ),
                  FilledButton(
                    onPressed:
                        isLoading ? null : () => updateYear(selectedYear),
                    child:
                        isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: context.colors.surface,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Update',
                              style: context.textStyles.body1.surface,
                            ),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _showChangeSectionDialog(
    String userId,
    String currentSection,
  ) async {
    final sectionOptions = ['A', 'B', 'C', 'D', 'E'];
    String selectedSection = currentSection.isEmpty ? 'A' : currentSection;
    bool isLoading = false;

    // Function to update section in Firestore
    Future<void> updateSection(String newSection) async {
      try {
        // Begin transaction to ensure all updates are atomic
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Update user profile
          transaction.update(
            FirebaseFirestore.instance.collection('users').doc(userId),
            {'section': newSection},
          );

          // Find all class_students entries for this user
          final classStudentsSnapshot =
              await FirebaseFirestore.instance
                  .collection('class_students')
                  .where('studentId', isEqualTo: userId)
                  .get();

          // Update each entry
          for (final doc in classStudentsSnapshot.docs) {
            transaction.update(doc.reference, {'section': newSection});
          }
        });

        showToast(
          'Success',
          'Section updated successfully',
          ToastificationType.success,
        );

        Navigator.pop(context);
      } catch (e) {
        showToast(
          'Error',
          'Failed to update section: $e',
          ToastificationType.error,
        );
      }
    }

    await showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  'Change Section',
                  style: context.textStyles.subtitle1.textPrimary,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select your new section:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedSection,
                          items:
                              sectionOptions.map((section) {
                                return DropdownMenuItem(
                                  value: section,
                                  child: Text('Section $section'),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedSection = value ?? 'A';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: context.textStyles.body1.textSecondary,
                    ),
                  ),
                  FilledButton(
                    onPressed:
                        isLoading ? null : () => updateSection(selectedSection),
                    child:
                        isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: context.colors.surface,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Update',
                              style: context.textStyles.body1.surface,
                            ),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: context.textStyles.heading3.textPrimary,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile',
                style: context.textStyles.body1.error,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          if (data == null) {
            return Center(
              child: Text(
                'Profile not found',
                style: context.textStyles.body1.error,
              ),
            );
          }

          final course = data['course'] as String? ?? 'Not set';
          final yearLevel = data['yearLevel'] as String? ?? '';
          final section = data['section'] as String? ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 64,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: context.colors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.email_outlined,
                            color: context.colors.textSecondary,
                          ),
                          title: Text(
                            'Email',
                            style: context.textStyles.caption1.textSecondary,
                          ),
                          subtitle: Text(
                            data['email'] ?? 'Not set',
                            style: context.textStyles.body1.textPrimary,
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.school_outlined,
                            color: context.colors.textSecondary,
                          ),
                          title: Text(
                            'Role',
                            style: context.textStyles.caption1.textSecondary,
                          ),
                          subtitle: Text(
                            data['role']?.toString().toUpperCase() ?? 'Not set',
                            style: context.textStyles.body1.textPrimary,
                          ),
                        ),
                        const Divider(),

                        // Course
                        ListTile(
                          leading: Icon(
                            Icons.book_outlined,
                            color: context.colors.textSecondary,
                          ),
                          title: Text(
                            'Course',
                            style: context.textStyles.caption1.textSecondary,
                          ),
                          subtitle: Text(
                            course,
                            style: context.textStyles.body1.textPrimary,
                          ),
                          trailing: TextButton(
                            onPressed:
                                () => _showChangeCourseDialog(userId!, course),
                            child: Text(
                              'Change',
                              style: context.textStyles.body2.primary,
                            ),
                          ),
                        ),

                        // Year Level
                        ListTile(
                          leading: Icon(
                            Icons.timeline_outlined,
                            color: context.colors.textSecondary,
                          ),
                          title: Text(
                            'Year Level',
                            style: context.textStyles.caption1.textSecondary,
                          ),
                          subtitle: Text(
                            yearLevel.isEmpty ? 'Not set' : 'Year $yearLevel',
                            style: context.textStyles.body1.textPrimary,
                          ),
                          trailing: TextButton(
                            onPressed:
                                () => _showChangeYearDialog(userId!, yearLevel),
                            child: Text(
                              'Change',
                              style: context.textStyles.body2.primary,
                            ),
                          ),
                        ),

                        // Section
                        ListTile(
                          leading: Icon(
                            Icons.group_outlined,
                            color: context.colors.textSecondary,
                          ),
                          title: Text(
                            'Section',
                            style: context.textStyles.caption1.textSecondary,
                          ),
                          subtitle: Text(
                            section.isEmpty ? 'Not set' : 'Section $section',
                            style: context.textStyles.body1.textPrimary,
                          ),
                          trailing: TextButton(
                            onPressed:
                                () =>
                                    _showChangeSectionDialog(userId!, section),
                            child: Text(
                              'Change',
                              style: context.textStyles.body2.primary,
                            ),
                          ),
                        ),

                        const Divider(),
                        ListTile(
                          leading: Icon(
                            Icons.lock_outline,
                            color: context.colors.textSecondary,
                          ),
                          title: Text(
                            'Password',
                            style: context.textStyles.caption1.textSecondary,
                          ),
                          subtitle: Text(
                            '••••••••',
                            style: context.textStyles.body1.textPrimary,
                          ),
                          trailing: TextButton(
                            onPressed: _showChangePasswordDialog,
                            child: Text(
                              'Change',
                              style: context.textStyles.body2.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
