import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textSubtle,
    required this.background,
    required this.surface,
    required this.border,
    required this.inputBorder,
    required this.error,
    required this.success,
    required this.warning,
  });

  /// Primary brand color, used for main CTAs, links
  /// #006FFD
  final Color primary;

  /// Secondary brand color
  /// #007AFF
  final Color secondary;

  /// Accent color for highlights, badges
  /// #E97C00
  final Color accent;

  /// Primary text color for headings and body
  /// #000000
  final Color textPrimary;

  /// Secondary text color for subtitles
  /// #71727A
  final Color textSecondary;

  /// Hint text color for inputs
  /// #8F9098
  final Color textHint;

  /// Subtle text color for labels
  /// #8E8E93
  final Color textSubtle;

  /// Background color
  /// #FFFFFF
  final Color background;

  /// Surface color for cards, dialogs
  /// #FFFFFF
  final Color surface;

  /// Border color for cards
  /// #3C3C4321
  final Color border;

  /// Border color for input fields
  /// #C5C6CC
  final Color inputBorder;

  /// Error state color
  /// #FF3B30
  final Color error;

  /// Success state color
  /// #34C759
  final Color success;

  /// Warning state color
  /// #FF9500
  final Color warning;

  static final light = AppColors(
    primary: const Color(0xFF006FFD),
    secondary: const Color(0xFF007AFF),
    accent: const Color(0xFFE97C00),
    textPrimary: const Color(0xFF000000),
    textSecondary: const Color(0xFF71727A),
    textHint: const Color(0xFF8F9098),
    textSubtle: const Color(0xFF8E8E93),
    background: const Color(0xFFFFFFFF),
    surface: const Color(0xFFFFFFFF),
    border: const Color(0x213C3C43), // 21 is 13% opacity
    inputBorder: const Color(0xFFC5C6CC),
    error: const Color(0xFFFF3B30),
    success: const Color(0xFF34C759),
    warning: const Color(0xFFFF9500),
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? textSubtle,
    Color? background,
    Color? surface,
    Color? border,
    Color? inputBorder,
    Color? error,
    Color? success,
    Color? warning,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      textSubtle: textSubtle ?? this.textSubtle,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      inputBorder: inputBorder ?? this.inputBorder,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textHint: Color.lerp(textHint, other.textHint, t) ?? textHint,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t) ?? textSubtle,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      border: Color.lerp(border, other.border, t) ?? border,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t) ?? inputBorder,
      error: Color.lerp(error, other.error, t) ?? error,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
    );
  }

  /// Safely get colors from BuildContext
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? light;
  }
}
