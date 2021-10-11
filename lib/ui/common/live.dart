import 'dart:developer';

import 'package:maliye_app/components/auction_lot_card.dart';
import 'package:maliye_app/components/empty_lot.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contestant/login.dart';

class LivePage extends StatefulWidget {
  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  Future<List<LotBig>> getLiveLots(BuildContext context, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    try {
      Dio dio = Dio();
      String url = Apis.live(userId);

      if (apiAuth.authorizedUser != null) {
        if (apiAuth.authorizedUser.isTeamMember) {
          url = Apis.staffLiveLots(userId, false);
        }
      }

      var response = await dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response?.statusCode == 200) {
        return ((response.data['data'] ?? []) as List)
            .map((json) => LotBig.fromJson(json))
            .toList();
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      }
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiAuth = Provider.of<ApiAuth>(context);
    return apiAuth.authorizedUser == null
        ? LoginPage()
        : FutureBuilder<List<LotBig>>(
            future: getLiveLots(context, apiAuth.authorizedUser.id),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                log(snapshot.error.toString());
                return const GenericErrorIndicator();
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const CircularProgressIndicator());
              } else if (snapshot.data.isEmpty) {
                return EmptyPage();
              }
              return Container(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.only(bottom: 80, top: 16, left: 8, right: 8),
                  child: Column(
                    children: snapshot.data
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: AuctionLotCard(lot: e, isLive: true),
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
