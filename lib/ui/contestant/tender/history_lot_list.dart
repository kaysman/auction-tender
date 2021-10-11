import 'dart:developer';

import 'package:maliye_app/components/empty_lot.dart';
import 'package:maliye_app/components/tender_card.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:maliye_app/models/tendor_lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/ui/contestant/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenderTabsyrylanHistoryPage extends StatefulWidget {
  const TenderTabsyrylanHistoryPage({Key key, this.finished = false})
      : super(key: key);

  final bool finished;

  @override
  _TenderTabsyrylanHistoryPageState createState() =>
      _TenderTabsyrylanHistoryPageState();
}

class _TenderTabsyrylanHistoryPageState
    extends State<TenderTabsyrylanHistoryPage>
    with AutomaticKeepAliveClientMixin {
  Future<List<TendorLot>> getBuyerTendorHistoryLots(
      BuildContext context, int userId) async {
    Dio dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    try {
      var response = await dio.get(
        Apis.tendorFinishedLots(userId, widget.finished),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return (response.data['data'] ?? [])
          .map<TendorLot>((json) => TendorLot.fromJson(json))
          .toList();
    } on DioError catch (e) {
      log(e.response.toString());
      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final apiAuth = Provider.of<ApiAuth>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Geçenler")),
      body: SafeArea(
        child: apiAuth.authorizedUser == null
            ? LoginPage()
            : FutureBuilder<List<TendorLot>>(
                future: getBuyerTendorHistoryLots(
                    context, apiAuth.authorizedUser.id),
                builder: (ctx, snapshot) {
                  if (snapshot.hasError) {
                    return const GenericErrorIndicator();
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
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
                                child: TendorCard(lot: e, isApplied: true),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
