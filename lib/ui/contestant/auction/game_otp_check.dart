import 'dart:developer';

import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/validators.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/contestant/auction/lot_game.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OtpCheck extends StatefulWidget {
  final int lot_id;
  final int buyer_id;
  final int ticket_no;

  const OtpCheck({
    Key key,
    @required this.lot_id,
    this.buyer_id,
    @required this.ticket_no,
  }) : super(key: key);

  @override
  _OtpCheckState createState() => _OtpCheckState();
}

class _OtpCheckState extends State<OtpCheck> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Dio dio = Dio();

  bool isLoading = false;
  bool isResendLoading = false;

  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: Constants.defaultMargin + 38),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "SMS Kod",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: Constants.defaultMargin),
              SizedBox(
                width: size.width * 0.6,
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  validator: validateOtp,
                  inputFormatters: [LengthLimitingTextInputFormatter(6)],
                ),
              ),
              const SizedBox(height: Constants.defaultMargin + 20),
              Text(
                "Telefon belgiňize gelen SMS kody giriziň.",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              SizedBox(height: size.height * 0.1),
              SizedBox(
                width: size.width * 0.5,
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: ElevatedButton(
                    onPressed: onSubmitTap,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 150),
                      child: isLoading
                          ? Theme(
                              data: Theme.of(context).copyWith(
                                accentColor: Color(Constants.appBlue),
                              ),
                              child: const ProgressIndicatorSmall(),
                            )
                          : Text(
                              "Tassyklamak",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(Constants.appBlue),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
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

  resendOtp() async {
    setState(() {
      _otpController.text = "";
      isResendLoading = true;
    });

    final apiAuth = Provider.of<ApiAuth>(context, listen: false);

    Map<String, dynamic> data = {
      "user_id": apiAuth.authorizedUser.id,
      "lot_id": widget.lot_id,
      "ticket_number": widget.ticket_no,
    };

    Dio dio = Dio();
    try {
      var response = await dio.post(Apis.lotLogin, data: data);
      setState(() => isResendLoading = false);

      if (response.statusCode == 200) {
        log("Resent");
      }
    } on DioError catch (e) {
      setState(() => isResendLoading = false);
      log(e.toString());
      showSnackbar(context, e.response.toString());
    }
  }

  onSubmitTap() async {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() => isLoading = true);

      Map<String, dynamic> data = {
        "buyer_id": widget.buyer_id,
        "code": _otpController.text,
      };

      try {
        var response = await dio.post(Apis.userCheck, data: data);
        setState(() => isLoading = false);

        if (response.statusCode == 200) {
          log(response.data.toString());
          onSucceed(response.data['token']);
          showSnackbar(context, "Üstünlik hemraňyz bolsun!", true);
        }
      } catch (e) {
        setState(() => isLoading = false);
        showSnackbar(context, "Näbelli ýalňyşlyk ýüze çykdy");
      }
    }
  }

  onSucceed(String token) async {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    try {
      Dio dio = Dio();

      var response = await dio.get(
        Apis.lotGameDetail(widget.lot_id, widget.buyer_id),
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        log(response.data.toString());
        navigateTo(context, LotGame(lot: LotBig.fromJson(response.data)));
      }
    } on DioError catch (e) {
      showSnackbar(context, "Sms kody dogry giriziň ýa-da soňrak synanyşyň");
      throw e;
    }
  }
}
