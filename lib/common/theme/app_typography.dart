import 'package:flutter/material.dart';

@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.heading4,
    required this.subtitle1,
    required this.subtitle2,
    required this.body1,
    required this.body2,
    required this.body3,
    required this.caption1,
    required this.caption2,
    required this.caption3,
    required this.caption4,
    required this.small,
  });

  /// Heading 1: 36px ExtraBold (w800)
  final TextStyle heading1;

  /// Heading 2: 20px ExtraBold (w800)
  final TextStyle heading2;

  /// Heading 3: 18px ExtraBold (w800)
  final TextStyle heading3;

  /// Heading 4: 17px SemiBold (w600)
  final TextStyle heading4;

  /// Subtitle 1: 15px SemiBold (w600)
  final TextStyle subtitle1;

  /// Subtitle 2: 14px Regular (w400)
  final TextStyle subtitle2;

  /// Body 1: 13px SemiBold (w600)
  final TextStyle body1;

  /// Body 2: 13px Medium (w500)
  final TextStyle body2;

  /// Body 3: 13px Regular (w400)
  final TextStyle body3;

  /// Caption 1: 12px Bold (w700)
  final TextStyle caption1;

  /// Caption 2: 12px SemiBold (w600)
  final TextStyle caption2;

  /// Caption 3: 12px Medium (w500)
  final TextStyle caption3;

  /// Caption 4: 12px Regular (w400)
  final TextStyle caption4;

  /// Small: 10px SemiBold (w600)
  final TextStyle small;

  static const _fontFamily = 'Inter';

  // Default Typography Theme
  static final light = AppTypography(
    // Heading styles
    heading1: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w800, // ExtraBold
      letterSpacing: -0.25,
      height: 1.12,
    ),
    heading2: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w800, // ExtraBold
      letterSpacing: 0,
      height: 1.16,
    ),
    heading3: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w800, // ExtraBold
      letterSpacing: 0,
      height: 1.22,
    ),
    heading4: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w600, // SemiBold
      letterSpacing: 0,
      height: 1.25,
    ),

    // Subtitle styles
    subtitle1: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600, // SemiBold
      letterSpacing: 0,
      height: 1.29,
    ),
    subtitle2: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400, // Regular
      letterSpacing: 0,
      height: 1.33,
    ),

    // Body styles
    body1: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600, // SemiBold
      letterSpacing: 0.5,
      height: 1.5,
    ),
    body2: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500, // Medium
      letterSpacing: 0.25,
      height: 1.43,
    ),
    body3: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400, // Regular
      letterSpacing: 0.4,
      height: 1.33,
    ),

    // Caption styles
    caption1: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700, // Bold
      letterSpacing: 0.1,
      height: 1.43,
    ),
    caption2: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600, // SemiBold
      letterSpacing: 0.5,
      height: 1.33,
    ),
    caption3: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500, // Medium
      letterSpacing: 0.5,
      height: 1.45,
    ),
    caption4: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400, // Regular
      letterSpacing: 0.5,
      height: 1.5,
    ),
    small: const TextStyle(
      fontFamily: _fontFamily,
      fontSize: 10,
      fontWeight: FontWeight.w600, // SemiBold
      letterSpacing: 0.5,
      height: 1.5,
    ),
  );

  @override
  ThemeExtension<AppTypography> copyWith({
    TextStyle? heading1,
    TextStyle? heading2,
    TextStyle? heading3,
    TextStyle? heading4,
    TextStyle? subtitle1,
    TextStyle? subtitle2,
    TextStyle? body1,
    TextStyle? body2,
    TextStyle? body3,
    TextStyle? caption1,
    TextStyle? caption2,
    TextStyle? caption3,
    TextStyle? caption4,
    TextStyle? small,
  }) {
    return AppTypography(
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      heading4: heading4 ?? this.heading4,
      subtitle1: subtitle1 ?? this.subtitle1,
      subtitle2: subtitle2 ?? this.subtitle2,
      body1: body1 ?? this.body1,
      body2: body2 ?? this.body2,
      body3: body3 ?? this.body3,
      caption1: caption1 ?? this.caption1,
      caption2: caption2 ?? this.caption2,
      caption3: caption3 ?? this.caption3,
      caption4: caption4 ?? this.caption4,
      small: small ?? this.small,
    );
  }

  @override
  ThemeExtension<AppTypography> lerp(
    ThemeExtension<AppTypography>? other,
    double t,
  ) {
    if (other is! AppTypography) {
      return this;
    }

    return AppTypography(
      heading1: TextStyle.lerp(heading1, other.heading1, t) ?? heading1,
      heading2: TextStyle.lerp(heading2, other.heading2, t) ?? heading2,
      heading3: TextStyle.lerp(heading3, other.heading3, t) ?? heading3,
      heading4: TextStyle.lerp(heading4, other.heading4, t) ?? heading4,
      subtitle1: TextStyle.lerp(subtitle1, other.subtitle1, t) ?? subtitle1,
      subtitle2: TextStyle.lerp(subtitle2, other.subtitle2, t) ?? subtitle2,
      body1: TextStyle.lerp(body1, other.body1, t) ?? body1,
      body2: TextStyle.lerp(body2, other.body2, t) ?? body2,
      body3: TextStyle.lerp(body3, other.body3, t) ?? body3,
      caption1: TextStyle.lerp(caption1, other.caption1, t) ?? caption1,
      caption2: TextStyle.lerp(caption2, other.caption2, t) ?? caption2,
      caption3: TextStyle.lerp(caption3, other.caption3, t) ?? caption3,
      caption4: TextStyle.lerp(caption4, other.caption4, t) ?? caption4,
      small: TextStyle.lerp(small, other.small, t) ?? small,
    );
  }

  /// Safely get typography from BuildContext
  static AppTypography of(BuildContext context) {
    return Theme.of(context).extension<AppTypography>() ?? light;
  }
}
