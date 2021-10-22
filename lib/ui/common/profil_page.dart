import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/contestant/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../contestant/auction/history_lot_list.dart';
import '../contestant/tender/history_lot_list.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    final apiAuth = Provider.of<ApiAuth>(context);
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 600),
      child: apiAuth.authorizedUser == null
          ? LoginPage()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 22),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            "Profil",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        buildAccountInfoCard(
                          title: "F.A.A",
                          body: apiAuth.authorizedUser.isTeamMember
                              ? "${apiAuth.authorizedUser.fullname}"
                              : "${apiAuth.authorizedUser.firstName} ${apiAuth.authorizedUser.surname} ${apiAuth.authorizedUser.fatherName}",
                        ),
                        const Divider(),
                        buildAccountInfoCard(
                          title: "Telefon belgi",
                          body: "${apiAuth.authorizedUser.getPhone}",
                        ),
                        const Divider(),
                        if (!apiAuth.authorizedUser.isTeamMember)
                          buildAccountInfoCard(
                            title: "Pasport belgi",
                            body: "${apiAuth.authorizedUser.passportNo}",
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (!apiAuth.authorizedUser.isTeamMember)
                  const SizedBox(height: 12),
                if (!apiAuth.authorizedUser.isTeamMember)
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 14,
                            ),
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              "Geçen",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor:
                                Theme.of(context).primaryColor.withAlpha(400),
                            onTap: () => navigateTo(
                              context,
                              TenderTabsyrylanHistoryPage(finished: true),
                            ),
                            child: Card(
                              color: Colors.transparent,
                              child: Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.only(top: 8),
                                child: Text("Bäsleşik"),
                              ),
                            ),
                          ),
                          const Divider(),
                          InkWell(
                            splashColor:
                                Theme.of(context).primaryColor.withAlpha(400),
                            onTap: () => navigateTo(context,
                                AuctionTabsyrylanHistoryPage(finished: true)),
                            child: Card(
                              color: Colors.transparent,
                              child: Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text("Bäsleşikli söwda"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      primary: Colors.red,
                      side: BorderSide(
                        color: Colors.red,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final apiAuth =
                          Provider.of<ApiAuth>(context, listen: false);
                      apiAuth.logout();
                    },
                    child: Text(
                      "Çykmak",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildAccountInfoCard({String title, String body}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text.rich(
        TextSpan(
          text: "$title\n",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          children: [
            TextSpan(
              text: body,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(Constants.appBlue),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
