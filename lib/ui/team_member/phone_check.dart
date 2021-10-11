import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/text_fields.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/contestant/auction/lot_game.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberPhoneCheck extends StatefulWidget {
  final int lot_id;

  const MemberPhoneCheck({Key key, this.lot_id}) : super(key: key);

  @override
  _MemberPhoneCheckState createState() => _MemberPhoneCheckState();
}

class _MemberPhoneCheckState extends State<MemberPhoneCheck> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _phoneController = TextEditingController();
  String phoneError;

  bool isLoading = false;

  @override
  void initState() {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    _phoneController.text = apiAuth.authorizedUser.phone;
    super.initState();
  }

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
      body: Form(
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
                    Constants.label,
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
                            "Bäsleşikli söwda gatnaşmak",
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
                                onPressed: onStartTap,
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 150),
                                  child: isLoading
                                      ? Theme(
                                          data: Theme.of(context).copyWith(
                                            accentColor: Colors.white,
                                          ),
                                          child: const ProgressIndicatorSmall(),
                                        )
                                      : Text(
                                          "Girmek",
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
    );
  }

  onStartTap() async {
    hideKeyboard();

    if (isLoading) return;

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() => isLoading = true);

      final apiAuth = Provider.of<ApiAuth>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      Dio dio = Dio();

      print(Apis.staffLotData(widget.lot_id, apiAuth.authorizedUser.id));
      try {
        var response = await dio.get(
          Apis.staffLotData(widget.lot_id, apiAuth.authorizedUser.id),
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );

        setState(() => isLoading = false);
        if (response.statusCode == 200) {
          navigateTo(context, LotGame(lot: LotBig.fromJson(response.data)));
        }
      } on DioError catch (e) {
        setState(() => isLoading = false);
        log(e.toString());
        showSnackbar(context, e.response.toString());
      }
    }
  }
}
