import 'package:maliye_app/providers/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apis.dart';

Future<bool> updateAccessToken(BuildContext context) async {
  final apiAuth = Provider.of<ApiAuth>(context, listen: false);
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString("refresh_token");
  Dio dio = Dio();
  try {
    Response response = await dio.get(
      Apis.getUpdateTokenApi,
      options: Options(headers: {"Authorization": "Bearer $refreshToken"}),
    );
    if (response.statusCode == 200) {
      prefs.setString("access_token", response.data['token']);
      return true;
    }
  } on DioError catch (e) {
    print("update access token status code: ${e.response.statusCode}");
    if (e.response.statusCode == 403) {
      print("update access token status code: 403");
      apiAuth.setUser(null);
    }
  }
  return false;
}

formattedPrice(String price) {
  return NumberFormat.currency(locale: 'uz', symbol: '').format(
    double.tryParse(price),
  );
}

void navigateTo(BuildContext context, Widget page) {
  Navigator.push<dynamic>(
    context,
    MaterialPageRoute(builder: (_) => page),
  );
  // PageTransition(
  //     alignment: Alignment.bottomCenter,
  //     curve: Curves.decelerate,
  //     duration: Duration(milliseconds: 300),
  //     reverseDuration: Duration(milliseconds: 300),
  //     type: PageTransitionType.rightToLeftWithFade,
  //     child: page,
  // ),
}

void hideKeyboard({BuildContext context}) {
  if (context == null) {
    FocusManager.instance.primaryFocus?.unfocus();
  } else {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}

void showSnackbar(BuildContext context, String message,
    [bool success = false]) {
  FToast()
    ..init(context)
    ..removeCustomToast()
    ..showToast(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: success ? Colors.blue : Color(0xFFFD6C6C),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(success ? Icons.check : Icons.cancel_outlined,
                color: Colors.white),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      gravity: ToastGravity.SNACKBAR,
      toastDuration: Duration(seconds: 5),
    );
}

int castToInt(dynamic value) {
  return (value is int) ? value : (int.tryParse(value.toString()) ?? 0);
}

extension DateFormatter on DateTime {
  String format(String format) {
    return DateFormat(format).format(this);
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }
}
