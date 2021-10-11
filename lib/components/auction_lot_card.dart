import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/models/document_submission.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/providers/bookmark_provider.dart';
import 'package:maliye_app/ui/contestant/auction/lot_detail.dart';
import 'package:maliye_app/ui/contestant/auction/game_phone_check.dart';
import 'package:maliye_app/ui/contestant/auction/three_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maliye_app/ui/team_member/phone_check.dart';
import 'package:provider/provider.dart';

class AuctionLotCard extends StatelessWidget {
  const AuctionLotCard({
    Key key,
    this.lot,
    this.isAuction = false,
    this.isLive = false,
    this.isApplied = false,
    this.isPast = false,
    this.buyer_id,
  }) : super(key: key);

  final LotBig lot;
  final int buyer_id;
  final bool isAuction;
  final bool isLive;
  final bool isApplied;
  final bool isPast;

  funcBookMark(BuildContext context) {
    var provider = Provider.of<BookmarkProvider>(
      context,
      listen: false,
    );
    provider.bookmark(lot);
  }

  funcUnBookMark(BuildContext context) {
    var provider = Provider.of<BookmarkProvider>(
      context,
      listen: false,
    );
    provider.unBookmark(lot);
  }

  @override
  Widget build(BuildContext context) {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    dynamic isToday = isLive
        ? (DateTime.now().difference(lot.startingDate).inDays == 0
            ? true
            : null)
        : false;

    return OrientationBuilder(
      builder: (context, orientation){
        return InkWell(
          onTap: () {
            if (apiAuth.authorizedUser?.isTeamMember == true) {
              return navigateTo(context, MemberPhoneCheck(lot_id: lot.id));
            } else if (isToday == true) {
              return navigateTo(
                context,
                LotPhoneCheck(
                  lot_id: lot.id,
                  ticket_no: lot.ticketNo,
                ),
              );
            } else if (isToday == null) {
              return showSnackbar(context, "Başlajak güni giriñ!", false);
            } else {
              return navigateTo(
                context,
                isLive
                    ? LotPhoneCheck(
                  lot_id: lot.id,
                  ticket_no: lot.ticketNo,
                )
                    : isApplied
                    ? ThreeStepPage(lot_id: lot.id, isFinished: isPast)
                    : AuctionInfo(lot_id: lot.id, oldlot: lot),
              );
            }
          },
          child: Card(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      columnWidths: {
                        0: const FixedColumnWidth(140),
                        1: const FlexColumnWidth(1.0),
                      },
                      children: [
                        TableRow(children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  "LOT №${lot.lotNumber}",
                                  style: TextStyle(
                                    fontSize: orientation == Orientation.landscape ? 22.0 : 15.0,
                                    color: const Color(0xff0057B1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 2,
                                  width: 70,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Spacer(),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Bäsleşikli söwda',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  style: ButtonStyle(padding: MaterialStateProperty
                                      .resolveWith<EdgeInsetsGeometry>((states) {
                                    return const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 8);
                                  })),
                                ),
                              ],
                            ),
                          )
                        ]),
                        TableRow(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Hasabynda saklaýjy: ',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${lot.organization.name}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff0057B1),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (!isLive)
                                    if (lot.documentSubmissionStatus == null)
                                      Consumer<BookmarkProvider>(
                                        builder: (_, state, child) {
                                          return GestureDetector(
                                            onTap: () => state.itemHasBookmarked(lot)
                                                ? funcUnBookMark(context)
                                                : funcBookMark(context),
                                            child: AnimatedSwitcher(
                                              duration: Duration(milliseconds: 150),
                                              child: SvgPicture.asset(
                                                state.itemHasBookmarked(lot)
                                                    ? SvgIcons.bookmarkFilled
                                                    : SvgIcons.saylanan,
                                                color: Color(Constants.appBlue),
                                                height: 22,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  if (!isPast &&
                                      !isLive &&
                                      lot.documentSubmissionStatus != null)
                                    compareStatus(lot),
                                  if (isLive && !apiAuth.authorizedUser.isTeamMember)
                                    Card(
                                      child: Container(
                                        width: 45,
                                        height: 45,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                            child: Text(
                                              lot.ticketNo.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            )),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        TableRow(children: [
                          Text(
                            'Başlangyç bahasy (manat):',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              "${formattedPrice(lot.startingPrice)}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff0057B1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          Text(
                            'Geçirilýän senesi: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "${lot.formattedStartingDate()}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff0057B1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget compareStatus(LotBig lot) {
    Color color;
    String image;

    if (lot.buyerSubmissionStatus.code == "refused") {
      color = Colors.red;
      image = "assets/svg/reject.svg";
    } else if (lot.documentSubmissionStatus.status == Status.APPROVED &&
        lot.applicationSubmission?.applicationStatus == Status.APPROVED &&
        lot.ticketNo != null) {
      color = Color(Constants.appBlue);
      image = "assets/svg/check.svg";
    } else if (lot.documentSubmissionStatus?.status == Status.REJECTED ||
        lot.applicationSubmission?.applicationStatus == Status.REJECTED) {
      color = Colors.red;
      image = "assets/svg/reject.svg";
    } else {
      color = Colors.yellow;
      image = "assets/svg/pause.svg";
    }

    return Card(
      child: Container(
        width: 45,
        height: 45,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(child: SvgPicture.asset(image, height: 22)),
      ),
    );
  }
}
