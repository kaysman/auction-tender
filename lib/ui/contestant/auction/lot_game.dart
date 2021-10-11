import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:maliye_app/components/cached_image.dart';
import 'package:maliye_app/components/card_widget.dart';
import 'package:maliye_app/components/glow_behavior.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
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

const int blueColorCode = 0xff0057B1;
const int redColorCode = 0xffF13850;
const int yellowColorCode = 0xffFCE903;
const int greenColorCode = 0xff009639;

// initialized variables
int _duration = 0;
List<Buyer> buyerList;
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
      log(bidInserted.toString());
      currentBid = Bid.fromJson(bidInserted['message']);
      setState(() {});
    });

    socket.on("percentage:updated", (updatedPercentage) {
      if (updatedPercentage['status'] == 200){
        print("Percentage Updated");
        print(updatedPercentage);
        percentage = double.tryParse(updatedPercentage['message']['increase_percentage']);
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

        // print("current_bid:not_accepting");
        // log("$response");
        if (response['status'] == 200) {
          if (response['message']['lot_result'] != null) {
            if (response['message']['lot_result']['finished'] == true) {
              if (response['message']['lot_result']['winner_buyer_id'] !=
                  null) {
                // setState(() {
                  winner = Buyer.fromJson(
                    response['message']['lot_result']['winner'],
                  );
                // });
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

              // setState(() {
              //   buyerList = List<Buyer>.generate(buyerList.length, (index) {
              //     var buyer = buyersResponse
              //         .where((el) => el['id'] == buyerList[index].id)
              //         ?.first;
              //     return Buyer.fromJson({
              //       "id": buyerList[index].id,
              //       "user_id": buyerList[index].userId,
              //       "lot_id": buyerList[index].lotId,
              //       "ticket_number": buyerList[index].ticketNumber,
              //       "connected": buyerList[index].connected,
              //       "last_bid_id": buyer['last_bid_id'],
              //       "proceed": buyer['proceed'],
              //     });
              //   });
              // });
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
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    final size = MediaQuery.of(context).size;
    LotBig lot = widget.lot;
    String price = currentBid == null
        ? lot.startingPrice
        : currentBid.bidAmount.toStringAsFixed(3);

    print(lot.startingPrice);
    print(percentage);
    print(double.tryParse(lot.startingPrice) ?? 0.0 * percentage ?? 1.0);

    String stepPrice = ((double.tryParse(lot.startingPrice) ?? 0.0 * percentage ?? 1.0) / 100).toStringAsFixed(0);

    return WillPopScope(
      onWillPop: confirmExit,
      child: Scaffold(
        appBar: MyAppBar(context: context),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                child: Column(
                  children: [
                    const SizedBox(height: Constants.defaultMargin),
                    SizedBox(
                      width: double.infinity,
                      child: CardWidget(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text.rich(
                                TextSpan(
                                  text: "Desganyň ady:\n",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: widget.lot.assetName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(Constants.appBlue),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.start,
                                softWrap: true,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text.rich(
                                TextSpan(
                                  text: "LOT № ${widget.lot.lotNumber}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(Constants.appBlue),
                                  ),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Constants.defaultMargin),
                    Container(
                      width: double.infinity,
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            children: [
                              buildCard(
                                text: "${formattedPrice(price)}",
                                color: blueColorCode,
                              ),
                              const SizedBox(height: 8),
                              if (percentage != null)
                                Text( stepPrice ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: size.height * 0.2,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!apiAuth.authorizedUser.isTeamMember)
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (!(isAcceptedOrRejected ==
                                                false)) {
                                              socket.emit("buyerbid:insert", {
                                                "admin_bid_id": currentBid.id,
                                                "proceed": false,
                                              });
                                              print("rejected");
                                            }
                                          },
                                          child: Text(
                                            "Ýatyr",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: const Color(0xffF13850),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: size.width * 0.28,
                                      child: CircularCountDownTimer(
                                        // Countdown duration in Seconds.
                                        duration: _duration,

                                        initialDuration: 0,

                                        // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                                        controller: _controller,

                                        // Width of the Countdown Widget.
                                        width: size.width / 2,

                                        // Height of the Countdown Widget.
                                        height: size.height / 2,

                                        // Ring Color for Countdown Widget.
                                        ringColor: Colors.grey[300],

                                        // Filling Color for Countdown Widget.
                                        fillColor:
                                            Theme.of(context).primaryColor,

                                        // Background Color for Countdown Widget.
                                        backgroundColor: Colors.transparent,

                                        // Border Thickness of the Countdown Ring.
                                        strokeWidth: 8.0,

                                        // Begin and end contours with a flat edge and no extension.
                                        strokeCap: StrokeCap.round,

                                        // Text Style for Countdown Text.
                                        textStyle: TextStyle(
                                          fontSize: size.width * 0.08,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),

                                        // Format for the Countdown Text.
                                        textFormat: CountdownTextFormat.MM_SS,

                                        // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                                        isReverse: true,

                                        // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                                        isReverseAnimation: true,

                                        // Handles visibility of the Countdown Text.
                                        isTimerTextShown: true,

                                        // Handles the timer start.
                                        autoStart: false,

                                        // This Callback will execute when the Countdown Starts.
                                        onStart: () {
                                          // Here, do whatever you want
                                          // print('Countdown Started');
                                        },

                                        // This Callback will execute when the Countdown Ends.
                                        onComplete: () {
                                          // Here, do whatever you want
                                          // print('Countdown Ended');
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (!apiAuth.authorizedUser.isTeamMember)
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (!(isAcceptedOrRejected ==
                                                true)) {
                                              socket.emit("buyerbid:insert", {
                                                "admin_bid_id": currentBid.id,
                                                "proceed": true,
                                              });
                                              print("accepted");
                                            }
                                          },
                                          child: Text(
                                            "Dowam",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: const Color(0xff009639),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              if (!apiAuth.authorizedUser.isTeamMember)
                                buildCard(
                                  text: widget.lot.me.ticketNumber.toString(),
                                  color: buildColor(
                                    currentBid,
                                    user,
                                  ),
                                  width: size.width * 0.25,
                                ),
                              GridView.count(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                childAspectRatio: 2.5,
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
                              const SizedBox(height: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.3,
                      child: ScrollConfiguration(
                        behavior: MyScrollBehavior(),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 18),
                          child: Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: MyCachedNetworkImage(
                                  imageurl:
                                      widget.lot.lotImages[index].getImage,
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
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
    }
    // else if ([0, 1, 2].contains(widget.lot.step)) {
    //   text = "Goýlan mukdary yzyna talap edip bilmeýärsiňiz";
    //   textColor = Colors.red;
    //   onPressed = () {};
    // }
    else if (winner.id != user.id
        // && ![0, 1, 2].contains(widget.lot.step)
        &&
        isApplied == false) {
      text = "Puluňyzyñ yzyna gaýtarylmagyny sora";
      textColor = Color(Constants.appBlue);
      onPressed = () => requestRefund();
    } else if (winner.id != user.id
        //  && ![0, 1, 2].contains(widget.lot.step)
        &&
        isApplied == true) {
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
                // SizedBox(
                //   width: double.infinity,
                //   child: AbsorbPointer(
                //     absorbing: isRefundLoading,
                //     child: ElevatedButton(
                //       onPressed: onPressed,
                //       child: AnimatedSwitcher(
                //         duration: Duration(milliseconds: 150),
                //         child: isRefundLoading
                //             ? Theme(
                //                 data: Theme.of(context).copyWith(
                //                   accentColor: const Color(0xFFBA9606),
                //                 ),
                //                 child: const ProgressIndicatorSmall(),
                //               )
                //             : Text(
                //                 text,
                //                 textAlign: TextAlign.center,
                //                 style: TextStyle(
                //                   fontSize: 16,
                //                   fontWeight: FontWeight.bold,
                //                   color: const Color(0xFFBA9606),
                //                 ),
                //               ),
                //       ),
                //       style: ElevatedButton.styleFrom(
                //         padding: EdgeInsets.all(12),
                //         primary: const Color(0xFFFFFAC7),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      socket.emit("leave.room");
                      // Wrap Navigator with SchedulerBinding to wait for rendering state before navigating
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

  Widget buildCard({@required String text, @required int color, double width}) {
    Size size = MediaQuery.of(context).size;
    return Card(
      child: Container(
        width: width ?? size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: Color(color) ?? Theme.of(context).primaryColor),
        child: Center(
          child: Text(
            text ?? '',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
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

/// TODO: step, area, prosent baha, organization name, region
/// "Siz yeniji boldunyz, 5 ish gun dowamynda teswirnama gol cekmage gelmeginizi hayys edyaris"
/// button disappearing after tapped, yenilen bolsa ayyrmaly
