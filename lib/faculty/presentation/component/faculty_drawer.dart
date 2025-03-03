import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/component/communication/logout_modal.dart';
import '../screen/faculty_screen.dart';
import '../screen/faculty_profile_screen.dart';

class FacultyDrawer extends StatelessWidget {
  final String? currentRoute;

  const FacultyDrawer({super.key, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Faculty User';
    final email = user?.email ?? '';

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.onPrimary,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'F',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            accountName: Text(
              displayName,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              email,
              style: TextStyle(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  screen: const FacultyScreen(),
                  isSelected: currentRoute == FacultyScreen.route,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  screen: const FacultyProfileScreen(),
                  isSelected: currentRoute == FacultyProfileScreen.route,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Website',
                  onTap: () {
                    // Handle website navigation
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? screen,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor:
          isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.2)
              : null,
      shape:
          isSelected
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              : null,
      onTap:
          onTap ??
          (screen != null
              ? () {
                Navigator.of(context).pop();
                if (!isSelected) {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => screen));
                }
              }
              : null),
    );
  }
}
