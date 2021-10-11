import 'dart:developer';

import 'package:maliye_app/components/auction_lot_card.dart';
import 'package:maliye_app/components/empty_lot.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuctionTabsyrylanPage extends StatefulWidget {
  final bool finished;

  const AuctionTabsyrylanPage({Key key, this.finished = false})
      : super(key: key);

  @override
  _AuctionTabsyrylanPageState createState() => _AuctionTabsyrylanPageState();
}

class _AuctionTabsyrylanPageState extends State<AuctionTabsyrylanPage> {
  Future<List<LotBig>> getBuyerLots(BuildContext context, int userId) async {
    Dio dio = Dio();
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    try {
      String url = Apis.buyerLots(userId, widget.finished);

      if (apiAuth.authorizedUser != null) {
        if (apiAuth.authorizedUser.isTeamMember) {
          url = Apis.staffLiveLots(userId, widget.finished);
        }
      }

      // print(token);

      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return (response.data['data'] ?? [])
            .map<LotBig>((json) => LotBig.fromJson(json))
            .toList();
      }
    } on DioError catch (e) {
      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiAuth = Provider.of<ApiAuth>(context);

    return FutureBuilder<List<LotBig>>(
      future: getBuyerLots(context, apiAuth.authorizedUser.id),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return GenericErrorIndicator();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        } else if (snapshot.data.isEmpty) {
          return EmptyPage();
        }
        return Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: 80,
              top: 16,
              left: 8,
              right: 8,
            ),
            child: Column(
              children: snapshot.data
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AuctionLotCard(lot: e, isApplied: true),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
