import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/contestant/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../contestant/auction/applied_lot_list.dart';
import '../contestant/tender/applied_lot_list.dart';

class Tabshyrylan extends StatefulWidget {
  const Tabshyrylan({Key key}) : super(key: key);

  @override
  _TabshyrylanState createState() => _TabshyrylanState();
}

class _TabshyrylanState extends State<Tabshyrylan>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

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
        : apiAuth.authorizedUser.isTeamMember
            ? AuctionTabsyrylanPage(finished: true)
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
                        AuctionTabsyrylanPage(),
                        TenderTabsyrylanPage(),
                      ],
                    ),
                  ),
                ],
              );
  }
}
