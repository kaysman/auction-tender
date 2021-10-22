import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcons {
  static const notifications = Icons.notifications;

  // get string
  static String get bookmarkFilled => 'assets/svg/filled.svg';

  static String get live => 'assets/svg/live.svg';

  static String get saylanan => 'assets/svg/saylanan.svg';

  static String get floatBar => 'assets/svg/tab3.svg';

  static String get tabshyrylan => 'assets/svg/tabsyrylan.svg';

  static String get profil => 'assets/svg/profile.svg';

  static Widget get hammer => SvgPicture.asset('assets/svg/hammer.svg');
  static Widget get raising => SvgPicture.asset("assets/svg/arrow_up.svg");
  static Widget bid_down([color]) => SvgPicture.asset(
        "assets/svg/metro-cancel.svg",
        height: 18,
        color: color,
      );
  static Widget bid_up([color]) => SvgPicture.asset(
        "assets/svg/accept.svg",
        height: 18,
        color: color,
      );

  static Widget get upload =>
      SvgPicture.asset("assets/svg/upload.svg", height: 14, width: 14);

  static Widget get filter =>
      SvgPicture.asset('assets/svg/filter.svg', color: Colors.white);

  static Widget get download => _svgAsset18dp("assets/svg/download.svg");

  static Widget get delete => _svgAsset24dp("assets/svg/delete.svg");

  static Widget get empty => SvgPicture.asset("assets/svg/empty.svg");

  static Widget get exception => SvgPicture.asset("assets/svg/exception.svg");

  static Widget get placeholder => _svgAsset24dp("assets/svg/placeholder.svg");

  static Widget get cancel => SvgPicture.asset(
        "assets/svg/cancel.svg",
        height: 14,
        width: 14,
      );

  // 32dp
  static SvgPicture _svgAsset28dp(String assetPath) =>
      SvgPicture.asset(assetPath, width: 28, height: 28);

  // 18dp
  static SvgPicture _svgAsset24dp(String assetPath) =>
      SvgPicture.asset(assetPath, width: 24, height: 24);

  // 18dp
  static SvgPicture _svgAsset18dp(String assetPath) =>
      SvgPicture.asset(assetPath, width: 18, height: 18);

  SvgIcons._();
}

class PngIcons {
  PngIcons._();

  static Image _pngAsset(String assetPath) => Image.asset(assetPath);

  static Widget get barLogo => _pngAsset("assets/png/logo.png");

  static Widget get buildingLogo => _pngAsset("assets/png/logo2.png");
}
