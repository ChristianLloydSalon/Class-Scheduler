import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class AdminDrawer extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onWebsiteTap;
  final VoidCallback onLogoutTap;

  const AdminDrawer({
    super.key,
    required this.onProfileTap,
    required this.onWebsiteTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: context.colors.inputBorder),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: context.icons.adminLogo,
                ),
                const SizedBox(height: 16),
                Text(
                  'CIT Administrator',
                  style: context.textStyles.heading3.textPrimary,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your institution',
                  style: context.textStyles.caption1.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerItem(
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: onProfileTap,
          ),
          _DrawerItem(
            icon: Icons.language_outlined,
            title: 'Website',
            onTap: onWebsiteTap,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: onLogoutTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.red[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text('Logout', style: context.textStyles.caption1.error),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: context.colors.textPrimary, size: 20),
            const SizedBox(width: 12),
            Text(title, style: context.textStyles.body1.textPrimary),
          ],
        ),
      ),
    );
  }
}
