import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/common/component/action/primary_button.dart';

class StudentScreen extends StatelessWidget {
  static const route = '/student';
  static const routeName = 'student';

  const StudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PrimaryButton(
          onPressed: () {
            context.read<AuthBloc>().add(const AuthSignOutEvent());
          },
          text: 'Logout',
        ),
      ),
    );
  }
}
