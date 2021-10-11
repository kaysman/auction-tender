import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/models/tendor_lot.dart';
import 'package:maliye_app/providers/bookmark_provider.dart';
import 'package:maliye_app/ui/contestant/tender/application.dart';
import 'package:maliye_app/ui/contestant/tender/lot_detail.dart';
import 'package:maliye_app/ui/contestant/tender/doc_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class TendorCard extends StatelessWidget {
  const TendorCard({
    Key key,
    this.lot,
    this.isApplied = false,
    this.isLive,
  }) : super(key: key);

  final TendorLot lot;
  final bool isLive;
  final bool isApplied;

  funcBookMark(BuildContext context) {
    var provider = Provider.of<BookmarkProvider>(
      context,
      listen: false,
    );
    provider.bookmarkTender(lot);
  }

  funcUnBookMark(BuildContext context) {
    var provider = Provider.of<BookmarkProvider>(
      context,
      listen: false,
    );
    provider.unBookmarkTender(lot);
  }

  @override
  Widget build(BuildContext context) {
    Function() nextAction;
    if (!isApplied) {
      nextAction = () => navigateTo(context, TendorInfo(lot_id: lot.id));
    } else if (lot.applicationSubmission != true) {
      nextAction = () => navigateTo(
            context,
            TenderApplicationPage(
              seller_id: lot.seller_id,
              lot_id: lot.id,
              hasNext: lot.formSubmission != true,
            ),
          );
    } else if (lot.applicationSubmission && lot.formSubmission != true) {
      nextAction = () => navigateTo(
            context,
            TendorDocumentsUpload(lot_id: lot.id, seller_id: lot.seller_id),
          );
    } else if (lot.applicationSubmission && lot.formSubmission) {
      nextAction = () => showSnackbar(
            context,
            "Siz tabşyrdyňyz. Garaşmagyňyzy haýys edýäris.",
            true,
          );
    } else {
      nextAction = () => showSnackbar(
            context,
            "Näbelli ýalňyşlyk ýüze çykdy",
            false,
          );
    }
    return GestureDetector(
      onTap: nextAction,
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                columnWidths: {
                  0: const FixedColumnWidth(150),
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
                            "LOT № ${lot?.lotNumber}",
                            style: TextStyle(
                              fontSize: 15,
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
                        children: [
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              'Bäsleşik',
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
                  TableRow(children: [
                    Text(
                      'Satyn alyjy: ',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              lot.organization.name,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff0057B1),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Consumer<BookmarkProvider>(
                            builder: (_, state, child) {
                              return GestureDetector(
                                onTap: () => state.itemHasBookmarkedTender(lot)
                                    ? funcUnBookMark(context)
                                    : funcBookMark(context),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 150),
                                  child: SvgPicture.asset(
                                    state.itemHasBookmarkedTender(lot)
                                        ? SvgIcons.bookmarkFilled
                                        : SvgIcons.saylanan,
                                    color: Color(Constants.appBlue),
                                    height: 22,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    Text(
                      'Geçirilýän senesi: ',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        lot.formattedStartingDate(),
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff0057B1),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                  TableRow(
                    children: [
                      Text(
                        'Işiň ugry:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          lot.businessLine?.name ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff0057B1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
