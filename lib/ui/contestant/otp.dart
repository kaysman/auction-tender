import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/validators.dart';
import 'package:maliye_app/models/user.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maliye_app/ui/common/index.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPage extends StatefulWidget {
  final int user_id;
  final Map<String, dynamic> resendData;

  const OtpPage({Key key, @required this.user_id, @required this.resendData})
      : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isResendLoading = false;

  final _otpController = TextEditingController();
  String otpError;
  String otpMessage = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(context: context),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(Constants.appBlue),
            image: DecorationImage(
              image: AssetImage("assets/png/nagysh.png"),
              fit: BoxFit.cover,
            )),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: Constants.defaultMargin),
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
              const SizedBox(height: Constants.defaultMargin + 38),
              Text(
                "SMS Kod",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: Constants.defaultMargin),
              SizedBox(
                width: size.width * 0.6,
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  validator: validateOtp,
                  decoration: InputDecoration(errorText: otpError),
                  onChanged: (String v) {
                    if (otpError != null) setState(() => otpError = null);
                  },
                  inputFormatters: [LengthLimitingTextInputFormatter(6)],
                ),
              ),
              const SizedBox(height: Constants.defaultMargin),
              Text(
                "Telefon belgiňize gelen SMS kody giriziň.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: size.height * 0.1),
              SizedBox(
                width: size.width * 0.5,
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: ElevatedButton(
                    onPressed: onSubmitTap,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 150),
                      child: isLoading
                          ? Theme(
                              data: Theme.of(context).copyWith(
                                accentColor: Theme.of(context).primaryColor,
                              ),
                              child: const ProgressIndicatorSmall(),
                            )
                          : Text(
                              "Tassyklamak",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: size.width * 0.5,
                child: AbsorbPointer(
                  absorbing: isResendLoading,
                  child: ElevatedButton(
                    onPressed: resendOtp,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 150),
                      child: isResendLoading
                          ? Theme(
                              data: Theme.of(context).copyWith(
                                accentColor: Colors.white,
                              ),
                              child: const ProgressIndicatorSmall(),
                            )
                          : Text(
                              "Täzeden ugrat",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
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
      ),
    );
  }

  Future resendOtp() async {
    Map<String, dynamic> data = {
      "phone": widget.resendData["phone"],
      "password": widget.resendData['password'],
    };

    Dio dio = Dio();
    Response response;

    setState(() {
      _otpController.text = "";
      isResendLoading = true;
    });

    try {
      response = await dio.post(Apis.userLogin, data: data);
      setState(() => isResendLoading = false);
      return;
    } on DioError catch (e) {
      setState(() => isResendLoading = false);
      if (e.response?.statusCode == 403) {
        return;
      } else {
        return showSnackbar(
          context,
          "Sms kody dogry giriziň ýa-da soňrak synanyşyň",
        );
      }
    }
  }

  onSubmitTap() async {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);

    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() => isLoading = true);

      Dio dio = Dio();

      try {
        String namespace = "auth/activate-user";
        Map<String, dynamic> data = {
          "id": widget.user_id,
          "code": _otpController.text,
        };

        Response response = await dio.post(
          Apis.baseAuctionApi + namespace,
          data: data,
        );

        setState(() => isLoading = false);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();

          prefs.setString("access_token", response.data['token']);
          prefs.setString("refresh_token", response.data['refresh_token']);
          apiAuth.setUser(User.fromJson(response.data['data']));

          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => IndexPage()),
              (route) => false,
            );
          });
        }
      } on DioError catch (e) {
        log(e.response.toString());
        setState(() => isLoading = false);

        if (e.response.statusCode == 409) {
          return showSnackbar(context, "Bu telefon belgili agza öñden bar");
        } else {
          return showSnackbar(context,
              "Sms kody dogry giriziñ ýada biraz wagtdan gaýtadan synanyşyň");
        }
      }
    }
  }
}
