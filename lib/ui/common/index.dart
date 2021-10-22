import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/providers/auction_list.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/providers/tendor_list.dart';
import 'package:maliye_app/ui/common/home.dart';
import 'package:maliye_app/ui/common/profil_page.dart';
import 'package:maliye_app/ui/common/saylanan_page.dart';
import 'package:maliye_app/ui/common/tabsyrylan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'live.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  PageController tabBarPageController = PageController(
    initialPage: 2,
    keepPage: true,
  );

  @override
  void initState() {
    getDocuments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(context: context),
      body: SafeArea(
        child: PageView(
          controller: tabBarPageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            LivePage(),
            SaylananPage(),
            HomePage(),
            Tabshyrylan(),
            ProfilPage(),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: BounceTabBar(
        currentIndex: tabBarPageController.initialPage,
        backgroundColor: Theme.of(context).primaryColor,
        onTabChanged: (int index) {
          tabBarPageController.jumpToPage(index);
        },
      ),
    );
  }

  Future<void> getDocuments() async {
    final state = Provider.of<AuctionListProvider>(context, listen: false);
    final tender = Provider.of<TenderListProvider>(context, listen: false);
    await state.getRequiredDocuments();
    await tender.getRequiredDocuments();
  }
}

class BounceTabBar extends StatefulWidget {
  const BounceTabBar({
    Key key,
    this.backgroundColor,
    this.currentIndex = 0,
    @required this.onTabChanged,
  }) : super(key: key);

  final Color backgroundColor;
  final ValueChanged<int> onTabChanged;
  final int currentIndex;

  @override
  _BounceTabBarState createState() => _BounceTabBarState();
}

class _BounceTabBarState extends State<BounceTabBar> {
  List<Widget> items = [];
  int _currentIndex;

  List<Map<String, dynamic>> tabBarData = [];

  @override
  void initState() {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    bool userExists = apiAuth.authorizedUser != null;
    bool isTeamMember =
        userExists ? apiAuth.authorizedUser.isTeamMember : false;
    tabBarData = [
      {
        "title": "Live",
        "image": SvgIcons.live,
      },
      {
        "title": "Saýlanan",
        "image": SvgIcons.saylanan,
      },
      {
        "title": "Esasy",
        "image": SvgIcons.floatBar,
      },
      {
        "title": isTeamMember ? "Geçenler" : "Tabşyrylan",
        "image": SvgIcons.tabshyrylan,
      },
      {
        "title": "Profil",
        "image": SvgIcons.profil,
      },
    ];
    _currentIndex = widget.currentIndex;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final textSize = orientation == Orientation.landscape
        ? size.height * 0.016
        : size.height * 0.013;

    items = List.generate(tabBarData.length, (index) {
      return buildCardIcon(
        tabBarData[index]['image'],
        tabBarData[index]['title'],
        isSelected: index == _currentIndex,
      );
    });

    return OrientationBuilder(
      builder: (context, orientation) {
        double currentElevation = orientation == Orientation.landscape
            ? -size.width * 0.02
            : -size.width * 0.06;

        return Padding(
          padding: EdgeInsets.only(
            left:
                orientation == Orientation.landscape ? size.width * 0.25 : 8.0,
            right:
                orientation == Orientation.landscape ? size.width * 0.25 : 8.0,
            bottom: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      items.length,
                      (index) {
                        final child = items[index];
                        final innerWidget = CircleAvatar(
                          radius: size.height * 0.027,
                          backgroundColor: widget.backgroundColor,
                          child: child,
                        );
                        if (index == 2) {
                          return Expanded(
                            child: Transform.translate(
                              offset: Offset(0.0, currentElevation),
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  widget.onTabChanged(index);
                                  setState(() => _currentIndex = index);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 10,
                                        color: const Color(0x38FFFFFF),
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: size.height * 0.031,
                                    backgroundColor: Colors.white,
                                    child: innerWidget,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                widget.onTabChanged(index);
                                setState(() => _currentIndex = index);
                              },
                              child: Column(
                                children: [
                                  innerWidget,
                                  Text(
                                    tabBarData[index]['title'],
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: textSize,
                                      color: index == _currentIndex
                                          ? Colors.white
                                          : const Color(0xffB5D8FF),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCardIcon(String icon, String label, {bool isSelected = false}) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          color: isSelected ? Colors.white : const Color(0xffB5D8FF),
          height: size.height * 0.035,
        ),
      ],
    );
  }
}
