import 'package:maliye_app/components/competition_card.dart';
import 'package:maliye_app/components/empty_lot.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:maliye_app/models/competition.dart';
import 'package:flutter/material.dart';
import 'package:maliye_app/providers/tendor_list.dart';
import 'package:provider/provider.dart';

class TenderTabView extends StatefulWidget {
  const TenderTabView({Key key}) : super(key: key);

  @override
  _TenderTabViewState createState() => _TenderTabViewState();
}

class _TenderTabViewState extends State<TenderTabView> {
  Future<List<Competition>> getTenders() async {
    final repo = Provider.of<TenderListProvider>(context, listen: false);
    return await repo.getTendersList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Competition>>(
      future: getTenders(),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return const GenericErrorIndicator();
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
                      child: CompetitionCard(
                        competition: e,
                        isAuction: false,
                      ),
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
