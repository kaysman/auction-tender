import 'package:maliye_app/components/custom_dialog.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/validators.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChangePasswordPage extends StatefulWidget {
  final String token;

  const ChangePasswordPage({
    Key key,
    @required this.token,
  }) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _passwordController = TextEditingController();
  String passwordError;

  TextEditingController _passwordConfirmationController =
      TextEditingController();
  String passwordConfirmationError;

  final _otpController = TextEditingController();
  String otpError;
  String otpMessage = "";

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                      height: size.height * 0.12,
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
                top: size.height * 0.18,
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
                          SizedBox(
                            width: size.width,
                            child: TextFormField(
                              controller: _passwordController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              obscureText: true,
                              validator: validatePassword,
                              decoration: InputDecoration(
                                errorText: passwordError,
                                labelText: "Täze açar sözi",
                              ),
                              onChanged: (String v) {
                                if (passwordError != null)
                                  setState(() => passwordError = null);
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: size.width,
                            child: TextFormField(
                              controller: _passwordConfirmationController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              validator: (String value) {
                                if (value == null || value.isEmpty) {
                                  return 'Boş goýmaly däl';
                                } else if (value != _passwordController.text) {
                                  return 'Açar sözüni gabat getirmeli';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                errorText: passwordConfirmationError,
                                labelText: "Täze açar sözüni gaýtalaň",
                              ),
                              onChanged: (String v) {
                                if (passwordConfirmationError != null)
                                  setState(
                                      () => passwordConfirmationError = null);
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: size.width,
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              validator: validateCommon,
                              decoration: InputDecoration(
                                errorText: otpError,
                                labelText: "SMS Kod",
                              ),
                              onChanged: (String v) {
                                if (otpError != null)
                                  setState(() => otpError = null);
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6)
                              ],
                            ),
                          ),
                          const SizedBox(height: Constants.defaultMargin),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: size.width * 0.5,
                              child: AbsorbPointer(
                                absorbing: isLoading,
                                child: ElevatedButton(
                                  onPressed: onChangePasswordTap,
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 150),
                                    child: isLoading
                                        ? const ProgressIndicatorSmall(
                                            color: Colors.white)
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onChangePasswordTap() async {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() => isLoading = true);

      Map<String, dynamic> data = {
        "password": _passwordController.text,
        "password_confirmation": _passwordConfirmationController.text,
        "code": _otpController.text,
      };

      Dio dio = Dio();

      try {
        Response response = await dio.post(
          Apis.changePasswordApi,
          data: data,
          options: Options(
            headers: {"Authorization": "Bearer ${widget.token}"},
          ),
        );

        setState(() => isLoading = false);

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 40.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CustomDialog(title: "Açar sözüňiz üýtgedildi"),
              );
            },
          );
        }
      } on DioError catch (e) {
        debugPrint(e.response?.statusCode?.toString());
        setState(() => isLoading = false);

        if (e.response?.statusCode == 403) {
          showSnackbar(context, "Maglumatlary barlaň we täzeden synanşyň.");
          return;
        }

        showSnackbar(context, e.response.toString());
        print(e);
      }
    }
  }
}
