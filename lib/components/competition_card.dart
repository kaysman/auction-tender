import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/models/competition.dart';
import 'package:maliye_app/ui/contestant/auction/lots_list.dart';
import 'package:maliye_app/ui/contestant/tender/lots_list.dart';
import 'package:flutter/material.dart';

class CompetitionCard extends StatelessWidget {
  const CompetitionCard(
      {Key key, @required this.competition, this.isAuction = true})
      : super(key: key);

  final Competition competition;
  final bool isAuction;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        return InkWell(
          onTap: () => navigateTo(
            context,
            isAuction
                ? AuctionView(auctionId: competition.id)
                : TenderView(tenderId: competition.id),
          ),
          child: Card(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    columnWidths: {
                      0: FixedColumnWidth(
                        orientation == Orientation.landscape
                            ? (size.width / 2) * 0.3
                            : size.width * 0.3
                      ),
                      1: FlexColumnWidth(1.0),
                    },
                    children: [
                      TableRow(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Image.asset(
                                'assets/png/logo.png',
                                height: 40,
                                width: 40,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text(
                                  isAuction ? 'Bäsleşikli söwda' : 'Bäsleşik',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ButtonStyle(padding:
                                    MaterialStateProperty.resolveWith<
                                        EdgeInsetsGeometry>((states) {
                                  return const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 8,
                                  );
                                })),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                            competition.title,
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
                          'Lotlaryň sany:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            competition.lotCount,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff0057B1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ]),
                      TableRow(
                        children: [
                          Text(
                            'Yglan edilen wagty:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              competition.getCreatedAt,
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
      },
    );
  }
}
