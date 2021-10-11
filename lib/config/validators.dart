import 'package:flutter/material.dart';

RegExp charRegExp = RegExp('[a-zA-Z]');

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }
}

String validateOtp(String value) {
  if (value == null || value.isEmpty) {
    return 'Telefonyñyza gelen gizlin kody girizmegiňizi haýyş edýäris';
  } else if (value.length != 6) {
    return 'Diňe 6 simwol bolmaly';
  }
  return null;
}

String validatePhone(String value) {
  if (value == null || value.isEmpty) {
    return 'Telefon belgisini giriziň';
  }
  return null;
}

String getPhoneMask(String unFormattedText) {
  var b = unFormattedText.characters.map((char) {
    return int.tryParse(char);
  });
  var c = b.where((element) => element != null);
  var result = c.toList().join('');
  return result;
}

String validateHumanName(String value) {
  if (value == null || value.isEmpty) {
    return 'Boş goýmaly däl';
  } else if (value.contains(RegExp(r'[0-9]'))) {
    return "Sanlary goldamaýar";
  }
  return null;
}

String validateEmail(String value) {
  if (value == null || value.isEmpty) {
    return 'Boş goýmaly däl';
  } else if (!value.isValidEmail()) {
    return 'Nädogry email';
  }
  return null;
}

String validateCompanyName(String value) {
  return validateHumanName(value);
}

String validateNumber(String value) {
  if (value == null || value.isEmpty) {
    return 'Boş goýmaly däl';
  }
  if (int.tryParse(value) == null) {
    return 'Diňe sanlara rugsat berilýär';
  }
  return null;
}

String validateCommon(String value) {
  if (value == null || value.isEmpty) {
    return 'Boş goýmaly däl';
  }
  return null;
}

String validatePassport(String value) {
  if (value == null || value.isEmpty) {
    return 'Boş goýmaly däl';
  } else if (value.length < 9) {
    return '9 sifrdan az bolmaly däl';
  }
  return null;
}

String validatePassword(String value) {
  if (value == null || value.isEmpty) {
    return 'Boş goýmaly däl';
  } else if (value.length < 8) {
    return '7-den gowrak nyşan giriziň';
  } else if (!(value.contains(RegExp(r'[0-9]')))) {
    return 'Iň azyndan bir san giriziň';
  } else if (!(value.toLowerCase().contains(charRegExp))) {
    return 'Iň azyndan bir nyşan giriziň';
  }
  return null;
}
