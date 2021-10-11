import 'dart:convert';

import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/text_fields.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/validators.dart';
import 'package:maliye_app/models/user.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/team_member/login.dart';
import 'package:maliye_app/ui/contestant/register.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password.dart';
import 'otp.dart';

class LoginPage extends StatefulWidget {
  final bool willPop;
  final showAppBar;

  const LoginPage({Key key, this.willPop = false, this.showAppBar = false})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool rememberMe = false;

  final _phoneController = TextEditingController();
  String _phoneError;

  final _passwordController = TextEditingController();
  String _passwordError;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: widget.showAppBar ? MyAppBar(context: context) : null,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Container(height: size.height),
                Container(
                  width: double.infinity,
                  height: size.height * 0.35,
                  decoration: BoxDecoration(
                    color: const Color(Constants.appBlue),
                    image: DecorationImage(
                      image: AssetImage("assets/png/nagysh.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/svg/nagysh.svg",
                        height: size.height * 0.17,
                      ),
                      Text(
                        Constants.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffffffff),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: size.height * 0.23,
                  child: Column(
                    children: [
                      Container(
                        width: orientation == Orientation.landscape ? size.width * 0.5 : size.width,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 22,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(1, 3),
                              blurRadius: 6,
                              color: Colors.black.withOpacity(0.06),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Şahsy otaga girmek",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(Constants.appBlue),
                              ),
                            ),
                            const SizedBox(height: Constants.defaultMargin),
                            PhoneTextField(
                              controller: _phoneController,
                              phoneError: _phoneError,
                              onChanged: (String v) {
                                if (_phoneError != null)
                                  setState(() => _phoneError = null);
                              },
                            ),
                            const SizedBox(height: Constants.defaultMargin),
                            TextFormField(
                              controller: _passwordController,
                              validator: validatePassword,
                              textInputAction: TextInputAction.go,
                              obscureText: true,
                              onFieldSubmitted: (v){
                                onLoginTap();
                              },
                              decoration: InputDecoration(
                                labelText: "Açar sözi",
                                errorText: _passwordError,
                              ),
                              onChanged: (String v) {
                                if (_passwordError != null)
                                  setState(() => _passwordError = null);
                              },
                            ),
                            const SizedBox(height: Constants.defaultMargin),
                            SizedBox(
                              width: size.width * 0.5,
                              child: AbsorbPointer(
                                absorbing: isLoading,
                                child: ElevatedButton(
                                  onPressed: onLoginTap,
                                  style: ElevatedButton.styleFrom(
                                    primary: const Color(Constants.appBlue),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 150),
                                    child: isLoading
                                        ? const ProgressIndicatorSmall(
                                        color: Colors.white)
                                        : Text(
                                      "Girmek",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: size.width * 0.5,
                        child: InkWell(
                          onTap: () => navigateTo(context, RegisterPage()),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(1, 3),
                                    blurRadius: 6,
                                    color: Colors.black.withOpacity(0.06),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Text(
                                'Agza bolmak',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: size.width * 0.5,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => navigateTo(context, ViewerLoginPage()),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(1, 3),
                                    blurRadius: 6,
                                    color: Colors.black.withOpacity(0.06),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Text(
                                'Topar agza bolup gatnaşmak',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: size.width * 0.5,
                        child: InkWell(
                          onTap: () => navigateTo(context, ForgotPassword()),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(1, 3),
                                    blurRadius: 6,
                                    color: Colors.black.withOpacity(0.06),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Text(
                                'Açar sözümi unutdym',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  onLoginTap() {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() => isLoading = true);
      loginUser();
    }
  }

  Future loginUser() async {
    Map<String, dynamic> data = {
      "phone": _phoneController.text,
      "password": _passwordController.text,
    };

    Dio dio = Dio();
    Response response;

    try {
      response = await dio.post(Apis.userLogin, data: data);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        print(response.data);

        final state = Provider.of<ApiAuth>(context, listen: false);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("access_token", response.data['token']);
        prefs.setString("refresh_token", response.data['refresh_token']);

        // save user preferences
        prefs.setString(
          "user",
          jsonEncode(User.fromJson(response.data['data'])),
        );
        state.setUser(User.fromJson(response.data['data']));

        if (widget.willPop) {
          Navigator.pop(context);
        }
      }
    } on DioError catch (e) {
      print(e);
      setState(() => isLoading = false);

      if (e.response?.statusCode == 403) {
        return navigateTo(
            context,
            OtpPage(
              user_id: e.response.data['id'],
              resendData: data,
            ));
      } else {
        return showSnackbar(
          context,
          "Dogry telefon nomer we parol giriziñ ýada soňrak gaýtadan synanyşyň",
        );
      }
    }
  }
}
