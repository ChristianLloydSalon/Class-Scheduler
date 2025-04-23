import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:scheduler/admin/presentation/component/admin_bottom_nav.dart';
import 'package:scheduler/admin/presentation/component/admin_drawer.dart';
import 'package:scheduler/admin/presentation/component/admin_screens_provider.dart';
import 'package:scheduler/admin/presentation/screen/admin_profile_screen.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/component/communication/logout_modal.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/login/presentation/screen/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminScreen extends HookWidget {
  const AdminScreen({super.key});

  static const route = '/admin';
  static const routeName = 'admin';

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    // Memoize callbacks
    final handleProfileTap = useCallback(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
      );
    }, []);

    final handleLogoutTap = useCallback(() {
      showConfirmationModal(
        context,
        title: 'Sign Out',
        message:
            'Are you sure you want to sign out? You will need to sign in again to access your administrator account.',
        cancelText: 'Cancel',
        confirmText: 'Sign Out',
        onConfirm: () {
          context.read<AuthBloc>().add(const AuthSignOutEvent());
        },
      );
    }, []);

    final handleBottomNavTap = useCallback((int index) {
      selectedIndex.value = index;
    }, []);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!state.authenticated) {
          context.pushReplacementNamed(LoginScreen.routeName);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: Text(
              '${state.role.name.toUpperCase()} Panel',
              style: context.textStyles.heading2.textPrimary,
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          drawer: AdminDrawer(
            onProfileTap: handleProfileTap,
            onLogoutTap: handleLogoutTap,
            onWebsiteTap: () async {
              const websiteUrl = 'https://ismis.bisu.edu.ph/';

              if (await canLaunchUrl(Uri.parse(websiteUrl))) {
                await launchUrl(Uri.parse(websiteUrl));
              }
            },
          ),
          body: SafeArea(
            child: AdminScreensProvider(selectedIndex: selectedIndex.value),
          ),
          bottomNavigationBar:
              state.role.isAdmin
                  ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: AdminBottomNav(
                      currentIndex: selectedIndex.value,
                      onTap: handleBottomNavTap,
                    ),
                  )
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}
