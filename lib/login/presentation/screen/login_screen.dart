import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scheduler/common/component/action/primary_button.dart';
import 'package:scheduler/common/component/input/primary_text_field.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    useEffect(() {
      return () {
        emailController.dispose();
        passwordController.dispose();
      };
    }, []);

    void handleLogin() {
      if (formKey.currentState?.validate() ?? false) {
        // TODO: Implement login logic
      }
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
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
                            'Please enter your ID to log in.',
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
                  hintText: 'Student Email',
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
                        // TODO: Navigate to registration
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
    );
  }
}
