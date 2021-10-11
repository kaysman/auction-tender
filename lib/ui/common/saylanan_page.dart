import 'package:maliye_app/components/auction_lot_card.dart';
import 'package:maliye_app/components/tender_card.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/models/tendor_lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/providers/bookmark_provider.dart';
import 'package:maliye_app/ui/contestant/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SaylananPage extends StatefulWidget {
  @override
  _SaylananPageState createState() => _SaylananPageState();
}

class _SaylananPageState extends State<SaylananPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool initialized = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiAuth = Provider.of<ApiAuth>(context);
    return apiAuth.authorizedUser == null
        ? LoginPage()
        : Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.only(top: 6),
                  indicatorWeight: 3,
                  labelPadding: const EdgeInsets.all(0),
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor:
                      Theme.of(context).primaryColor.withOpacity(0.9),
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 6),
                      child: Text("Bäsleşikli söwda"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 6),
                      child: Text("Bäsleşik"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    BookmarkedAuctions(),
                    BookmarkedTenders(),
                  ],
                ),
              ),
            ],
          );
  }
}

class BookmarkedAuctions extends StatelessWidget {
  const BookmarkedAuctions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<BookmarkProvider>(context);
    List<Widget> widgets = state.getBookmarks.map<AuctionLotCard>(
      (LotBig item) {
        return AuctionLotCard(lot: item);
      },
    ).toList();

    return Container(
      child: state.getBookmarks.isNotEmpty
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 14,
                right: 14,
                top: 12,
                bottom: 80,
              ),
              child: Column(children: widgets),
            )
          : Container(
              child: Center(
                child: Text('Saýlanan bäsleşikli söwda ýok'),
              ),
            ),
    );
  }
}

class BookmarkedTenders extends StatelessWidget {
  const BookmarkedTenders({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<BookmarkProvider>(context);
    List<Widget> widgets = state.getTendorBookmarks
        .map<TendorCard>((TendorLot item) => TendorCard(lot: item))
        .toList();
    return Container(
      child: state.getTendorBookmarks.isNotEmpty
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 14,
                right: 14,
                top: 12,
                bottom: 80,
              ),
              child: Column(children: widgets),
            )
          : Container(
              child: Center(child: Text('Saýlanan bäsleşik ýok')),
            ),
    );
  }
}
