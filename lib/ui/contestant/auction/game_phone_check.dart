import 'dart:developer';

import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/labeled_checkbox.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/text_fields.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/models/rule.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'game_otp_check.dart';

class LotPhoneCheck extends StatefulWidget {
  final int lot_id;
  final int ticket_no;

  const LotPhoneCheck({Key key, this.ticket_no, this.lot_id}) : super(key: key);

  @override
  _LotPhoneCheckState createState() => _LotPhoneCheckState();
}

class _LotPhoneCheckState extends State<LotPhoneCheck> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _phoneController = TextEditingController();
  String phoneError;

  bool isLoading = false;
  bool isAgreeLoading = false;

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
    final size = MediaQuery.of(context).size;

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
                                onPressed: getRules,
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

  onAgreeTap() async {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    setState(() => isAgreeLoading = true);
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);

    Map<String, dynamic> data = {
      "user_id": apiAuth.authorizedUser.id,
      "lot_id": widget.lot_id,
      "ticket_number": widget.ticket_no,
    };

    Dio dio = Dio();

    try {
      var response = await dio.post(Apis.lotLogin, data: data);
      setState(() => isAgreeLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context);
        navigateTo(
          context,
          OtpCheck(
            lot_id: widget.lot_id,
            ticket_no: widget.ticket_no,
            buyer_id: response.data['buyer_id'],
          ),
        );
      }
    } on DioError catch (e) {
      setState(() => isAgreeLoading = false);
      log(e.toString());
      showSnackbar(context, e.response.toString());
    }
  }

  getRules() async {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() => isLoading = true);

      Dio dio = Dio();

      try {
        // use id 1 to get rules that appear on game entrance
        var response = await dio.get(Apis.getRulesApi(1));
        setState(() => isLoading = false);

        if (response.statusCode == 200) {
          List<Rule> duty_list = (response.data.first['duty_list'] ?? [])
              .map<Rule>((json) => Rule.fromMap(json))
              .toList();
          List<Rule> agree_list = (response.data.first['agree_list'] ?? [])
              .map<Rule>((json) => Rule.fromMap(json))
              .toList();
          buildDialog(duty_list, agree_list);
        }
      } on DioError catch (e) {
        setState(() => isLoading = false);
        log(e.toString());
        showSnackbar(context, e.response.toString());
      }
    }
  }

  void buildDialog(List<Rule> duty_list, List<Rule> agree_list) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 24.0,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              List<bool> agreements =
                  duty_list.map((e) => e.userAgreed).toList();
              agreements.addAll(agree_list.map((e) => e.userAgreed).toList());
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Scrollbar(
                        isAlwaysShown: true,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          children: [
                            Text(
                              "Ýerine ýetirilmeli şertler",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (var rule in duty_list)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: LabeledCheckbox(
                                  label: rule.rule_name,
                                  value: rule.userAgreed,
                                  onChanged: (bool v) {
                                    rule.userAgreed = v;
                                    setState(() {});
                                  },
                                ),
                              ),
                            Text(
                              "Razylaşmaly kadalar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (var rule in agree_list)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: LabeledCheckbox(
                                  label: rule.rule_name,
                                  value: rule.userAgreed,
                                  onChanged: (bool v) {
                                    rule.userAgreed = v;
                                    setState(() {});
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      width: MediaQuery.of(context).size.width,
                      child: AbsorbPointer(
                        absorbing: isAgreeLoading,
                        child: ElevatedButton(
                          onPressed:
                              agreements.contains(false) ? null : onAgreeTap,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 150),
                            child: isAgreeLoading
                                ? Theme(
                                    data: Theme.of(context).copyWith(
                                      accentColor: Colors.white,
                                    ),
                                    child: const ProgressIndicatorSmall(),
                                  )
                                : Text(
                                    "Razylaşýaryn",
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
