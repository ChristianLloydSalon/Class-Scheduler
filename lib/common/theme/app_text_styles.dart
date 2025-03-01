import 'package:flutter/material.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/common/theme/app_typography.dart';

class AppTextStyles {
  final BuildContext context;

  AppTextStyles._(this.context);

  static AppTextStyles of(BuildContext context) => AppTextStyles._(context);

  TextStyleGroup get heading1 =>
      TextStyleGroup(context, AppTypography.of(context).heading1);
  TextStyleGroup get heading2 =>
      TextStyleGroup(context, AppTypography.of(context).heading2);
  TextStyleGroup get heading3 =>
      TextStyleGroup(context, AppTypography.of(context).heading3);
  TextStyleGroup get heading4 =>
      TextStyleGroup(context, AppTypography.of(context).heading4);

  TextStyleGroup get subtitle1 =>
      TextStyleGroup(context, AppTypography.of(context).subtitle1);
  TextStyleGroup get subtitle2 =>
      TextStyleGroup(context, AppTypography.of(context).subtitle2);

  TextStyleGroup get body1 =>
      TextStyleGroup(context, AppTypography.of(context).body1);
  TextStyleGroup get body2 =>
      TextStyleGroup(context, AppTypography.of(context).body2);
  TextStyleGroup get body3 =>
      TextStyleGroup(context, AppTypography.of(context).body3);

  TextStyleGroup get caption1 =>
      TextStyleGroup(context, AppTypography.of(context).caption1);
  TextStyleGroup get caption2 =>
      TextStyleGroup(context, AppTypography.of(context).caption2);
  TextStyleGroup get caption3 =>
      TextStyleGroup(context, AppTypography.of(context).caption3);
  TextStyleGroup get caption4 =>
      TextStyleGroup(context, AppTypography.of(context).caption4);

  TextStyleGroup get small =>
      TextStyleGroup(context, AppTypography.of(context).small);
}

class TextStyleGroup {
  final BuildContext context;
  final TextStyle baseStyle;

  TextStyleGroup(this.context, this.baseStyle);

  TextStyle get primary => baseStyle.copyWith(color: context.colors.primary);
  TextStyle get secondary =>
      baseStyle.copyWith(color: context.colors.secondary);
  TextStyle get accent => baseStyle.copyWith(color: context.colors.accent);
  TextStyle get textPrimary =>
      baseStyle.copyWith(color: context.colors.textPrimary);
  TextStyle get textSecondary =>
      baseStyle.copyWith(color: context.colors.textSecondary);
  TextStyle get textHint => baseStyle.copyWith(color: context.colors.textHint);
  TextStyle get textSubtle =>
      baseStyle.copyWith(color: context.colors.textSubtle);
  TextStyle get error => baseStyle.copyWith(color: context.colors.error);
  TextStyle get success => baseStyle.copyWith(color: context.colors.success);
  TextStyle get warning => baseStyle.copyWith(color: context.colors.warning);
  TextStyle get surface => baseStyle.copyWith(color: context.colors.surface);

  /// Base style without color modification
  TextStyle get regular => baseStyle;
}
