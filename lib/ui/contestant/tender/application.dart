import 'dart:developer';
import 'dart:io';

import 'package:maliye_app/components/custom_dialog.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/text_fields.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/config/validators.dart';
import 'package:maliye_app/ui/contestant/auction/application.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'doc_upload.dart';

class TenderApplicationPage extends StatefulWidget {
  final int seller_id;
  final int lot_id;
  final bool hasNext;

  const TenderApplicationPage(
      {Key key,
      @required this.seller_id,
      @required this.lot_id,
      @required this.hasNext})
      : super(key: key);

  @override
  _TenderApplicationPageState createState() => _TenderApplicationPageState();
}

class _TenderApplicationPageState extends State<TenderApplicationPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // name
  final nameController = TextEditingController();
  String nameError;

  // type
  String companyType;

  // address
  final addressController = TextEditingController();
  String addressError;

  // fax
  final faxController = TextEditingController();
  String faxError;

  // phone
  final phoneController = TextEditingController();
  String phoneError;

  // email
  final emailController = TextEditingController();
  String emailError;

  // patent date
  DateTime selectedDate = DateTime.now();

  // patent place
  final patentPlaceController = TextEditingController();
  String patentPlaceError;

  // patent organization
  final patentOrganizationController = TextEditingController();
  String patentOrgError;

  // basis capital
  final basisCapitalController = TextEditingController();
  String basisCapitalError;

  // employees
  final employeesController = TextEditingController();
  String employeesError;

  // manager
  final managerController = TextEditingController();
  String managerError;

  // accountant
  final accountantController = TextEditingController();
  String accountantError;

  // bank name
  final bankNameController = TextEditingController();
  String bankNameError;

  // bank account
  final bankAccountController = TextEditingController();
  String bankAccountError;

  // bank settlement account
  final bankSettlementAccountController = TextEditingController();
  String bankSettlementAccountError;

  // bank tax code
  final bankTaxCodeController = TextEditingController();
  String bankTaxCodeError;

  // bank bab
  final bankBabController = TextEditingController();
  String bankBabError;

  // business
  final businessController = TextEditingController();
  String businessError;

  // clients
  final clientsController = TextEditingController();
  String clientsError;
  List<String> clientsList = [];

  // info
  final infoController = TextEditingController();
  String infoError;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String selecteddate = selectedDate.format("dd-MM-yyyy");
    return Scaffold(
      appBar: Platform.isIOS
          ? AppBar(
              brightness: Brightness.dark,
              centerTitle: false,
              title: Row(
                children: [
                  PngIcons.barLogo,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Türkmenistanyň Maliýe we Ykdysadyýet Ministrligi'
                            .toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            )
          : MyAppBar(context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0.3,
              child: Container(
                color: Colors.white,
                padding: Constants.innerPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const ApplicationLabel(
                      text:
                          "Mümkin bolan üpjün edijiniň (potratçynyň) doly ady",
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: validateHumanName,
                      decoration: InputDecoration(
                        labelText: "Potratçynyñ ady",
                        errorText: nameError,
                      ),
                      onChanged: (String v) {
                        if (nameError != null) setState(() => nameError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(
                      text:
                          "Mümkin bolan üpjün edijiniň (potratçynyň) edarasynyň salgysy, faksy, telefony we elektron poçtasy",
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: addressController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "Edarasynyñ salgysy",
                        errorText: addressError,
                      ),
                      onChanged: (String v) {
                        if (addressError != null)
                          setState(() => addressError = null);
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: Text(
                          "Edarasynyñ faksy",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PhoneTextField(
                      controller: faxController,
                      phoneError: faxError,
                      isRequired: false,
                      textInputAction: TextInputAction.next,
                      onChanged: (v) {
                        if (faxError != null) {
                          setState(() => faxError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: Text(
                          "Edarasynyñ telefon belgisi",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    PhoneTextField(
                      controller: phoneController,
                      phoneError: phoneError,
                      textInputAction: TextInputAction.next,
                      onChanged: (v) {
                        if (phoneError != null) {
                          setState(() => phoneError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Edarasynyñ elektron poçtasy",
                        errorText: emailError,
                      ),
                      onChanged: (String v) {
                        if (emailError != null)
                          setState(() => emailError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(
                      text:
                          "Kärhananyň ýa-da telekeçilik patentiniň bellige alnan senesi, ýeri we edarasy",
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2040),
                          helpText: 'Sene saýla',
                          cancelText: 'Aýyr',
                          confirmText: 'Saýla',
                        );
                        if (picked != null && picked != selectedDate)
                          setState(() {
                            selectedDate = picked;
                          });
                      },
                      child: SizedBox(
                        width: size.width,
                        height: 48,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFDDDDDD)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(selecteddate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: patentPlaceController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "Ýeri",
                        errorText: patentPlaceError,
                      ),
                      onChanged: (String v) {
                        if (patentPlaceError != null)
                          setState(() => patentPlaceError = null);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: patentOrganizationController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "Edarasy",
                        errorText: patentOrgError,
                      ),
                      onChanged: (String v) {
                        if (patentOrgError != null)
                          setState(() => patentOrgError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(text: "Guramaçylyk-hukuk görnüşi"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: companyType,
                      onChanged: (String v) {
                        setState(() {
                          companyType = v;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Guramaçylyk-hukuk görnüşi",
                      ),
                      items: companyTypes
                          .map<DropdownMenuItem<String>>((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(
                        text: "Esaslyk maýanyň möçberi (manat)"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: basisCapitalController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "Esaslyk maýanyñ möçberi",
                        errorText: basisCapitalError,
                      ),
                      onChanged: (String v) {
                        if (basisCapitalError != null)
                          setState(() => basisCapitalError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(text: "Işgärleriniñ sany"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: employeesController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (String value) {
                        if (value == null || value.isEmpty) {
                          return 'Boş goýmaly däl';
                        } else if ((double.tryParse(value) < 1) ||
                            (double.tryParse(value) > 10000)) {
                          return "min 1 we max 10 000 işgär";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Işgärleriniñ sany",
                        errorText: employeesError,
                      ),
                      onChanged: (String v) {
                        if (employeesError != null)
                          setState(() => employeesError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(text: "Ýolbaşçynyñ F.A.Aa"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: managerController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Ýolbaşçynyñ F.A.Aa",
                        errorText: managerError,
                      ),
                      onChanged: (String v) {
                        if (managerError != null)
                          setState(() => managerError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(text: "Baş hasapçynyñ F.A.Aa"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: accountantController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Baş hasapçynyñ F.A.Aa",
                        errorText: accountantError,
                      ),
                      onChanged: (String v) {
                        if (accountantError != null)
                          setState(() => accountantError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(text: "Bank maglumatlary"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bankNameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "Bank",
                        errorText: bankNameError,
                      ),
                      onChanged: (String v) {
                        if (bankNameError != null)
                          setState(() => bankNameError = null);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bankAccountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "Bank hasaby",
                        errorText: bankAccountError,
                      ),
                      onChanged: (String v) {
                        if (bankAccountError != null)
                          setState(() => bankAccountError = null);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bankSettlementAccountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "Hasaplaşyk hasaby",
                        errorText: bankSettlementAccountError,
                      ),
                      onChanged: (String v) {
                        if (bankSettlementAccountError != null)
                          setState(() => bankSettlementAccountError = null);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bankTaxCodeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "Salgyt kody",
                        errorText: bankTaxCodeError,
                      ),
                      onChanged: (String v) {
                        if (bankTaxCodeError != null)
                          setState(() => bankTaxCodeError = null);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bankBabController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: validateCommon,
                      decoration: InputDecoration(
                        labelText: "BAB",
                        errorText: bankBabError,
                      ),
                      onChanged: (String v) {
                        if (bankBabError != null)
                          setState(() => bankBabError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(
                      text:
                          "Işiñ esasy görnüşleri we ýerine ýetirilen tabşyryklar barada gysgaça häsiýetnama",
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: businessController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Häsiýetnama",
                        errorText: businessError,
                      ),
                      onChanged: (String v) {
                        if (businessError != null)
                          setState(() => businessError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    const ApplicationLabel(
                      text: "Esasy müşderileriniñ sanawy we gaýry maglumatlar",
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: clientsController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: "Esasy müşderileriniñ sanawy",
                        errorText: clientsError,
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (!clientsList.contains(clientsController.text) &&
                                clientsController.text.isNotEmpty)
                              clientsList.add(clientsController.text);
                            clientsController.text = "";
                            setState(() {});
                          },
                          icon: Icon(Icons.add_outlined, size: 28),
                        ),
                      ),
                      onChanged: (String v) {
                        if (clientsError != null)
                          setState(() => clientsError = null);
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        padding: const EdgeInsets.only(top: 8, left: 6),
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          children: List.generate(clientsList.length, (i) {
                            return Container(
                              width: size.width,
                              padding: const EdgeInsets.only(top: 6, bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 10,
                                    child: Text(
                                      "${i + 1}. ${clientsList[i]}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (clientsList
                                            .contains(clientsList[i]))
                                          clientsList.remove(clientsList[i]);
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: const Color(0xFFFF7373),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: infoController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      minLines: 3,
                      maxLines: 8,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12),
                        labelText: "Gaýry maglumatlar",
                        errorText: infoError,
                      ),
                      onChanged: (String v) {
                        if (infoError != null) setState(() => infoError = null);
                      },
                    ),
                    const SizedBox(height: 18),
                    AbsorbPointer(
                      absorbing: isLoading,
                      child: SizedBox(
                        width: size.width * 0.5,
                        child: ElevatedButton(
                          onPressed: onSendTap,
                          style: ElevatedButton.styleFrom(
                            primary: const Color(Constants.appBlue),
                          ),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 150),
                            child: isLoading
                                ? const ProgressIndicatorSmall(
                                    color: Colors.white)
                                : Text(
                                    "Ugrat",
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
            ),
          ],
        ),
      ),
    );
  }

  onSendTap() async {
    hideKeyboard();

    if (isLoading) {
      print(selectedDate.format("dd-MM-yyyy"));
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map<String, dynamic> data = {
        "main": {
          "name": nameController.text,
          "type": companyType,
          "address": addressController.text,
          if (faxController.text.isNotEmpty) "fax": "+993" + faxController.text,
          "phone": "+993" + phoneController.text,
          "email": emailController.text,
          "patent_date": selectedDate.toString(),
          "patent_place": patentPlaceController.text,
          "patent_organization": patentOrganizationController.text,
        },
        "basis_capital": basisCapitalController.text,
        "employees": int.tryParse(employeesController.text) ?? 0,
        "manager": managerController.text,
        "accountant": accountantController.text,
        "bank": {
          "name": bankNameController.text,
          "bank_account": bankAccountController.text,
          "settlement_account": bankSettlementAccountController.text,
          "tax_code": bankTaxCodeController.text,
          "bab": bankBabController.text,
        },
        "business": businessController.text,
        "clients": clientsList,
        "info": infoController.text,
      };

      setState(() => isLoading = true);

      Dio dio = Dio();

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("access_token");
        var response = await dio.post(
          Apis.tenderApplicationApi(widget.seller_id),
          data: data,
          options: Options(
            headers: {
              "Authorization": "Bearer $token",
            },
            contentType: "application/json",
          ),
        );

        print(response.statusCode);
        log(response.data.toString());
        setState(() => isLoading = false);

        if (response.statusCode == 201) {
          if (widget.hasNext)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TendorDocumentsUpload(
                  lot_id: widget.lot_id,
                  seller_id: widget.seller_id,
                ),
              ),
            );
          else
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 40.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: CustomDialog(title: "Ýüz tutmañyz ýüklenildi!"),
                );
              },
            );
        }
      } on DioError catch (e) {
        debugPrint(e.response.statusCode.toString());
        setState(() => isLoading = false);
        if (e.response.statusCode == 401) {
          bool updated = await updateAccessToken(context);
          if (updated) setState(() {});
        }

        if (e.response.statusCode == 409) {
          showSnackbar(context, "Siz öň ýüz tutdyňyz");
        } else {
          showSnackbar(context,
              "Ýalňyşlyk ýüze çykdy. Maglumatlary doly barlaň we täzeden synanşyň.");
        }
      }
    }
  }
}

class ApplicationLabel extends StatelessWidget {
  const ApplicationLabel({Key key, this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF004794),
          ),
        ),
      ),
    );
  }
}
