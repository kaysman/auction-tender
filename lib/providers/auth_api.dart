import 'package:maliye_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuth with ChangeNotifier {
  /// user
  User _authUser;
  User get authorizedUser => this._authUser;
  setUser(User value, [bool notifyListener = true]) {
    this._authUser = value;
    if (notifyListener) {
      this.notifyListeners();
    }
  }

  // int buyer_id = 0;
  // setBuyerId(int buyerId, [bool notifyListener = true]) {
  //   this.buyer_id = buyerId;
  //   if (notifyListener) {
  //     this.notifyListeners();
  //   }
  // }

  logout() async {
    _authUser = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    prefs.remove("access_token");
    prefs.remove("refresh_token");
    notifyListeners();
  }

  // static Future<ApiAuth> getInstance() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return ApiAuth(
  //     token: prefs.getString('token'),
  //     authUser: User(
  //       json: prefs.containsKey('user') ? jsonDecode(prefs.getString('user')) : null,
  //     ),
  //   );
  // }

  // static Future<ApiAuth> login(Map<String, dynamic> payload) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('token', payload['access_token'] ?? null);
  //   await prefs.setString('token_expires_at', payload['expires_at'] ?? null);
  //   await prefs.setString('user', jsonEncode(payload['user']));

  //   return ApiAuth(
  //     token: prefs.getString('token'),
  //     authUser: User(
  //       json: jsonDecode(
  //         prefs.getString('user'),
  //       ),
  //     ),
  //   );
  // }

  // static Future<void> logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('token');
  //   await prefs.remove('token_expires_at');
  //   await prefs.remove('user');
  // }
}
