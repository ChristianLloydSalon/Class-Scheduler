import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDrawer extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onWebsiteTap;
  final VoidCallback onLogoutTap;
  final String? currentRoute;

  const AdminDrawer({
    super.key,
    required this.onProfileTap,
    required this.onWebsiteTap,
    required this.onLogoutTap,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
                      Container(
                        height: 64,
                        width: 64,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: context.icons.adminLogo,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Administrator',
                              style: context.textStyles.subtitle1.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style:
                                    context.textStyles.caption1.textSecondary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Admin Portal',
                    style: context.textStyles.heading2.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your institution',
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
                  _SectionTitle(title: 'Management'),
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    subtitle: 'View and manage your profile',
                    onTap: () {
                      Navigator.pop(context);
                      onProfileTap();
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
                    onTap: () {
                      Navigator.pop(context);
                      onWebsiteTap();
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
                  Navigator.pop(context);
                  onLogoutTap();
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
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? context.colors.textPrimary),
      title: Text(
        title,
        style: context.textStyles.body1.baseStyle.copyWith(
          color: textColor ?? context.colors.textPrimary,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
