import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:scheduler/admin/presentation/screen/admin_screen.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/communication/custom_toast.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/faculty/presentation/screen/faculty_screen.dart';
import 'package:scheduler/sign_up/presentation/screen/landing_screen.dart';
import 'package:scheduler/student/presentation/screen/student_screen.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  static const route = '/';
  static const routeName = 'login';

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    void handleLogin() {
      if (formKey.currentState?.validate() ?? false) {
        context.read<AuthBloc>().add(
          AuthSignInEvent(emailController.text, passwordController.text),
        );
      }
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.authenticated) {
          if (state.role.isNone) {
            showToast(
              'Error 404',
              'User role not found',
              ToastificationType.error,
            );
            return;
          }

          context.pushReplacementNamed(
            state.role.isStudent
                ? StudentScreen.routeName
                : state.role.isFaculty
                ? FacultyScreen.routeName
                : AdminScreen.routeName,
          );

          return;
        }

        if (state.errorMessage?.isNotEmpty ?? false) {
          showToast(
            'Error',
            state.errorMessage ?? '',
            ToastificationType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello!',
                              style: context.textStyles.heading1.textPrimary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please enter your email to log in.',
                              style: context.textStyles.subtitle2.textPrimary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      context.icons.logo,
                    ],
                  ),
                  const SizedBox(height: 32),
                  PrimaryTextField(
                    controller: emailController,
                    hintText: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.endsWith('@bisu.edu.ph')) {
                        return 'Please use your BISU email (@bisu.edu.ph)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Login',
                    onPressed: handleLogin,
                    width: double.infinity,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No account? ',
                        style: context.textStyles.body2.textSecondary,
                      ),
                      TextButton(
                        onPressed: () {
                          context.pushNamed(LandingScreen.routeName);
                        },
                        child: Text(
                          'Register now',
                          style: context.textStyles.body2.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
