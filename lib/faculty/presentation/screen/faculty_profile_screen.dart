import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:toastification/toastification.dart';
import '../component/faculty_app_bar.dart';
import '../component/faculty_drawer.dart';
import '../../../../common/theme/app_theme.dart';

class FacultyProfileScreen extends StatelessWidget {
  const FacultyProfileScreen({super.key});

  static const route = '/faculty/profile';

  Future<void> _changePassword(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user?.email == null) return;

    try {
      await auth.sendPasswordResetEmail(email: user!.email!);

      if (context.mounted) {
        showToast(
          'Reset Email Sent',
          'Password reset email has been sent',
          ToastificationType.success,
        );
      }
    } catch (e) {
      showToast(
        'Error',
        'Failed to send password reset email',
        ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const FacultyAppBar(title: 'Profile'),
      drawer: const FacultyDrawer(currentRoute: route),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: context.textStyles.subtitle1.error,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              );
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final displayName = userData?['name'] as String? ?? 'Faculty User';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: context.colors.primary,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'F',
                          style: context.textStyles.heading1.surface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        style: context.textStyles.heading3.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: context.textStyles.body2.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSection(
                  context,
                  title: 'Personal Information',
                  children: [
                    _buildInfoTile(
                      context,
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      value: displayName,
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: 'Account Settings',
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.lock_outline,
                        color: context.colors.primary,
                      ),
                      title: Text(
                        'Change Password',
                        style: context.textStyles.body1.textPrimary,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: context.colors.textSecondary,
                      ),
                      onTap: () => _changePassword(context),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: context.textStyles.subtitle1.primary),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: context.colors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.colors.primary),
      title: Text(label, style: context.textStyles.body2.textSecondary),
      subtitle: Text(value, style: context.textStyles.body1.textPrimary),
    );
  }
}
