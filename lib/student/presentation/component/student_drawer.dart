import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/communication/logout_modal.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/student/presentation/screen/student_profile_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  bottom: BorderSide(color: context.colors.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  context.icons.logo,
                  const SizedBox(height: 16),
                  Text(
                    'Student Portal',
                    style: context.textStyles.heading2.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your academic journey',
                    style: context.textStyles.body2.textSecondary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),
                  _SectionTitle(title: 'Account'),
                  ListTile(
                    leading: Icon(
                      Icons.person_outline_rounded,
                      color: context.colors.textPrimary,
                    ),
                    title: Text(
                      'Profile',
                      style: context.textStyles.body1.textPrimary,
                    ),
                    subtitle: Text(
                      'View and manage your profile',
                      style: context.textStyles.caption1.textSecondary,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: 'Resources'),
                  ListTile(
                    leading: Icon(
                      Icons.language_rounded,
                      color: context.colors.textPrimary,
                    ),
                    title: Text(
                      'School Website',
                      style: context.textStyles.body1.textPrimary,
                    ),
                    subtitle: Text(
                      'Visit our official website',
                      style: context.textStyles.caption1.textSecondary,
                    ),
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                    onTap: () async {
                      const websiteUrl = 'https://ismis.bisu.edu.ph/';

                      if (await canLaunchUrl(Uri.parse(websiteUrl))) {
                        await launchUrl(Uri.parse(websiteUrl));
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: context.colors.error,
                ),
                title: Text('Sign Out', style: context.textStyles.body1.error),
                subtitle: Text(
                  'End your current session',
                  style: context.textStyles.caption1.textSecondary,
                ),
                onTap: () {
                  showConfirmationModal(
                    context,
                    title: 'Sign Out',
                    message:
                        'Are you sure you want to sign out? You will need to sign in again to access your student account.',
                    cancelText: 'Cancel',
                    confirmText: 'Sign Out',
                    onConfirm: () {
                      context.read<AuthBloc>().add(const AuthSignOutEvent());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(title, style: context.textStyles.body1.textSecondary),
    );
  }
}
