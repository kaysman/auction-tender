import 'dart:developer';

import 'package:maliye_app/components/cached_image.dart';
import 'package:maliye_app/components/glow_behavior.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/labels.dart';
import 'package:maliye_app/components/card_widget.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:maliye_app/models/document.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/models/lot_image.dart';
import 'package:maliye_app/providers/auction_list.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/contestant/auction/three_step.dart';
import 'package:maliye_app/ui/contestant/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'required_docs.dart';

class AuctionInfo extends StatelessWidget {
  final LotBig oldlot;
  final int lot_id;
  const AuctionInfo({
    Key key,
    @required this.lot_id,
    @required this.oldlot,
  }) : super(key: key);

  Future<Response> getAuctionDetail() async {
    Dio dio = Dio();
    try {
      var response = await dio.get(Apis.auctionLotDetail(lot_id));
      print(response.data);
      if (response.statusCode == 200) {
        return response;
      }
    } on DioError catch (e) {
      print(e);
      throw e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Bäsleşikli söwda barada", style: appTextStyle),
      ),
      body: FutureBuilder<Response>(
        future: getAuctionDetail(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const GenericErrorIndicator();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return AuctionInfoBody(
            response: snapshot.data,
            oldLot: oldlot,
          );
        },
      ),
    );
  }
}

class AuctionInfoBody extends StatefulWidget {
  final Response response;
  final LotBig oldLot;

  const AuctionInfoBody({
    Key key,
    @required this.response,
    @required this.oldLot,
  }) : super(key: key);

  @override
  _AuctionInfoBodyState createState() => _AuctionInfoBodyState();
}

class _AuctionInfoBodyState extends State<AuctionInfoBody> {
  bool isLoading = false;
  Dio dio = Dio();
  int buyer_id;
  List<LotImage> images = [];

  Future<bool> checkLotSubmission() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);

    Map<String, dynamic> data = {
      "user_id": apiAuth.authorizedUser.id,
      "lot_id": widget.oldLot.id,
    };

    setState(() => isLoading = true);

    try {
      var response = await dio.post(
        Apis.checkSubmissionApi,
        data: data,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      setState(() => isLoading = false);

      print("auction check applied: ");
      log(response.data.toString());

      if (response.statusCode == 200) {
        setState(() => buyer_id = response.data['id']);
        return response.data['status'];
      } else {
        return false;
      }
    } on DioError catch (e) {
      setState(() => isLoading = false);
      log(e.response.toString() + " " + e.response.statusCode.toString());

      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      }
    }
  }

  @override
  void initState() {
    images = ((widget.response.data['photos'] ?? []) as List)
        .map((json) => LotImage.fromJson(json))
        .toList();
    getDocuments();
    super.initState();
  }

  Future<void> getDocuments() async {
    final state = Provider.of<AuctionListProvider>(context, listen: false);
    if (state.requiredFiles == null) {
      await state.getRequiredDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuctionListProvider>(context);
    final apiAuth = Provider.of<ApiAuth>(context);
    Size size = MediaQuery.of(context).size;
    bool hasImage = images.isNotEmpty;

    return ScrollConfiguration(
      behavior: MyScrollBehavior(),
      child: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 1,
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: "LOT № ${widget.oldLot.lotNumber} \n"
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(Constants.appBlue),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      Text.rich(
                        TextSpan(
                          text: "Geçirilýän Senesi\n".toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(Constants.appBlue),
                          ),
                          children: [
                            TextSpan(
                              text: "${widget.oldLot.formattedStartingDate()}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Constants.defaultMargin),
              Container(
                height: size.height * 0.27,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: hasImage
                    ? Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: MyCachedNetworkImage(
                              imageurl: images[index].getImage,
                            ),
                          );
                        },
                        autoplay: true,
                        itemCount: images.length,
                        pagination: SwiperPagination(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                          builder: DotSwiperPaginationBuilder(
                            color: Colors.white30,
                            activeColor: Colors.white,
                            size: 6.0,
                            activeSize: 8.0,
                          ),
                        ),
                      )
                    : Center(
                        child: SvgPicture.asset("assets/svg/placeholder.svg"),
                      ),
              ),
              const SizedBox(height: Constants.defaultMargin),
              // lot card
              CardWidget(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: Constants.auctionTitle,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.02),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      BlueLabel(
                        label:
                            "Hasabynda saklaýjy: ${widget.oldLot.organization.name}",
                      ),
                      const SizedBox(height: Constants.defaultMargin8),
                      Text.rich(
                        TextSpan(
                            text: "Desganyň ady:\n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size.height * 0.015),
                            children: [
                              TextSpan(
                                text: " ${widget.oldLot.assetName}",
                                style: TextStyle(
                                  fontSize: size.height * 0.015,
                                  fontWeight: FontWeight.w500,
                                  color: Color(Constants.appBlue),
                                ),
                              ),
                            ]),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: Constants.defaultMargin8),
                      Text.rich(
                        TextSpan(
                          text: "Ýerleşýän ýeri:\n",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.015),
                          children: [
                            TextSpan(
                              text: " ${widget.oldLot.assetAddress}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: size.height * 0.015,
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
                            valueText: "${widget.oldLot?.businessLine?.name}",
                          ),
                          OutlinedCard(
                            keyText: "Gurlan ýyly:",
                            valueText: "${widget.oldLot?.constructionYear}",
                          ),
                        ],
                      ),
                      const SizedBox(height: Constants.defaultMargin8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedCard(
                            keyText: "Binanyň meýdany (m2):",
                            valueText: "${widget.oldLot.formmattedArea()}",
                          ),
                          OutlinedCard(
                            keyText: "Başlangyç bahasy (manat):",
                            valueText:
                                "${formattedPrice(widget.oldLot.startingPrice)}",
                          ),
                        ],
                      ),
                    ],
                  ),
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
                          BlueLabel(
                            label: "Talap edilýän resminamalar",
                          ),
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
                                        style: TextStyle(
                                          fontSize: size.height * 0.014,
                                        ),
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Neşir edilen gazeti",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (widget.response.data['link'] != null)
                      GestureDetector(
                        onTap: () => _launchURL(widget.response.data['link']),
                        child: Text.rich(
                          TextSpan(
                            text:
                                "Elektron neşir edilen gazetiň salgysy - maglumaty ýükläp almak üçin:  ",
                            children: [
                              TextSpan(
                                text: widget.response.data['link_text'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(Constants.appBlue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      "Habarlaşmak üçin",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: "${widget.oldLot.region.filial}",
                      ),
                    ),
                    if (widget.oldLot.region.location != null)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "  " + "${widget.oldLot.region.location}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(Constants.appBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text.rich(
                      TextSpan(
                        text: "Telefon belgileri:",
                        children: [
                          TextSpan(
                            text: "  " + "${widget.oldLot.region.getPhoneList}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(Constants.appBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: "Fax belgileri:",
                        children: [
                          TextSpan(
                            text: "  " + "${widget.oldLot.region.getFaxList}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(Constants.appBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Constants.defaultMargin8),
                    if (apiAuth.authorizedUser?.isTeamMember != true)
                      Center(
                        child: SizedBox(
                          width: size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: () => apiAuth.authorizedUser != null
                                ? onSubmitTap(context)
                                : navigateTo(
                                    context,
                                    LoginPage(willPop: true, showAppBar: true),
                                  ),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 150),
                              child: isLoading
                                  ? Theme(
                                      data: Theme.of(context).copyWith(
                                        accentColor: Colors.white,
                                      ),
                                      child: Center(
                                        child: const ProgressIndicatorSmall(),
                                      ),
                                    )
                                  : Text(
                                      "Ýüz Tutmak",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.9)),
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

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Işledip bolmady $url';

  void onSubmitTap(BuildContext context) async {
    bool status = await checkLotSubmission();

    /// applied before
    if (status == false) {
      setState(() => isLoading = false);

      navigateTo(context, ThreeStepPage(lot_id: widget.oldLot.id));
    }

    /// not applied yet
    else if (status == true) {
      setState(() => isLoading = true);

      await applyToLot();
    } else {
      showSnackbar(context, "Something went wrong");
    }
  }

  applyToLot() async {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    try {
      Response response = await dio.post(
        Apis.applyApi,
        data: {
          "user_id": apiAuth.authorizedUser.id,
          "lot_id": widget.oldLot.id,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      setState(() => isLoading = false);

      log("apply response " + response.data.toString());

      if (response.statusCode == 201) {
        setState(() {
          buyer_id = response.data.first['id'];
        });
        navigateTo(context, ThreeStepPage(lot_id: widget.oldLot.id));
      }
    } on DioError catch (e) {
      log(e.response.toString());
      setState(() => isLoading = false);
      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated)
          setState(() {});
        else {
          await prefs.clear();
          navigateTo(context, LoginPage(willPop: true));
        }
      } else {
        showSnackbar(context, "Something went wrong, please try again later");
      }
    }
  }
}

class OutlinedCard extends StatelessWidget {
  const OutlinedCard({
    Key key,
    @required this.keyText,
    @required this.valueText,
  }) : super(key: key);

  final String keyText;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            keyText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size.height * 0.014,
            ),
          ),
          SizedBox(
            width: size.width / 2 - 60,
            child: OutlinedButton(
              onPressed: () {},
              child: Text(
                valueText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              style: OutlinedButton.styleFrom(
                primary: Color(Constants.appBlue),
                onSurface: Color(Constants.appBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
