import 'dart:developer';

import 'package:maliye_app/components/cached_image.dart';
import 'package:maliye_app/components/card_widget.dart';
import 'package:maliye_app/components/custom_dialog.dart';
import 'package:maliye_app/components/glow_behavior.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/labels.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/submission_status_card.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:maliye_app/models/document.dart';
import 'package:maliye_app/models/document_submission.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/providers/auction_list.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application.dart';
import 'update_application.dart';
import 'declined_files.dart';
import 'lot_detail.dart';
import 'required_docs.dart';
import '../login.dart';

class ThreeStepPage extends StatefulWidget {
  final int lot_id;
  final bool isFinished;

  const ThreeStepPage({
    Key key,
    this.lot_id,
    this.isFinished = false,
  }) : super(key: key);

  @override
  _ThreeStepPageState createState() => _ThreeStepPageState();
}

class _ThreeStepPageState extends State<ThreeStepPage> {
  Future<LotBig> getAuctionDetail(int uuid) async {
    Dio dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    print(token);
    print(uuid);
    print(widget.lot_id);
    print(widget.isFinished);

    try {
      var response = await dio.get(
        Apis.buyerLotDetail(uuid, widget.lot_id, widget.isFinished),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        log(response.data.toString());
        return LotBig.fromJson(response.data);
      }
    } on DioError catch (e) {
      print(e.response);
      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      }
    }
  }

  @override
  void initState() {
    getDocuments();
    super.initState();
  }

  Future<void> getDocuments() async {
    final state = Provider.of<AuctionListProvider>(context, listen: false);
    if (state.requiredFiles.isEmpty) {
      await state.getRequiredDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiAuth = Provider.of<ApiAuth>(context);
    return apiAuth.authorizedUser == null
        ? LoginPage()
        : Scaffold(
            appBar: MyAppBar(context: context),
            body: RefreshIndicator(
              onRefresh: () => Future.sync(
                () => getAuctionDetail(apiAuth.authorizedUser.id),
              ),
              child: FutureBuilder<LotBig>(
                future: getAuctionDetail(apiAuth.authorizedUser.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return GenericErrorIndicator();
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: const CircularProgressIndicator(),
                    );
                  }
                  return DocumentAcceptionBody(
                    lot: snapshot.data,
                    isFinished: widget.isFinished,
                  );
                },
              ),
            ),
          );
  }
}

class DocumentAcceptionBody extends StatefulWidget {
  final LotBig lot;
  final bool isFinished;

  const DocumentAcceptionBody({
    Key key,
    this.lot,
    this.isFinished = false,
  }) : super(key: key);

  @override
  _DocumentAcceptionBodyState createState() => _DocumentAcceptionBodyState();
}

class _DocumentAcceptionBodyState extends State<DocumentAcceptionBody> {
  bool first;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Widget line1 = Divider(
      thickness: 4,
      color: widget.lot?.documentSubmissionStatus?.status == Status.INREVIEW
          ? null
          : widget.lot?.documentSubmissionStatus?.status?.getBackgroundColor,
    );
    Widget line2 = Divider(
      thickness: 4,
      color: widget.lot?.buyerApplication?.applicationSubmission == null
          ? null
          : widget.lot?.buyerApplication?.applicationSubmission
              ?.applicationStatus?.getBackgroundColor,
    );
    final state = Provider.of<AuctionListProvider>(context);
    // documents card status
    var documentStatus = widget.lot.documentSubmissionStatus.status;
    // form application card status
    var applicationStatus =
        widget.lot.buyerApplication.applicationSubmission?.applicationStatus;
    var ticketStatus = widget.lot.ticketNo != null ? Status.APPROVED : null;

    // if buyer submission is refused, all statuses must be rejected
    if (widget.lot.buyerSubmissionStatus.code == "refused") {
      line1 = Divider(thickness: 4, color: Colors.red);
      line2 = Divider(thickness: 4, color: Colors.red);
      documentStatus = Status.REJECTED;
      applicationStatus = Status.REJECTED;
      ticketStatus = Status.REJECTED;
    }

    return ScrollConfiguration(
      behavior: MyScrollBehavior(),
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Constants.defaultMargin),
              if (widget.lot.lotImages.isNotEmpty &&
                  widget.lot.lotImages != null)
                Container(
                  height: size.height * 0.27,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: MyCachedNetworkImage(
                          imageurl: widget.lot.lotImages[index].getImage,
                        ),
                      );
                    },
                    autoplay: true,
                    itemCount: 1,
                    pagination: SwiperPagination(
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                      builder: DotSwiperPaginationBuilder(
                        color: Colors.white30,
                        activeColor: Colors.white,
                        size: 6.0,
                        activeSize: 8.0,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: Constants.defaultMargin),
              SizedBox(
                width: double.infinity,
                child: CardWidget(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlueLabel(
                          label: "Satyjy: ${widget.lot.organization.name}"),
                      const SizedBox(height: Constants.defaultMargin8),
                      Text.rich(
                        TextSpan(
                          text: "Desganyň ady:\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: " ${widget.lot.assetName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(Constants.appBlue)),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedCard(
                            keyText: "Işiň ugry:",
                            valueText: "${widget.lot.businessLine.name}",
                          ),
                          OutlinedCard(
                            keyText: "Gurlan ýyly:",
                            valueText: "${widget.lot.constructionYear}",
                          ),
                        ],
                      ),
                      const SizedBox(height: Constants.defaultMargin8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedCard(
                            keyText: "Binanyň meýdany (m2):",
                            valueText: "${widget.lot.assetArea}",
                          ),
                          OutlinedCard(
                            keyText: "Başlangyç bahasy (manat):",
                            valueText:
                                "${formattedPrice(widget.lot.startingPrice)}",
                          ),
                        ],
                      ),
                      if (widget.isFinished) refundRequestStatus(context),
                      if (!widget.isFinished)
                        const SizedBox(height: Constants.defaultMargin8),
                      if (!widget.isFinished)
                        Center(
                          child: SizedBox(
                            width: size.width,
                            child: buildInfoButton(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Constants.defaultMargin),
              CardWidget(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SubmissionStatusCard(
                          label: "Resminama",
                          status: documentStatus,
                        ),
                        Expanded(child: line1),
                        SubmissionStatusCard(
                          label: "Arza",
                          status: applicationStatus,
                        ),
                        Expanded(child: line2),
                        SubmissionStatusCard(
                          label: "Petek Belgi",
                          status: ticketStatus,
                          isLast: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Constants.defaultMargin),
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlueLabel(label: "Talap edilýän resminamalar"),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: state.requiredFiles.map((UploadFile doc) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: Constants.defaultMargin),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.circle, size: 6),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        doc.title,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Constants.defaultMargin),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoButton() {
    String text;
    String note;
    Widget nextPage;
    Color color = Theme.of(context).primaryColor;
    Color yellow = const Color(0xFFFDB51B);

    // tool
    var docSubmission = widget.lot.documentSubmissionStatus;
    final docState = Provider.of<AuctionListProvider>(context, listen: false);
    var docsFalseOrNull = widget.lot.documents
        .where((doc) => (doc.status == false || doc.status == null));

    if (widget.lot.buyerSubmissionStatus.code == "refused") {
      text = "Kabul edilmedi";
      color = Colors.red;
      nextPage = null;
    } else if (widget.lot.buyerSubmissionStatus.code == "accepted") {
      text = "Tassyklandy";
      nextPage = null;
    } else if (!widget.lot.formSubmission) {
      text = "Resminama tabşyrmak";
      note = widget.lot.documentSubmissionStatus.note;
      nextPage = DocumentsUpload(
        buyer_id: widget.lot.buyer_id,
        lot_id: widget.lot.id,
      );
    } else if (docSubmission.status == Status.REJECTED) {
      // status false/null doc file names
      final files = docsFalseOrNull.map((e) => e.title).toList();
      // state files
      List<UploadFile> stateFiles = docState.requiredFiles.map((e) {
        e.paths = null;
        e.fileName = null;
        return e;
      }).toList();
      // get declined files from state files where files exist
      List<UploadFile> declinedFiles =
          stateFiles.where((element) => files.contains(element.slug)).toList();

      var userDocTitles = widget.lot.documents.map((e) => e.title);
      List<String> notes = docsFalseOrNull.map((e) => e.note).toList();

      for (var obj in stateFiles) {
        if (!userDocTitles.contains(obj.slug)) {
          declinedFiles.add(obj);
          notes.add('Tabşyrylmadyk!');
        }
      }

      nextPage = DeclinedFiles(
        declinedFiles: declinedFiles,
        notes: notes,
        buyer_id: widget.lot.buyer_id,
        lot_id: widget.lot.id,
      );

      if (docsFalseOrNull.isNotEmpty) {
        text =
            "Resminamalaryňyzy täzeden iberiň \n(${declinedFiles.length} sany)";
        note = docSubmission.note;
        color = Colors.red;
      } else {
        text = "Galan resminamalaryňyzy iberiň";
        note = widget.lot.documentSubmissionStatus.note;
        color = Colors.red;
      }
    } else if (docSubmission.status == Status.INREVIEW) {
      text = "Resminamalaryňyz seredilýär";
      color = yellow;
      nextPage = null;
    } else if (docSubmission.status == Status.APPROVED &&
        widget.lot.buyerApplication.applicationSubmission == null) {
      text = "Ýüz tutmak formuny dolduryñ";
      nextPage = ApplicationPage(buyer_id: widget.lot.buyer_id);
    } else if (widget
            .lot.buyerApplication?.applicationSubmission?.applicationStatus ==
        Status.INREVIEW) {
      text = "Ýüz tutmañyz seredilýär";
      color = yellow;
      note = widget.lot.buyerApplication.applicationSubmission.note;
      nextPage = null;
    } else if (widget
            .lot.buyerApplication?.applicationSubmission?.applicationStatus ==
        Status.REJECTED) {
      text = "Ýüz tutma formuñyzy täzelemeli";
      color = Colors.red;
      note = widget.lot.buyerApplication.applicationSubmission.note;
      nextPage = UpdateApplicationPage(lot: widget.lot);
    } else if (widget.lot.buyerApplication?.applicationSubmission
                ?.applicationStatus ==
            Status.APPROVED &&
        widget.lot.ticketNo == null) {
      text = "Petek almaga garaşylýar";
      color = yellow;
      nextPage = null;
    } else if (widget.lot.buyerSubmissionStatus?.code == "refused") {
      text = "Ret edildi";
      color = Colors.red;
      note = widget.lot.buyerApplication.applicationSubmission.note;
      nextPage = null;
    } else if (widget.lot.ticketNo != null &&
        widget.lot.buyerSubmissionStatus?.code == "accepted") {
      text = "Live bölüminden auksiona gatnaşyñ";
      note = null;
      nextPage = null;
    } else if (widget.lot.ticketNo != null) {
      text = "Doly tassyklanmak üçin garaşyň";
      nextPage = null;
    } else {
      text = "Bir näsazlyk ýüze çykdy";
      nextPage = null;
    }

    return OutlinedButton(
      onPressed: nextPage == null ? () {} : () => navigateTo(context, nextPage),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (!(note == "" || note == null)) Text("Bellik: $note"),
                ],
              ),
            ),
            if (nextPage != null) const SizedBox(width: 8),
            if (nextPage != null)
              Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
      style: OutlinedButton.styleFrom(
        primary: color,
        onSurface: color,
        backgroundColor: color.withOpacity(0.02),
        side: BorderSide(color: color),
      ),
    );
  }

  Widget refundRequestStatus(BuildContext context) {
    Function() onPressed;
    String text;
    Color textColor = Theme.of(context).primaryColor;
    if (widget.lot.isWinner) {
      text = "Ýeniji bolduñyz. Gutlaýarys!";
      textColor = Colors.green;
      onPressed = () {};
    } else if ([0, 1, 2].contains(widget.lot.step)) {
      text = "Goýlan mukdary yzyna talap edip bilmeýärsiňiz";
      textColor = Colors.red;
      onPressed = () => showSnackbar(
            context,
            "Siz goýlan mukdary yzyna talap edip bilmeýärsiňiz sebäbi siz ${widget.lot.step}-njy turda ýeňildiňiz.",
          );
    } else if (!widget.lot.refunApplication.isApplied) {
      text = "Goýlan mukdary yzyna talap ediň";
      textColor = Color(Constants.appBlue);
      onPressed = buildDialog;
    } else if (widget.lot.refunApplication.isApplied) {
      text =
          "Puluňyzyñ yzyna gaýtarylmagyny soradyñyz. Garaşmagyňyzy haýyş edýäris.";
      textColor = Colors.orange;
      onPressed = () {};
    } else if (widget.lot.refunApplication.status == true) {
      text = "Goýlan mukdary yzyna aldyňyz";
      textColor = Colors.orange;
      onPressed = () => showSnackbar(
            context,
            "Goýlan mukdary yzyna aldyňyz. Gatnaşanyňyz üçin köp sagboluň.",
          );
    } else if (widget.lot.refunApplication.status == false) {
      text = "Haýyşyňyz ret edildi";
      textColor = Colors.orange;
      onPressed = () {};
    } else {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.77,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          style: OutlinedButton.styleFrom(
            primary: textColor,
            side: BorderSide(color: textColor),
          ),
        ),
      ),
    );
  }

  buildDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            "Goýlan puluňyzy yzyna soraýarsyňyzmy?",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ýok",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return AbsorbPointer(
                  absorbing: isLoading,
                  child: TextButton(
                    onPressed: () => requestRefund(setState),
                    style: TextButton.styleFrom(
                      primary: const Color(Constants.appBlue),
                    ),
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
                              "hawa",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  requestRefund(void Function(void Function()) func) async {
    Dio dio = Dio();
    func(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      var response = await dio.get(
        Apis.requestRefund(widget.lot.buyer_id),
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 40.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: CustomDialog(
                title:
                    "Goýlan puluňyzy yzyna soradyňyz. Garaşmagyňyzy haýyş edýäris.",
              ),
            );
          },
        );
      }
    } on DioError catch (e) {
      print(e);
      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      }
      showSnackbar(context, e.response.toString());
    } finally {
      func(() => isLoading = false);
    }
  }
}
