import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/student/presentation/screen/student_screen.dart';

enum RegisterType {
  none,
  student,
  faculty;

  bool get isStudent => this == student;
  bool get isFaculty => this == faculty;
}

class SignUpScreen extends HookWidget {
  const SignUpScreen({super.key, required this.registerType});

  final RegisterType registerType;

  static const route = '/sign-up';
  static const routeName = 'sign-up';

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final idController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    void handleSignUp() {
      if (formKey.currentState?.validate() ?? false) {
        context.read<AuthBloc>().add(
          AuthSignUpEvent(
            name: nameController.text,
            id: idController.text,
            email: emailController.text,
            password: passwordController.text,
            role: registerType.isFaculty ? UserRole.faculty : UserRole.student,
          ),
        );
      }
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.authenticated) {
          context.pushReplacementNamed(StudentScreen.routeName);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            40,
            24,
            40 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              const _Header(),
              const SizedBox(height: 40),
              _FormSection(
                formKey: formKey,
                nameController: nameController,
                idController: idController,
                emailController: emailController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                width: double.infinity,
                onPressed: handleSignUp,
                text: 'Sign Up',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign Up', style: context.textStyles.heading1.textPrimary),
            Text(
              'Create an account to get started',
              style: context.textStyles.subtitle2.textPrimary,
            ),
          ],
        ),
        const SizedBox(width: 16),
        context.icons.logo,
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.formKey,
    required this.nameController,
    required this.idController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final Key formKey;
  final TextEditingController nameController;
  final TextEditingController idController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          PrimaryTextField(
            labelText: 'Name',
            controller: nameController,
            hintText: 'John Doe',
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          PrimaryTextField(
            labelText: 'ID',
            controller: idController,
            hintText: '123456',
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ID is required';
              }
              if (value.length != 6) {
                return 'ID must be 6 digits';
              }
              return null;
            },
          ),
          PrimaryTextField(
            labelText: 'Email',
            controller: emailController,
            hintText: 'email.@bisu.edu.ph',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Invalid email';
              }
              if (!value.endsWith('@bisu.edu.ph')) {
                return 'Email must end with @bisu.edu.ph';
              }
              return null;
            },
          ),
          PrimaryTextField(
            labelText: 'Password',
            controller: passwordController,
            hintText: 'Create a password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value != confirmPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          PrimaryTextField(
            controller: confirmPasswordController,
            hintText: 'Confirm password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm password is required';
              }
              if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
