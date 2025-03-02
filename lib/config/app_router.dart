import 'package:go_router/go_router.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/login/presentation/screen/login_screen.dart';
import 'package:scheduler/sign_up/presentation/screen/landing_screen.dart';
import 'package:scheduler/sign_up/presentation/screen/sign_up_screen.dart';
import 'package:scheduler/student/presentation/screen/student_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    initialLocation: Uri.base.path,
    routes: [
      GoRoute(
        path: LoginScreen.route,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: LandingScreen.route,
        name: LandingScreen.routeName,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: SignUpScreen.route,
        name: SignUpScreen.routeName,
        builder: (context, state) {
          final registerType =
              state.extra as RegisterType? ?? RegisterType.none;

          return SignUpScreen(registerType: registerType);
        },
        redirect: (context, state) {
          final registerType =
              state.extra as RegisterType? ?? RegisterType.none;

          if (registerType == RegisterType.none) {
            return LandingScreen.route;
          }

          return null;
        },
      ),
      GoRoute(
        path: StudentScreen.route,
        name: StudentScreen.routeName,
        builder: (context, state) => const StudentScreen(),
      ),
    ],
    redirect: (context, state) async {
      // get user from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final role = prefs.getString('role') ?? '';

      final userRole = UserRole.values.firstWhere(
        (e) => e.name == (role),
        orElse: () => UserRole.none,
      );

      final isAuthenticated = userId != null;
      final isAuthRoute =
          state.matchedLocation == LoginScreen.route ||
          state.matchedLocation == LandingScreen.route ||
          state.matchedLocation == SignUpScreen.route;

      // Handle unauthenticated users
      if (!isAuthenticated) {
        return isAuthRoute ? null : LoginScreen.route;
      }

      // Handle authenticated users
      if (isAuthRoute) {
        // Redirect to appropriate dashboard based on role
        return _getInitialRouteForRole(userRole);
      }

      // Check if user has access to the requested route
      if (!_hasAccess(userRole, state.uri.path)) {
        return _getInitialRouteForRole(userRole);
      }

      return null;
    },
  );

  static String _getInitialRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return '/student/schedule';
      case UserRole.faculty:
        return '/faculty/schedule';
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.none:
        return LoginScreen.route;
    }
  }

  static bool _hasAccess(UserRole role, String path) {
    switch (role) {
      case UserRole.student:
        return path.startsWith('/student/');
      case UserRole.faculty:
        return path.startsWith('/faculty/');
      case UserRole.admin:
        return path.startsWith('/admin/');
      case UserRole.none:
        return false;
    }
  }
}
