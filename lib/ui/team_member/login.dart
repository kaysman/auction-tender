import 'dart:developer';

import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/text_fields.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/validators.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/contestant/register.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'otp_check.dart';

class ViewerLoginPage extends StatefulWidget {
  final bool willPop;

  const ViewerLoginPage({Key key, this.willPop = false}) : super(key: key);

  @override
  _ViewerLoginPageState createState() => _ViewerLoginPageState();
}

class _ViewerLoginPageState extends State<ViewerLoginPage> {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(context: context),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              Container(
                height: size.height,
              ),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 22),
                      width: double.infinity,
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
                            "Şahsy otag girmek",
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
                            obscureText: true,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onLoginTap() async {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() => isLoading = true);

      Map<String, dynamic> data = {
        "phone": _phoneController.text,
        "password": _passwordController.text,
      };

      Dio dio = Dio();

      try {
        Response response = await dio.post(Apis.staffLogin, data: data);
        setState(() => isLoading = false);

        print("user data: ");
        log(response.data.toString());

        if (response.statusCode == 201) {
          navigateTo(context, ViewerOtpCheckPage(user_id: response.data['id']));
        }
      } on DioError catch (e) {
        print(e.error);
        setState(() => isLoading = false);

        if (e.response.statusCode == 403) {
          return navigateTo(
            context,
            ViewerOtpCheckPage(user_id: e.response.data['id']),
          );
        } else if (e.response.statusCode == 400) {
          return showSnackbar(context, "Telefon nomer ýa-da açar söz ýalňyş");
        } else {
          return showSnackbar(
            context,
            e.response.data.map((e) => e['message']).toString(),
          );
        }
      }
    }
  }
}
