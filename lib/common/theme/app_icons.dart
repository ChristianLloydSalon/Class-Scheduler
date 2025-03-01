import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

@immutable
class AppIcons extends ThemeExtension<AppIcons> {
  const AppIcons({
    required this.logo,
    // Add other icons as needed
  });

  final SvgPicture logo;

  static final icons = AppIcons(
    logo: SvgPicture.asset('assets/icons/logo.svg'),
  );

  @override
  ThemeExtension<AppIcons> copyWith({
    SvgPicture? logo,
  }) {
    return AppIcons(
      logo: logo ?? this.logo,
    );
  }

  @override
  ThemeExtension<AppIcons> lerp(ThemeExtension<AppIcons>? other, double t) {
    if (other is! AppIcons) {
      return this;
    }
    return this;
  }

  /// Safely get icons from BuildContext
  static AppIcons of(BuildContext context) {
    return Theme.of(context).extension<AppIcons>() ?? icons;
  }
}
