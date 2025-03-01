import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_colors.dart';
import 'package:scheduler/common/theme/app_icons.dart';
import 'package:scheduler/common/theme/app_text_styles.dart';

extension AppTheme on BuildContext {
  AppTextStyles get textStyles => AppTextStyles.of(this);
  AppColors get colors => AppColors.of(this);
  AppIcons get icons => AppIcons.of(this);
}
