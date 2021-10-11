import 'package:flutter/foundation.dart';

enum Gender { ERKEK, ZENAN }

extension Property on Gender {
  String get describe => describeEnum(this).toString();

  String get name {
    switch (this) {
      case Gender.ERKEK:
        return "Erkek";
      case Gender.ZENAN:
        return "Zenan";
      default:
        throw Exception();
    }
  }
}
