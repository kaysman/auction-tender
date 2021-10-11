import 'package:dio/dio.dart';
import 'package:maliye_app/components/empty_lot.dart';
import 'package:maliye_app/components/glow_behavior.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:flutter/material.dart';
import 'package:maliye_app/components/competition_card.dart';
import 'package:maliye_app/models/competition.dart';

class AuctionTabView extends StatefulWidget {
  const AuctionTabView({Key key}) : super(key: key);

  @override
  _AuctionTabViewState createState() => _AuctionTabViewState();
}

class _AuctionTabViewState extends State<AuctionTabView> {
  Future<List<Competition>> getAuction;

  @override
  initState() {
    getAuction = getAuctions();
    super.initState();
  }

  Future<List<Competition>> getAuctions() async {
    Dio dio = Dio();

    try {
      Response response = await dio.get(Apis.getAuctionsList);

      print(response.data);

      if (response.statusCode == 200) {
        List<Competition> auctions = ((response.data ?? []) as List)
            .map((json) => Competition.fromJson(json))
            .toList();
        return auctions;
      }
    } on DioError catch (e) {
      debugPrint(e.toString());
      throw e;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        print(size.width);

        return FutureBuilder<List<Competition>>(
          future: getAuction,
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return const GenericErrorIndicator();
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const CircularProgressIndicator());
            } else if (snapshot.data.isEmpty) {
              return EmptyPage();
            }

            return Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ScrollConfiguration(
                    behavior: MyScrollBehavior(),
                    child: orientation == Orientation.landscape
                        ? buildListForLandscape(snapshot.data)
                        : buildListForPortrait(
                            snapshot.data, size.width >= 600)),
              ),
            );
          },
        );
      },
    );
  }

  buildListForPortrait(List<Competition> list, [bool bigScreen = false]) {
    if (bigScreen) {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 4 / 2,
        children: list.map((item) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CompetitionCard(
              competition: item,
              isAuction: true,
            ),
          );
        }).toList(),
      );
    } else {
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CompetitionCard(
              competition: list[index],
              isAuction: true,
            ),
          );
        },
      );
    }
  }

  buildListForLandscape(List<Competition> list) {
    final size = MediaQuery.of(context).size;
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 4 / 2.3,
      children: list.map((item) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CompetitionCard(
            competition: item,
            isAuction: true,
          ),
        );
      }).toList(),
    );
  }
}
