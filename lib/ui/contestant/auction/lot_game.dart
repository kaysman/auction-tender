import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:maliye_app/components/cached_image.dart';
import 'package:maliye_app/components/card_widget.dart';
import 'package:maliye_app/components/glow_behavior.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/models/bid.dart';
import 'package:maliye_app/models/buyer.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/common/index.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wakelock/wakelock.dart';

import 'lot_detail.dart';

const int blueColorCode = 0xff0057B1;
const int redColorCode = 0xffF13850;
const dynamic yellowColorCode = null;
const int greenColorCode = 0xff009639;

// initialized variables
int _duration = 0;
List<Buyer> buyerList = [];
Buyer user;
bool isRunning = false;

class LotGame extends StatefulWidget {
  final LotBig lot;

  const LotGame({Key key, this.lot}) : super(key: key);

  @override
  _LotGameState createState() => _LotGameState();
}

class _LotGameState extends State<LotGame> {
  IO.Socket socket;

  CountDownController _controller = CountDownController();
  Bid currentBid;

  Buyer winner;
  bool isStopped;

  bool isRefundLoading = false;
  bool isApplied = false;

  bool isAcceptedOrRejected;
  double percentage;
  int step = 0;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();

    currentBid = widget.lot.currentBid;
    percentage = widget.lot.increasePercentage;
    step = widget.lot.step;

    log("Trying to connect");
    socket = IO.io(
      baseApiUrl + ":" + baseAuctionPort,
      <String, dynamic>{
        "transports": ['websocket'],
        "query": {"token": widget.lot.token},
        "autoConnect": false,
        "force new connection": true,
      },
    );

    socket
      ..connect()
      ..on('connect', (connected) {
        print("connected");
        socket.emit('join.room');
      })
      ..on('who_is_online', (data) => socket.emit("i_am_online"));

    buyerList = widget.lot.buyerList;
    user = widget.lot.me;

    socket.on('current:timer', (current) {
      _controller.restart(duration: current['seconds']);
      if (current['isRunning'] == false) {
        _controller.pause();
      }
    });

    socket.on("timer:started", (started) {
      print("Timer started");
      log(started.toString());
      _controller.restart(duration: started['seconds']);
    });

    socket.on("timer:paused", (paused) {
      _controller.pause();
    });

    socket.on("timer:resumed", (resumed) {
      _controller.resume();
    });

    socket.on("timer:restarted", (restarted) {
      _controller.restart(duration: restarted['seconds']);
    });

    socket.on("bid:inserted", (bidInserted) {
      print("Bid Inserted: $bidInserted");
      currentBid = Bid.fromJson(bidInserted['message']);
      step = int.tryParse(bidInserted['message']['step']) ?? step;
      setState(() {});
    });

    socket.on("percentage:updated", (updatedPercentage) {
      if (updatedPercentage['status'] == 200) {
        print("Percentage Updated");
        print(updatedPercentage);
        percentage = double.tryParse(
            updatedPercentage['message']['increase_percentage']);
      }
      setState(() {});
    });

    socket.on("buyerbid:inserted", (buyerBidInserted) {
      setState(() {
        if (buyerBidInserted['message']['buyer_id'] == user.id) {
          user = Buyer.fromJson({
            "id": user.id,
            "user_id": user.userId,
            "lot_id": user.lotId,
            "ticket_number": user.ticketNumber,
            "connected": user.connected,
            "last_bid_id": buyerBidInserted['message']['admin_bid_id'],
            "proceed": buyerBidInserted['message']['proceed'],
          });

          isAcceptedOrRejected = buyerBidInserted['message']['proceed'];
        }
        buyerList = buyerList.map((Buyer buyer) {
          if (buyerBidInserted['message']['buyer_id'] == buyer.id) {
            return Buyer.fromJson({
              "id": buyer.id,
              "user_id": buyer.userId,
              "lot_id": buyer.lotId,
              "ticket_number": buyer.ticketNumber,
              "connected": buyer.connected,
              "last_bid_id": buyerBidInserted['message']['admin_bid_id'],
              "proceed": buyerBidInserted['message']['proceed'],
            });
          } else {
            return buyer;
          }
        }).toList();
      });
    });

    socket.on(
      "current_bid:not_accepting",
      (response) {
        setState(() {
          isAcceptedOrRejected = null;
        });

        if (response['status'] == 200) {
          if (response['message']['lot_result'] != null) {
            if (response['message']['lot_result']['finished'] == true) {
              if (response['message']['lot_result']['winner_buyer_id'] !=
                  null) {
                winner = Buyer.fromJson(
                  response['message']['lot_result']['winner'],
                );
              }
            } else {
              print("not finished");
              var buyersResponse =
                  (response['message']['lot_result']['buyers'] as List);

              int buyer_index = 0;

              for (var el in buyersResponse) {
                if (el['id'] == user.id) {
                  setState(() {
                    user = Buyer.fromJson({
                      "id": user.id,
                      "user_id": user.userId,
                      "lot_id": user.lotId,
                      "ticket_number": user.ticketNumber,
                      "connected": user.connected,
                      "last_bid_id": el['admin_bid_id'],
                      "proceed": el['proceed'],
                    });
                  });
                  break;
                }
                buyer_index += 1;
              }

              buyersResponse.removeAt(buyer_index);
              setState(() {
                buyerList = buyersResponse
                    .map<Buyer>((json) => Buyer.fromJson(json))
                    .toList();
              });
            }
          }
        }
      },
    );
  }

  @override
  void dispose() {
    print("disposed");
    socket
      ..emit("leave.room")
      ..destroy();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: confirmExit,
      child: Scaffold(
        appBar: MyAppBar(context: context),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              buildBody(),
              if (winner != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: buildWinnerCard(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final lot = widget.lot;
    final price = currentBid == null
        ? lot.startingPrice
        : currentBid.bidAmount.toStringAsFixed(3);
    String stepPrice = (double.tryParse(lot.startingPrice) * percentage / 100)
        .toStringAsFixed(1);

    dynamic rejectBtnColor =
        isAcceptedOrRejected != null ? Colors.grey : const Color(0xffDF001C);
    dynamic acceptBtnColor =
        isAcceptedOrRejected != null ? Colors.grey : const Color(0xff8FB946);
    return Stack(
      children: [
        Card(
          margin: EdgeInsets.fromLTRB(
            16.0,
            size.height * 0.09,
            16.0,
            16.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              boxShadow: [
                BoxShadow(color: const Color(0xFF7E7E7E)),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.0,
                size.height * 0.05,
                16.0,
                16.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30, child: VerticalDivider()),
                      const SizedBox(width: 18.0),
                      Text(
                        "$step",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff676D73),
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: SvgIcons.hammer,
                      ),
                      const SizedBox(width: 18.0),
                      const SizedBox(height: 30, child: VerticalDivider()),
                      const SizedBox(width: 18.0),
                      Text.rich(
                        TextSpan(
                          text: "$stepPrice",
                          children: [
                            TextSpan(
                              text: "  TMT",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff8FB946),
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff676D73),
                          ),
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(width: 6.0),
                      SvgIcons.raising,
                      const SizedBox(width: 18.0),
                      const SizedBox(height: 30, child: VerticalDivider()),
                    ],
                  ),
                  const SizedBox(height: 18.0),
                  Row(
                    children: [
                      const SizedBox(width: 8.0),
                      const SizedBox(height: 30, child: VerticalDivider()),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: price,
                            children: [
                              TextSpan(
                                text: "  TMT",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff8FB946),
                                ),
                              ),
                            ],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff676D73),
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30, child: VerticalDivider()),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                  const SizedBox(height: 18.0),
                  CircularCountDownTimer(
                    duration: _duration,
                    initialDuration: 0,
                    controller: _controller,
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    ringColor: Colors.grey[300],
                    fillColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.transparent,
                    strokeWidth: 8.0,
                    strokeCap: StrokeCap.round,
                    textStyle: TextStyle(
                      fontSize: size.width * 0.08,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textFormat: CountdownTextFormat.MM_SS,
                    isReverse: true,
                    isReverseAnimation: true,
                    isTimerTextShown: true,
                    autoStart: false,
                    onStart: () {},
                    onComplete: () {},
                  ),
                  const SizedBox(height: 18.0),
                  Row(
                    children: [
                      Expanded(
                        child: BidButton(
                          icon: SvgIcons.bid_down(rejectBtnColor),
                          text: "Ýatyr",
                          color: rejectBtnColor,
                          onPressed: isAcceptedOrRejected != null
                              ? null
                              : () {
                                  if (!(isAcceptedOrRejected == false)) {
                                    socket.emit("buyerbid:insert", {
                                      "admin_bid_id": currentBid.id,
                                      "proceed": false,
                                    });
                                    print("rejected");
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: 18.0),
                      Expanded(
                        child: BidButton(
                          icon: SvgIcons.bid_up(acceptBtnColor),
                          text: "Dowam et",
                          color: acceptBtnColor,
                          onPressed: isAcceptedOrRejected != null
                              ? null
                              : () {
                                  if (!(isAcceptedOrRejected == true)) {
                                    socket.emit("buyerbid:insert", {
                                      "admin_bid_id": currentBid.id,
                                      "proceed": true,
                                    });
                                    print("accepted");
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: Color(buildColor(currentBid, user) ?? 0xffffffff),
                      border: Border.all(
                        color: Color(
                          buildColor(currentBid, user) ?? Constants.appBlue,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        "№${widget.lot.me.ticketNumber.toString()}   ${widget.lot.me.firstname} ${widget.lot.me.lastname}",
                        style: TextStyle(
                          color: Color(
                            buildColor(currentBid, user) != null
                                ? 0xffffffff
                                : Constants.appBlue,
                          ),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  Divider(),
                  const SizedBox(height: 8.0),
                  if (buyerList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Gatnaşyjy ýok",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (buyerList.isNotEmpty)
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      childAspectRatio: 3 / 2,
                      children: buyerList.map((Buyer buyer) {
                        return buildCard(
                          color: buildColor(
                            currentBid,
                            buyer,
                          ),
                          text: buyer.ticketNumber.toString(),
                        );
                      }).toList(),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Ýerleşýän ýeri:\n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: size.height * 0.015),
                            children: [
                              TextSpan(
                                text: " ${lot.assetAddress}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: size.height * 0.015,
                                  color: Color(
                                    Constants.appBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedCard(
                              keyText: "Işiň ugry:",
                              valueText: "${lot.businessLine?.name ?? ""}",
                            ),
                            OutlinedCard(
                              keyText: "Gurlan ýyly:",
                              valueText: "${lot.constructionYear}",
                            ),
                          ],
                        ),
                        const SizedBox(height: Constants.defaultMargin8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedCard(
                              keyText: "Binanyň meýdany (m2):",
                              valueText: "${lot.formmattedArea()}",
                            ),
                            OutlinedCard(
                              keyText: "Başlangyç bahasy (manat):",
                              valueText: "${formattedPrice(lot.startingPrice)}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.3,
                    child: ScrollConfiguration(
                      behavior: MyScrollBehavior(),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        child: Swiper(
                          itemBuilder: (BuildContext context, int index) {
                            print(widget.lot.lotImages[index].getImage);
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: MyCachedNetworkImage(
                                imageurl: widget.lot.lotImages[index].getImage,
                              ),
                            );
                          },
                          autoplay: true,
                          itemCount: widget.lot.lotImages.length,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.035,
          left: 34.0,
          right: 34.0,
          child: _blueLabeledHeader(
            lot.lotNumber,
            lot.assetName,
          ),
        ),
      ],
    );
  }

  _blueLabeledHeader(int number, String content) {
    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              color: primaryColor,
              child: Center(
                child: Text(
                  "LOT №  $number",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              child: Center(
                child: Text(
                  content,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWinnerCard() {
    Function() onPressed;
    String text;
    Color textColor = Theme.of(context).primaryColor;
    setState(() {
      isApplied = widget.lot.refunApplication?.isApplied;
    });

    if (winner.id == user.id) {
      text = "Ýeniji bolduñyz. Gutlaýarys!";
      textColor = Colors.green;
      onPressed = () {};
    } else if (winner.id != user.id && isApplied == false) {
      text = "Puluňyzyñ yzyna gaýtarylmagyny sora";
      textColor = Color(Constants.appBlue);
      onPressed = () => requestRefund();
    } else if (winner.id != user.id && isApplied == true) {
      text = "Puluňyzyñ yzyna gaýtarylmagyny soradyñyz";
      textColor = Colors.orange;
      onPressed = () {};
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(400),
      ),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    text: "${winner?.ticketNumber}\n",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                      fontSize: 32,
                    ),
                    children: [
                      TextSpan(
                        text: "Petek belgili ",
                        children: [
                          TextSpan(
                            text: "${winner?.firstname} ${winner?.lastname}",
                            children: [
                              TextSpan(
                                text: " ýeňiji boldy!",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(Constants.appBlue),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      socket.emit("leave.room");
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => IndexPage()),
                          (route) => false,
                        );
                      });
                    },
                    child: Text(
                      "Çykmak",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> confirmExit() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Bäsleşikli söwdadan çykjakmy?",
            style: TextStyle(
              color: const Color(Constants.appBlue),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Ýok",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Hawa",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  int buildColor(Bid currentBid, Buyer buyer) {
    if (currentBid != null &&
        currentBid?.id != buyer.lastBidId &&
        buyer.proceed &&
        currentBid?.isAccepting == true)
      return yellowColorCode;
    else if (currentBid != null &&
        currentBid?.id == buyer.lastBidId &&
        buyer.proceed)
      return greenColorCode;
    else if (currentBid != null &&
        currentBid?.id == buyer.lastBidId &&
        buyer.proceed == false)
      return redColorCode;
    else if (currentBid != null &&
        currentBid?.id != buyer.lastBidId &&
        buyer.proceed == false)
      return redColorCode;
    else {
      return 0xFFC7C7C7;
    }
  }

  Widget buildCard(
      {@required String text, @required dynamic color, double width}) {
    Size size = MediaQuery.of(context).size;
    return Card(
      child: Container(
        width: width ?? size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color != null ? Color(color) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color != null ? Color(color) : Color(Constants.appBlue),
          ),
        ),
        child: Center(
          child: Text(
            '№${text ?? ''}',
            style: TextStyle(
              fontSize: 22,
              color: color != null
                  ? const Color(0xFFF5F5F5)
                  : Color(Constants.appBlue),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  requestRefund() async {
    hideKeyboard();

    if (isRefundLoading) {
      return;
    }

    Dio dio = Dio();
    setState(() => isRefundLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      var response = await dio.get(
        Apis.requestRefund(widget.lot.buyer_id),
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );
      setState(() => isRefundLoading = false);

      if (response.statusCode == 200) {
        setState(() {
          isApplied = true;
        });
      }
    } on DioError catch (e) {
      print(e);
      setState(() => isRefundLoading = false);

      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      }
      showSnackbar(context, e.response.toString());
    }
  }
}

class BidButton extends StatelessWidget {
  const BidButton({
    Key key,
    @required this.color,
    @required this.text,
    @required this.icon,
    @required this.onPressed,
  }) : super(key: key);

  final Color color;
  final String text;
  final Widget icon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        side: BorderSide(
          color: color,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 4),
          SizedBox(
            height: 16,
            child: VerticalDivider(
              color: color,
              thickness: 1,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text.toUpperCase(),
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: color,
                letterSpacing: -0.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
