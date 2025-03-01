import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_typography.dart';

extension AppTheme on BuildContext {
  AppTypography get typography => AppTypography.of(this);
}
