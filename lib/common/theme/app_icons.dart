import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

@immutable
class AppIcons extends ThemeExtension<AppIcons> {
  const AppIcons({required this.logo, required this.adminLogo});

  final SvgPicture logo;
  final SvgPicture adminLogo;

  static final icons = AppIcons(
    logo: SvgPicture.asset('assets/icon/logo.svg'),
    adminLogo: SvgPicture.asset('assets/icon/admin_logo.svg'),
  );

  @override
  ThemeExtension<AppIcons> copyWith({SvgPicture? logo, SvgPicture? adminLogo}) {
    return AppIcons(
      logo: logo ?? this.logo,
      adminLogo: adminLogo ?? this.adminLogo,
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
