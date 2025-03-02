import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          SizedBox(width: 80, height: 80, child: context.icons.adminLogo),
          Text(title, style: context.textStyles.heading4.textPrimary),
          Text(subtitle, style: context.textStyles.body2.textSecondary),
        ],
      ),
    );
  }
}
