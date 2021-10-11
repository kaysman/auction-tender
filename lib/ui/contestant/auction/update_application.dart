import 'dart:developer';

import 'package:maliye_app/components/custom_dialog.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/label.dart';
import 'package:maliye_app/components/labeled_checkbox.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/num_to_text.dart';
import 'package:maliye_app/config/validators.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application.dart';

class UpdateApplicationPage extends StatefulWidget {
  final LotBig lot;

  const UpdateApplicationPage({Key key, @required this.lot}) : super(key: key);

  @override
  _UpdateApplicationPageState createState() => _UpdateApplicationPageState();
}

class _UpdateApplicationPageState extends State<UpdateApplicationPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isCompany = false;
  bool isLoading = false;

  // fiziki
  TextEditingController nameController = TextEditingController();
  String nameError;

  TextEditingController surnameController = TextEditingController();
  String surnameError;

  TextEditingController fatherNameController = TextEditingController();
  String fatherNameError;

  TextEditingController passportNoController = TextEditingController();
  String passportNoError;

  TextEditingController addressController = TextEditingController();
  String addressError;

  // yuridiki
  TextEditingController companyNameController = TextEditingController();
  String companyNameError;

  String companyType;
  String companyTypeError;

  TextEditingController companyAddressController = TextEditingController();
  String companyAddressError;

  TextEditingController joinerNameController = TextEditingController();
  String joinerNameError;

  TextEditingController joinerSurnameController = TextEditingController();
  String joinerSurnameError;

  TextEditingController joinerFathernameController = TextEditingController();
  String joinerFathernameError;

  TextEditingController joinerProfessionController = TextEditingController();
  String joinerProfessionError;

  TextEditingController joinerPassportNoController = TextEditingController();
  String joinerPassportNoError;

  // common factors
  bool fromInternet = false;
  bool whenWinner = true;
  bool agreeTerms = true;
  bool yazgy = true;
  bool signature = true;
  bool buying = true;
  bool responsible = true;

  TextEditingController tenPercentManatController = TextEditingController();
  String tenPercentManatError;
  TextEditingController tenPercentCoinController =
      TextEditingController(text: "0");
  String tenPercentCoinError;
  TextEditingController tenPercentWordController = TextEditingController();

  TextEditingController taxManatController = TextEditingController();
  String taxManatError;
  TextEditingController taxCoinController = TextEditingController(text: "0");
  String taxCoinError;
  TextEditingController taxWordController = TextEditingController();

  TextEditingController totayPaymentController = TextEditingController();
  TextEditingController totayPaymentWordController = TextEditingController();

  // bank
  TextEditingController bankController = TextEditingController();
  String bankError;

  TextEditingController accountingAccountController = TextEditingController();
  String accountingAccountError;

  TextEditingController taxCodeController = TextEditingController();
  String taxCodeError;

  TextEditingController babController = TextEditingController();
  String babError;

  TextEditingController bankAccountController = TextEditingController();
  String bankAccountError;

  buildFiziki() {
    return Column(
      children: [
        const SizedBox(height: Constants.defaultMargin),
        TextFormField(
          controller: nameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: validateHumanName,
          decoration: InputDecoration(
            labelText: "Ady",
            errorText: nameError,
          ),
          onChanged: (String v) {
            if (nameError != null) setState(() => nameError = null);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: surnameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: validateHumanName,
          decoration: InputDecoration(
            labelText: "Familiýasy",
            errorText: surnameError,
          ),
          onChanged: (String v) {
            if (surnameError != null) setState(() => surnameError = null);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: fatherNameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: "Atasynyň ady",
            errorText: fatherNameError,
          ),
          onChanged: (String v) {
            if (fatherNameError != null) setState(() => fatherNameError = null);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: addressController,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          validator: validateCommon,
          decoration: InputDecoration(
            labelText: "Ýerleşýän ýeri",
            errorText: addressError,
          ),
          onChanged: (String v) {
            if (addressError != null)
              setState(
                () => addressError = null,
              );
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passportNoController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          validator: validatePassport,
          decoration: InputDecoration(
            labelText: "Pasport belgisi",
            errorText: passportNoError,
          ),
          onChanged: (String v) {
            if (passportNoError != null) setState(() => passportNoError = null);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  buildYuridiki() {
    return Column(
      children: [
        const SizedBox(height: Constants.defaultMargin),
        TextFormField(
          controller: companyNameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: validateCompanyName,
          decoration: InputDecoration(
            labelText: "Kärhananyň ady",
            errorText: companyNameError,
          ),
          onChanged: (String v) {
            if (companyNameError != null)
              setState(() => companyNameError = null);
          },
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: companyType,
          onChanged: (String v) {
            setState(() {
              companyType = v;
            });
          },
          decoration: InputDecoration(
            labelText: "Kärhananyň görnüşi",
          ),
          items: companyTypes.map<DropdownMenuItem<String>>((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: companyAddressController,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          validator: validateCommon,
          decoration: InputDecoration(
            labelText: "Ýerleşýän ýeri",
            errorText: companyAddressError,
          ),
          onChanged: (String v) {
            if (companyAddressError != null)
              setState(
                () => companyAddressError = null,
              );
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: joinerNameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: validateHumanName,
          decoration: InputDecoration(
            labelText: "Wekiliň ady",
            errorText: joinerNameError,
          ),
          onChanged: (String v) {
            if (joinerNameError != null) setState(() => joinerNameError = null);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: joinerSurnameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: validateHumanName,
          decoration: InputDecoration(
            labelText: "Wekiliň familiýasy",
            errorText: joinerSurnameError,
          ),
          onChanged: (String v) {
            if (joinerSurnameError != null)
              setState(() => joinerSurnameError = null);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: joinerFathernameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: "Wekiliň atasynyň ady",
            errorText: joinerFathernameError,
          ),
          onChanged: (String v) {
            if (joinerFathernameError != null)
              setState(() => joinerFathernameError = null);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: joinerProfessionController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: validateCommon,
          decoration: InputDecoration(
            labelText: "Wekiliň wezipesi",
            errorText: joinerProfessionError,
          ),
          onChanged: (String v) {
            if (joinerProfessionError != null)
              setState(() => joinerProfessionError = null);
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: joinerPassportNoController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: validatePassport,
          decoration: InputDecoration(
            labelText: "Wekiliň pasport belgisi",
            errorText: joinerPassportNoError,
          ),
          onChanged: (String v) {
            if (joinerPassportNoError != null)
              setState(() => joinerPassportNoError = null);
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    var previousApplication = widget.lot.buyerApplication;

    // initialize
    nameController.text = previousApplication.general.firstname;
    surnameController.text = previousApplication.general.lastname;
    fatherNameController.text = previousApplication.general.fathername;
    passportNoController.text = previousApplication.general.passport;
    addressController.text = previousApplication.general.address;

    isCompany = previousApplication.general.isOrganization;
    companyNameController.text = previousApplication.general.name;
    companyType = previousApplication.general.type;
    companyAddressController.text = previousApplication.general.address;
    joinerNameController.text = previousApplication.general.firstname;
    joinerSurnameController.text = previousApplication.general.lastname;
    joinerFathernameController.text = previousApplication.general.fathername;
    joinerPassportNoController.text = previousApplication.general.passport;
    joinerProfessionController.text = previousApplication.general.position;

    // common factors
    fromInternet = previousApplication.publishedData == "Internet serişdeleri";

    // 10%
    String tenpercent = previousApplication.transferredMoney.toString();
    List<String> tenpercentList = tenpercent.split(".");
    tenPercentManatController.text = tenpercentList[0];
    tenPercentCoinController.text = tenpercentList[1];

    // yygym tolegi
    String yygym = previousApplication.collectionMoney.toString();
    List<String> yygymList = yygym.split(".");
    taxManatController.text = yygymList[0];
    taxCoinController.text = yygymList[1];

    // bank
    bankController.text = previousApplication.bank;
    accountingAccountController.text = previousApplication.settlementAccount;
    taxCodeController.text = previousApplication.taxCode;
    babController.text = previousApplication.bab;
    bankAccountController.text = previousApplication.bankAccount;

    // add listeners
    paymentListener();
    tenPercentManatController.addListener(paymentListener);
    taxManatController.addListener(paymentListener);
    tenPercentCoinController.addListener(paymentListener);
    taxCoinController.addListener(paymentListener);

    super.initState();
  }

  paymentListener() {
    var tenPercent = double.tryParse(tenPercentManatController.text +
            "." +
            tenPercentCoinController.text) ??
        0;
    var tax = double.tryParse(
            taxManatController.text + "." + taxCoinController.text) ??
        0;
    var total = (tenPercent + tax).toString();
    setState(() {
      tenPercentWordController.text =
          numberToTextConverter(tenPercent.toString());
      taxWordController.text = numberToTextConverter(tax.toString());
      totayPaymentController.text = total;
      totayPaymentWordController.text =
          numberToTextConverter(totayPaymentController.text);
    });
  }

  @override
  void dispose() {
    // dispose controllers
    super.dispose();
  }

  buildLockIcon() {
    return Icon(
      Icons.lock,
      color: const Color(0xA28F8F8F),
      size: 16,
    );
  }

  buildPenIcon() {
    return Icon(
      Icons.edit,
      color: const Color(0xA20A19A0),
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool noteIsEmpty =
        widget.lot.buyerApplication.applicationSubmission.note.isEmpty;
    String applicationNote = noteIsEmpty
        ? "ýok"
        : widget.lot.buyerApplication.applicationSubmission.note;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: MyAppBar(context: context),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0.3,
            child: Container(
              color: Colors.white,
              padding: Constants.innerPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: size.width,
                    child: Card(
                      color: Colors.red.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Bellik: $applicationNote",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CenterelizedLabel(
                    text: "SIZ HAÝSY ŞAHS BOLUP\n GATNAŞÝARSYŇYZ?",
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          if (isCompany) {
                            setState(() => isCompany = false);
                          }
                        },
                        child: Container(
                          child: Text(
                            'Fiziki',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isCompany
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          width: 100,
                          decoration: BoxDecoration(
                            color: isCompany
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (!isCompany) {
                            setState(() => isCompany = true);
                          }
                        },
                        child: Container(
                          child: Text(
                            'Ýuridiki',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isCompany
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          width: 100,
                          decoration: BoxDecoration(
                            color: isCompany
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    child: isCompany ? buildYuridiki() : buildFiziki(),
                  ),
                  const SizedBox(height: 16),
                  CenterelizedLabel(
                    text:
                        "Siz bu geçiriljek bäsleşikli söwda\n hakynda nireden öwrendiňiz?",
                  ),
                  ListTileTheme(
                    contentPadding: const EdgeInsets.all(0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: RadioListTile<bool>(
                              title: Text(
                                "Internet serişdeleri",
                                style: TextStyle(fontSize: 13),
                              ),
                              value: true,
                              groupValue: fromInternet,
                              onChanged: (bool value) {
                                setState(() {
                                  fromInternet = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: RadioListTile<bool>(
                              title: Text(
                                "Bitarap Türkmenistan gazeti",
                                style: TextStyle(fontSize: 12),
                              ),
                              value: false,
                              groupValue: fromInternet,
                              onChanged: (bool value) {
                                setState(() {
                                  fromInternet = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CenterelizedLabel(text: "Lot'yñ başlangyç bahasynyñ 10%-i"),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tenPercentManatController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: validateCommon,
                          decoration: InputDecoration(
                            labelText: "Manat",
                            errorText: tenPercentManatError,
                            suffixIcon: buildPenIcon(),
                          ),
                          onChanged: (String v) {
                            if (tenPercentManatError != null)
                              setState(() => tenPercentManatError = null);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: tenPercentCoinController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: "Teññe",
                            errorText: tenPercentCoinError,
                            suffixIcon: buildPenIcon(),
                          ),
                          onChanged: (String v) {
                            if (tenPercentCoinError != null)
                              setState(() => tenPercentCoinError = null);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: tenPercentWordController,
                    readOnly: true,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      labelText: "Ýazgy",
                      suffixIcon: buildLockIcon(),
                    ),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  CenterelizedLabel(text: "Ýörite ýygym"),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: taxManatController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: validateCommon,
                          decoration: InputDecoration(
                            labelText: "Manat",
                            errorText: taxManatError,
                            suffixIcon: buildPenIcon(),
                          ),
                          onChanged: (String v) {
                            if (taxManatError != null)
                              setState(() => taxManatError = null);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: taxCoinController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: "Teňňe",
                            errorText: taxCoinError,
                            suffixIcon: buildPenIcon(),
                          ),
                          onChanged: (String v) {
                            if (taxCoinError != null)
                              setState(() => taxCoinError = null);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: taxWordController,
                    readOnly: true,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      labelText: "Ýazgy",
                      suffixIcon: buildLockIcon(),
                    ),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  CenterelizedLabel(
                      text:
                          "Lot'yñ başlangyç bahasynyñ 10%-i we ýörite ýygymyñ jemi"),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: totayPaymentController,
                    readOnly: true,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      labelText: "San",
                      suffixIcon: buildLockIcon(),
                    ),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: totayPaymentWordController,
                    readOnly: true,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      labelText: "Ýazgy",
                      suffixIcon: buildLockIcon(),
                    ),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  CenterelizedLabel(
                      text:
                          " Bäsleşikli söwda gatnaşmak üçin\n aşakdaky görekezilenler bilen\n tanyşyň we razylaşýanlygyňyz\n hakynda bellik ediň"),
                  const SizedBox(height: 12),
                  LabeledCheckbox(
                    label:
                        "Bildirişde beýan edilen söwdalaryň şertlerine we olaryň  sanly geçiriliş kadalaryny berjaý etmäge; Men ýeňiji diýip yglan edilen ýagdaýynda söwdalaryň netijesi baradaky ýazga gol çekmäge, şondan soňra 20 (ýigrimi) iş gününden giç bolmadyk möhletde satyjy bilen hususylaşdyrylan obýekti  satyn almak-satmak barada şertnama baglaşmaga;",
                    value: whenWinner,
                    onChanged: (bool v) => setState(() => whenWinner = v),
                  ),
                  const SizedBox(height: 12),
                  LabeledCheckbox(
                    label: "Şertnamada bellenilen borçlary ýerine ýetirmäge;",
                    value: agreeTerms,
                    onChanged: (bool v) => setState(() => agreeTerms = v),
                  ),
                  CenterelizedLabel(
                    text:
                        "Bäsleşikli söwda gatnaşmak üçin \naşakdaky görekezilenler bilen\ntanyşyň we razylaşýanlygyňyz\nhakynda bellik ediň",
                  ),
                  const SizedBox(height: 12),
                  LabeledCheckbox(
                    label:
                        "Eger-de meniň  gatnaşyja bildirilýän talaplara laýyk gelmeýändigim ýüze çykarylan halatynda söwdalara gattnaşmakdan mahrum edilmegim bilen, eger-de meniň söwdalarda ýeňiji bolan halatymda men tarapyndan satyn almak-satmak baradaky gol çekilen şertnamanyň we ýazgynyň güýçsiz diýlip ykrar edilmegim bilen;",
                    value: yazgy,
                    onChanged: (bool v) => setState(() => yazgy = v),
                  ),
                  const SizedBox(height: 12),
                  LabeledCheckbox(
                    label:
                        "Eger-de men söwdalaryň ýazgysyna gol çekmesem ýa-da satyn almak satmak baradaky şertnama baglaşylanda, meniň satyn almak-satmak baradaky şertnama boýunça borçlarymy ýerine ýetirmesem ýa-da göwnejaý ýerine ýetirmesem, eger-de şu ýüz tutma bellige alnandan soň meniň ýazykly hereketlerimiň netijesiniň subtnamasy hökmünde satuwa gataşyja bildirilýän talaplara laýyk gelmeýändigim ýüze çykarylan halatynda meniň öňünden beren pulumyň  jemi maňa gaýtarylyp berilmejekligi bilen;",
                    value: signature,
                    onChanged: (bool v) => setState(() => signature = v),
                  ),
                  const SizedBox(height: 12),
                  LabeledCheckbox(
                    label:
                        "Men söwdalaryň ýeňijisi diýlip yglan edilen halatymda ýa-da satyn almak satmak baradaky şertnama gol çekilýänçä şu ýüz tutma satuwlaryň netijesi hakyndaky ýazgy bilen bilelikde biziň aramyzda şertnamanyň güýjüne eýe bolýar;",
                    value: buying,
                    onChanged: (bool v) => setState(() => buying = v),
                  ),
                  const SizedBox(height: 12),
                  LabeledCheckbox(
                    label:
                        "Men şu LOT-a gatnaşmak üçin ýokarda ýazan maglumatlarymy hem-de olarda getirilen tassyklamalary we parametrleri öz golum bilen tassyklaýaryn. Tabşyrylan resminamalaryň ýerine ýetirilişinde bolup biljek töwekgelçiliklere we çykdajylara düşünýärin hem-de olary öz üstüme alýaryn.",
                    value: responsible,
                    onChanged: (bool v) => setState(() => responsible = v),
                  ),
                  const SizedBox(height: 12),
                  CenterelizedLabel(
                    text: "Dalaşgäriň töleg rekwizitleri:",
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bankController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: validateCommon,
                    decoration: InputDecoration(
                      labelText: "Bank",
                      errorText: bankError,
                    ),
                    onChanged: (String v) {
                      if (bankError != null) setState(() => bankError = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bankAccountController,
                    keyboardType: TextInputType.name,
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: accountingAccountController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: validateCommon,
                    decoration: InputDecoration(
                      labelText: "Hasaplaşyk hasaby",
                      errorText: accountingAccountError,
                    ),
                    onChanged: (String v) {
                      if (accountingAccountError != null)
                        setState(() => accountingAccountError = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: taxCodeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: validateCommon,
                    decoration: InputDecoration(
                      labelText: "Salgyt kody",
                      errorText: taxCodeError,
                    ),
                    onChanged: (String v) {
                      if (taxCodeError != null)
                        setState(() => taxCodeError = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: babController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: validateCommon,
                    decoration: InputDecoration(
                      labelText: "BAB",
                      errorText: babError,
                    ),
                    onChanged: (String v) {
                      if (babError != null) setState(() => babError = null);
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: size.width * 0.5,
                    child: Center(
                      child: AbsorbPointer(
                        absorbing: isLoading,
                        child: ElevatedButton(
                          onPressed: onSubmitTap,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  onSubmitTap() async {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    if (_formKey.currentState.validate() &&
        ![whenWinner, agreeTerms, yazgy, signature, buying].contains(false)) {
      _formKey.currentState.save();

      Map<String, dynamic> data = {
        "general": {
          "is_organization": isCompany,
          "name": isCompany ? companyNameController.text : null,
          "type": isCompany ? companyType : null,
          "address": isCompany
              ? companyAddressController.text
              : addressController.text,
          "position": isCompany ? joinerProfessionController.text : null,
          "firstname":
              isCompany ? joinerNameController.text : nameController.text,
          "lastname":
              isCompany ? joinerSurnameController.text : surnameController.text,
          "patronymic": isCompany
              ? joinerFathernameController.text
              : fatherNameController.text,
          "passport": isCompany
              ? joinerPassportNoController.text
              : passportNoController.text,
        },
        "published_data": fromInternet
            ? "Internet serişdeleri"
            : "Bitarap Türkmenistan gazeti",
        "transferred_money": double.tryParse(tenPercentManatController.text +
            "." +
            tenPercentCoinController.text),
        "bank": bankController.text,
        "settlement_account": accountingAccountController.text,
        "tax_code": taxCodeController.text,
        "bab": babController.text,
        "bank_account": bankAccountController.text,
        "collection_money": double.tryParse(
            taxManatController.text + "." + taxCoinController.text),
        "total_money": double.tryParse(totayPaymentController.text),
      };

      setState(() => isLoading = true);

      Dio dio = Dio();

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("access_token");
        var response = await dio.put(
          Apis.applicationApi(widget.lot.buyer_id),
          data: data,
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }),
        );

        log(response.data.toString());

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
                child: CustomDialog(title: "Ýüz tutmañyzy täzelediñiz!"),
              );
            },
          );
        }
      } on DioError catch (e) {
        setState(() => isLoading = false);
        if (e.response.statusCode == 401) {
          bool updated = await updateAccessToken(context);
          if (updated) setState(() {});
        }

        showSnackbar(context, e.response.toString());
      }
    } else {
      showSnackbar(context, "Maglumatlary doly we dogry girizin.");
    }
  }
}
