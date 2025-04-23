import 'package:go_router/go_router.dart';
import 'package:scheduler/admin/presentation/screen/admin_screen.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/faculty/presentation/screen/faculty_screen.dart';
import 'package:scheduler/login/presentation/screen/login_screen.dart';
import 'package:scheduler/sign_up/presentation/screen/landing_screen.dart';
import 'package:scheduler/sign_up/presentation/screen/sign_up_screen.dart';
import 'package:scheduler/student/presentation/screen/student_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    initialLocation: LoginScreen.route,
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
      GoRoute(
        path: AdminScreen.route,
        name: AdminScreen.routeName,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: FacultyScreen.route,
        name: FacultyScreen.routeName,
        builder: (context, state) => const FacultyScreen(),
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
        return StudentScreen.route;
      case UserRole.faculty:
        return FacultyScreen.route;
      case UserRole.admin:
      case UserRole.registrar:
        return AdminScreen.route;
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
      case UserRole.registrar:
        return path.startsWith('/admin/');
      case UserRole.none:
        return false;
    }
  }
}
