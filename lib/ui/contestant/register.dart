import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/input_formatter.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/text_fields.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/validators.dart';
import 'package:maliye_app/models/user.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/common/index.dart';
import 'package:maliye_app/ui/contestant/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const TextStyle titleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Color(Constants.appBlue),
);

const List<String> i_list = ['I', 'II'];
const List<String> velayats = ['AŞ', 'AH', 'MR', 'DZ', 'BN', 'LB'];

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isRegistered = false;
  int registered_user_id;

  final _surnameController = TextEditingController();
  String _surnameError;

  final _nameController = TextEditingController();
  String _nameError;

  final _fatherNameController = TextEditingController();
  String _fatherNameError;

  final _passportController = TextEditingController();
  String _passportNoError;
  String selected_i;
  String selected_velayat;

  final _phoneController = TextEditingController();
  String _phoneError;

  final _passwordController = TextEditingController();
  String _passwordError;

  final _passwordConfirmationController = TextEditingController();
  String _passwordConfirmationError;

  final _otpController = TextEditingController();
  String otpError;
  String otpMessage = "";

  @override
  void initState() {
    selected_i = i_list.first;
    selected_velayat = velayats.first;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: MyAppBar(context: context),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(height: size.height * 1.25),
              Container(
                width: double.infinity,
                height: size.height * 0.35,
                decoration: BoxDecoration(
                  color: Color(Constants.appBlue),
                  image: DecorationImage(
                    image: AssetImage("assets/png/nagysh.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    SvgPicture.asset("assets/svg/nagysh.svg",
                        height: size.height * 0.13),
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
                top: size.height * 0.18,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 22,
                      ),
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 8,
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
                            "Agza Bolmak",
                            style: TextStyle(
                              fontSize: 1,
                              fontWeight: FontWeight.bold,
                              color: Color(Constants.appBlue),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _surnameController,
                            validator: validateHumanName,
                            enabled: !isRegistered,
                            decoration: InputDecoration(
                              labelText: "Familiýasy",
                              errorText: _surnameError,
                              suffixIcon: isRegistered ? buildLockIcon() : null,
                            ),
                            onChanged: (String v) {
                              if (_surnameError != null)
                                setState(() => _surnameError = null);
                            },
                          ),
                          const SizedBox(height: Constants.defaultMargin8),
                          TextFormField(
                            controller: _nameController,
                            enabled: !isRegistered,
                            validator: validateHumanName,
                            decoration: InputDecoration(
                              labelText: "Ady",
                              errorText: _nameError,
                              suffixIcon: isRegistered ? buildLockIcon() : null,
                            ),
                            onChanged: (String v) {
                              if (_nameError != null)
                                setState(() => _nameError = null);
                            },
                          ),
                          const SizedBox(height: Constants.defaultMargin8),
                          TextFormField(
                            controller: _fatherNameController,
                            enabled: !isRegistered,
                            decoration: InputDecoration(
                              labelText: "Atasynyň ady",
                              errorText: _fatherNameError,
                              suffixIcon: isRegistered ? buildLockIcon() : null,
                            ),
                            onChanged: (String v) {
                              if (_fatherNameError != null)
                                setState(() => _fatherNameError = null);
                            },
                          ),
                          const SizedBox(height: Constants.defaultMargin8),
                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 54,
                                  child: DropdownButtonFormField<String>(
                                    value: selected_i,
                                    isDense: true,
                                    onChanged: (String v) {
                                      setState(() => selected_i = v);
                                    },
                                    validator: (String v) {
                                      if (v.isEmpty) return "Boş goýmaly däl";
                                      return null;
                                    },
                                    items: i_list
                                        .map<DropdownMenuItem<String>>((item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 65,
                                  child: DropdownButtonFormField<String>(
                                    value: selected_velayat,
                                    isDense: true,
                                    onChanged: (String v) {
                                      setState(() => selected_velayat = v);
                                    },
                                    validator: (String v) {
                                      if (v.isEmpty) return "Boş goýmaly däl";
                                      return null;
                                    },
                                    items: velayats
                                        .map<DropdownMenuItem<String>>((item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _passportController,
                                    enabled: !isRegistered,
                                    validator: validateCommon,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "Pasport Belgisi",
                                      prefix: Text(
                                          "$selected_i-$selected_velayat "),
                                      errorText: _passportNoError,
                                      suffixIcon:
                                          isRegistered ? buildLockIcon() : null,
                                    ),
                                    onChanged: (String v) {
                                      if (_passportNoError != null)
                                        setState(() => _passportNoError = null);
                                    },
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(7),
                                      UpperCaseTextFormatter(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Constants.defaultMargin8),
                          PhoneTextField(
                            controller: _phoneController,
                            enabled: !isRegistered,
                            suffix: isRegistered ? buildLockIcon() : null,
                            phoneError: _phoneError,
                            onChanged: (String v) {
                              if (_phoneError != null)
                                setState(() => _phoneError = null);
                            },
                          ),
                          const SizedBox(height: Constants.defaultMargin8),
                          TextFormField(
                            controller: _passwordController,
                            enabled: !isRegistered,
                            validator: validatePassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Açar sözi",
                              errorText: _passwordError,
                              suffixIcon: isRegistered ? buildLockIcon() : null,
                            ),
                            onChanged: (String v) {
                              if (_passwordError != null)
                                setState(() => _passwordError = null);
                            },
                          ),
                          const SizedBox(height: Constants.defaultMargin8),
                          TextFormField(
                            controller: _passwordConfirmationController,
                            enabled: !isRegistered,
                            obscureText: true,
                            validator: (String value) {
                              if (value == null || value.isEmpty) {
                                return 'Boş goýmaly däl';
                              } else if (value != _passwordController.text) {
                                return 'Paroly gabat getirmeli';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Açar sözüni gaýtalaň",
                              errorText: _passwordConfirmationError,
                              suffixIcon: isRegistered ? buildLockIcon() : null,
                            ),
                            onChanged: (String v) {
                              if (_passwordConfirmationError != null)
                                setState(
                                    () => _passwordConfirmationError = null);
                            },
                          ),
                          const SizedBox(height: Constants.defaultMargin8),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 100),
                            child: isRegistered
                                ? TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    validator: validateOtp,
                                    decoration: InputDecoration(
                                      labelText: "SMS Kod",
                                      errorText: otpError,
                                    ),
                                    onChanged: (String v) {
                                      if (otpError != null)
                                        setState(() => otpError = null);
                                    },
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                  )
                                : Container(),
                          ),
                          const SizedBox(height: Constants.defaultMargin8),
                          if (isRegistered)
                            Row(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: 40,
                                  ),
                                  child: Icon(
                                    Icons.info,
                                    color: Colors.orange,
                                  ),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: otpMessage,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: size.width * 0.5,
                            child: AbsorbPointer(
                              absorbing: isLoading,
                              child: ElevatedButton(
                                onPressed: isRegistered
                                    ? onOtpSubmitTap
                                    : onRegisterTap,
                                style: ElevatedButton.styleFrom(
                                  primary: const Color(Constants.appBlue),
                                ),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 150),
                                  child: isLoading
                                      ? const ProgressIndicatorSmall(
                                          color: Colors.white)
                                      : Text(
                                          isRegistered
                                              ? "Tassyklamak"
                                              : "Agza bolmak",
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
                    const SizedBox(height: Constants.defaultMargin8),
                    SizedBox(
                      width: size.width * 0.5,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => LoginPage(
                              showAppBar: true,
                              willPop: true,
                            ),
                          ),
                        ),
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
                                horizontal: 14, vertical: 12),
                            child: Text(
                              'Şahsy otaga girmek',
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
  }

  buildLockIcon() {
    return Icon(
      Icons.lock,
      color: Color(0xff0057B1),
    );
  }

  onRegisterTap() {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() => isLoading = true);
      registerUser();
    }
  }

  Future registerUser() async {
    Map<String, dynamic> data = {
      "firstname": _nameController.text,
      "lastname": _surnameController.text,
      "patronymic": _fatherNameController.text,
      "passport": "$selected_i-$selected_velayat ${_passportController.text}",
      "phone": _phoneController.text,
      "password": _passwordController.text,
    };

    Dio dio = Dio();

    try {
      Response registerResponse = await dio.post(
        Apis.userRegister,
        data: data,
      );

      print(registerResponse);

      setState(() => isLoading = false);

      if (registerResponse.statusCode == 201) {
        setState(() {
          isRegistered = true;
          otpMessage = registerResponse.data['message'];
          registered_user_id = registerResponse.data['id'];
        });
      }
    } on DioError catch (e) {
      setState(() => isLoading = false);
      print(e);
      log(e.response.toString());

      if (e.response.statusCode == 409) {
        return showSnackbar(
            context, "Bu telefon belgiden agza bolnan, girmegiñizi ha");
      } else {
        return showSnackbar(context, e.toString());
      }
    }
  }

  onOtpSubmitTap() async {
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
        Response otpResponse = await dio.post(
          Apis.userActivate,
          data: {
            "id": registered_user_id,
            "code": _otpController.text,
          },
        );

        setState(() => isLoading = false);

        log(otpResponse.data.toString());

        if (otpResponse.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString("access_token", otpResponse.data['token']);
          prefs.setString("refresh_token", otpResponse.data['refresh_token']);

          // save user preferences
          prefs.setString(
              "user", jsonEncode(User.fromJson(otpResponse.data['data'])));
          apiAuth.setUser(User.fromJson(otpResponse.data['data']));

          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => IndexPage()),
              (route) => false,
            );
          });
        }
      } on DioError catch (e) {
        setState(() => isLoading = false);
        print(e);
        showSnackbar(context, e.response.toString());
      }
    }
  }
}
