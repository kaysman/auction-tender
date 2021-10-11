import 'package:flutter/foundation.dart';

enum Country { TURKMENISTAN, ABROAD }

extension Property on Country {
  String get describe => describeEnum(this).toString();

  String get name {
    switch (this) {
      case Country.TURKMENISTAN:
        return "Türkmenistan";
      case Country.ABROAD:
        return "Daşary ýurt";
      default:
        throw Exception();
    }
  }
}
