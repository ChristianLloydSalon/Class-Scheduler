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
