import 'dart:developer';
import 'dart:typed_data';

import 'package:maliye_app/components/auction_lot_card.dart';
import 'package:maliye_app/components/empty_lot.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';

import 'package:maliye_app/models/preferences.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/providers/auction_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'filter_auction.dart';

class AuctionView extends StatefulWidget {
  final int auctionId;

  const AuctionView({
    Key key,
    @required this.auctionId,
  }) : super(key: key);

  @override
  _AuctionViewState createState() => _AuctionViewState();
}

class _AuctionViewState extends State<AuctionView>
    with AutomaticKeepAliveClientMixin {
  AuctionPreferences _auctionPreferences;

  bool isLastPage = false;

  Future<List<LotBig>> _fetchPage() async {
    final repository = Provider.of<AuctionListProvider>(context, listen: false);

    try {
      final response = await repository.getLotsList(
        widget.auctionId,
        _auctionPreferences?.organization?.id,
        _auctionPreferences?.lines?.id,
        _auctionPreferences?.regions?.id,
      );

      final newItems = ((response['data'] ?? []) as List)
          .map((json) => LotBig.fromJson(json))
          .toList();
      return newItems;
    } catch (error) {
      log(error.toString());
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        return Scaffold(
          appBar: MyAppBar(context: context),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width > 400 ? 18.0 : 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "Bäsleşikli söwda",
                            style: TextStyle(
                              fontSize: orientation == Orientation.landscape
                                  ? 28.0
                                  : 22.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(Constants.appBlue),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 160,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _pushListPreferencesScreen(context),
                        child: Container(
                          width: orientation == Orientation.landscape
                              ? size.width * 0.14
                              : size.width * 0.28,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(Constants.appBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Tertip",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgIcons.filter,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<LotBig>>(
                    future: _fetchPage(),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.data);
                        return const GenericErrorIndicator();
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: const CircularProgressIndicator());
                      } else if (snapshot.data.isEmpty) {
                        return EmptyPage();
                      }

                      return orientation == Orientation.landscape
                          ? buildListForLandscape(snapshot.data)
                          : buildListForPortrait(snapshot.data, size.width >= 600);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  buildListForLandscape(List<LotBig> list) {
    final size = MediaQuery.of(context).size;
    return GridView.extent(
      childAspectRatio: 5 / 2,
      maxCrossAxisExtent: size.width - 80,
      padding: const EdgeInsets.only(bottom: 12.0),
      children: list.map((item) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AuctionLotCard(lot: item),
        );
      }).toList(),
    );
  }

  buildListForPortrait(List<LotBig> list, [bool bigScreen = false]) {
    final size = MediaQuery.of(context).size;

    if (bigScreen) {
      return GridView.extent(
        childAspectRatio: 3 / 1.8,
        maxCrossAxisExtent: size.width - 80,
        padding: const EdgeInsets.only(bottom: 12.0),
        children: list.map((item) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AuctionLotCard(lot: item),
          );
        }).toList(),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 12.0),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AuctionLotCard(lot: list[index]),
        );
      },
    );
  }

  Future<void> _pushListPreferencesScreen(BuildContext context) async {
    final route = MaterialPageRoute<AuctionPreferences>(
      builder: (_) => FilterAuction(
        auctionId: widget.auctionId,
        repository: Provider.of<AuctionListProvider>(context),
        preferences: _auctionPreferences,
      ),
      fullscreenDialog: true,
    );
    final newPreferences = await Navigator.of(context).push(route);

    if (newPreferences != null) {
      _auctionPreferences = newPreferences;
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}
