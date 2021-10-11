import 'dart:developer';

import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/text_fields.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'change_password.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _phoneController = TextEditingController();
  String phoneError;

  bool isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(context: context),
      body: SingleChildScrollView(
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
                      height: size.height * 0.1,
                    ),
                    Text(
                      "Döwletiň bäsleşikler ulgamy",
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
                top: size.height * 0.28,
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(left: 22, right: 22, top: 16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Açar sözümi unutdym",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(Constants.appBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              "Telefon belgisi",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 6),
                          PhoneTextField(
                            controller: _phoneController,
                            phoneError: phoneError,
                            textInputAction: TextInputAction.done,
                            onChanged: (v) {
                              if (phoneError != null) {
                                setState(() => phoneError = null);
                              }
                            },
                          ),
                          const SizedBox(height: Constants.defaultMargin),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: size.width * 0.5,
                              child: AbsorbPointer(
                                absorbing: isLoading,
                                child: ElevatedButton(
                                  onPressed: onRenewPasswordTap,
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 150),
                                    child: isLoading
                                        ? Theme(
                                            data: Theme.of(context).copyWith(
                                              accentColor: Colors.white,
                                            ),
                                            child:
                                                const ProgressIndicatorSmall(),
                                          )
                                        : Text(
                                            "Barlamak",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: const Color(Constants.appBlue),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  onRenewPasswordTap() async {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() => isLoading = true);

      Map<String, dynamic> data = {"phone": _phoneController.text};

      Dio dio = Dio();

      log("forgot password:");
      print(Apis.forgotPasswordApi);

      try {
        var response = await dio.post(Apis.forgotPasswordApi, data: data);

        setState(() => isLoading = false);

        print(response.statusCode);
        print(response.data.toString());

        if (response.statusCode == 200) {
          navigateTo(
            context,
            ChangePasswordPage(token: response.data['token']),
          );
        }
      } on DioError catch (e) {
        setState(() => isLoading = false);

        print(e.toString());
      }
    }
  }
}
