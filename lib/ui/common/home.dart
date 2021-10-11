import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/ui/contestant/auction/auctions_list.dart';
import 'package:maliye_app/ui/contestant/tender/tenders_list.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation){
        final size = MediaQuery.of(context).size;
        final style = TextStyle(
          fontSize: size.width > 400 ? 24 : 14,
        );
        return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabBar(
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
                              child: Text("Bäsleşikli söwda", style: style),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 6),
                              child: Text("Bäsleşik", style: style),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [AuctionTabView(), TenderTabView()],
                  ),
                ),
              ],
            ),
          );
      },
    );
  }
}
