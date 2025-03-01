import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scheduler/common/component/action/secondary_button.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/sign_up/presentation/screen/sign_up_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              SvgPicture.asset(
                'assets/image/students.svg',
                height: screenHeight * 0.6,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ShaderMask(
                  shaderCallback:
                      (rect) => LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.white, Colors.transparent],
                      ).createShader(rect),
                  child: Container(
                    height: screenHeight * 0.5,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [const _Spiels(), const _RegisterButtons()],
              ),
            ),
          ),
          // Arrow back button
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 24,
                    color: context.colors.textHint,
                  ),
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spiels extends StatelessWidget {
  const _Spiels();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Text('Stay Organized,', style: context.textStyles.heading1.textPrimary),
        Text('Stay on Track', style: context.textStyles.heading1.textPrimary),
        Text(
          'Students, keep track of your classes with instant notifications. Teachers, plan your sessions and stay ahead. Get started today!',
          style: context.textStyles.body1.textSecondary,
        ),
      ],
    );
  }
}

class _RegisterButtons extends StatelessWidget {
  const _RegisterButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        SecondaryButton(
          width: double.infinity,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        const SignUpScreen(registerType: RegisterType.student),
              ),
            );
          },
          text: 'Register as Student',
        ),
        SecondaryButton(
          width: double.infinity,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        const SignUpScreen(registerType: RegisterType.faculty),
              ),
            );
          },
          text: 'Register as Faculty',
        ),
      ],
    );
  }
}
