import 'dart:developer';

import 'package:maliye_app/components/empty_lot.dart';
import 'package:maliye_app/components/my_appbar.dart';
import 'package:maliye_app/components/tender_card.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:maliye_app/models/preferences.dart';
import 'package:maliye_app/models/tendor_lot.dart';
import 'package:maliye_app/providers/tendor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'filter_tender.dart';

class TenderView extends StatefulWidget {
  final int tenderId;

  const TenderView({Key key, this.tenderId}) : super(key: key);

  @override
  _TenderViewState createState() => _TenderViewState();
}

class _TenderViewState extends State<TenderView>
    with AutomaticKeepAliveClientMixin {
  TenderPreferences _tenderPreferences;

  bool isLastPage = false;

  Future<List<TendorLot>> _fetchPage() async {
    final repository = Provider.of<TenderListProvider>(context, listen: false);

    try {
      final response = await repository.getTenderLotsList(
        widget.tenderId,
        _tenderPreferences?.organization?.id,
        _tenderPreferences?.lines?.id,
      );

      final newItems = ((response['data'] ?? []) as List)
          .map((json) => TendorLot.fromJson(json))
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
    return Scaffold(
      appBar: MyAppBar(context: context),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        "Bäsleşikler",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(Constants.appBlue),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => _pushListPreferencesScreen(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(Constants.appBlue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Tertip",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SvgIcons.filter,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<TendorLot>>(
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

                  return ListView(
                    children: snapshot.data
                        .map(
                          (TendorLot e) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TendorCard(lot: e),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pushListPreferencesScreen(BuildContext context) async {
    final route = MaterialPageRoute<TenderPreferences>(
      builder: (_) => FilterTender(
        repository: Provider.of<TenderListProvider>(context),
        preferences: _tenderPreferences,
        tenderId: widget.tenderId,
      ),
      fullscreenDialog: true,
    );
    final newPreferences = await Navigator.of(context).push(route);

    log("result sent back");
    print(newPreferences?.lines?.name);
    print(newPreferences?.organization?.name);

    if (newPreferences != null) {
      _tenderPreferences = newPreferences;
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}
