import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/communication/logout_modal.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import '../screen/faculty_screen.dart';
import '../screen/faculty_profile_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class FacultyDrawer extends StatelessWidget {
  final String? currentRoute;

  const FacultyDrawer({super.key, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Faculty User';
    final email = user?.email ?? '';

    return Drawer(
      backgroundColor: context.colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: context.colors.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: context.colors.primary.withOpacity(
                          0.1,
                        ),
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'F',
                          style: context.textStyles.heading1.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: context.textStyles.subtitle1.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: context.textStyles.caption1.textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Faculty Portal',
                    style: context.textStyles.heading2.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your classes and schedules',
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
                  _SectionTitle(title: 'Navigation'),
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    subtitle: 'View and manage your classes',
                    isSelected: currentRoute == FacultyScreen.route,
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != FacultyScreen.route) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FacultyScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    subtitle: 'View and manage your profile',
                    isSelected: currentRoute == FacultyProfileScreen.route,
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != FacultyProfileScreen.route) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FacultyProfileScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: 'Resources'),
                  _DrawerItem(
                    icon: Icons.language_rounded,
                    title: 'School Website',
                    subtitle: 'Visit our official website',
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
              child: _DrawerItem(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                subtitle: 'End your current session',
                textColor: context.colors.error,
                iconColor: context.colors.error,
                onTap: () {
                  showConfirmationModal(
                    context,
                    title: 'Sign Out',
                    message:
                        'Are you sure you want to sign out? You will need to sign in again to access your faculty account.',
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
      child: Text(
        title.toUpperCase(),
        style: context.textStyles.body1.textSecondary,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isSelected = false,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor =
        textColor ??
        (isSelected ? context.colors.primary : context.colors.textPrimary);
    final effectiveIconColor =
        iconColor ??
        (isSelected ? context.colors.primary : context.colors.textPrimary);

    return ListTile(
      leading: Icon(icon, color: effectiveIconColor),
      title: Text(
        title,
        style: context.textStyles.body1.baseStyle.copyWith(
          color: effectiveTextColor,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: context.textStyles.caption1.textSecondary,
              )
              : null,
      trailing: trailing,
      selected: isSelected,
      selectedTileColor: context.colors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
