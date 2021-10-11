import 'dart:developer';

import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/models/competition.dart';
import 'package:maliye_app/models/document.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TenderListProvider with ChangeNotifier {
  List<UploadFile> requiredDocs = [];
  int totalItemCount = 0;

  Future getTendersList() async {
    Dio dio = Dio();

    try {
      Response response = await dio.get(Apis.getTendersList);

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
  }

  Future getTenderLotsList(
    int id,
    int orgId,
    int lineId,
  ) async {
    Dio dio = Dio();

    try {
      var response = await dio.get(Apis.tendorLotList(
        id,
        orgId,
        lineId,
      ));

      return response.data;
    } on DioError catch (e) {
      log(e.response.toString());
      throw e;
    }
  }

  Future<void> getRequiredDocuments() async {
    Dio dio = Dio();
    try {
      Response response = await dio.get(Apis.tendorRequiredDocs);
      if (response.statusCode == 200) {
        this.requiredDocs = List.from((response.data ?? []) as List)
            .map(
              (json) => UploadFile.fromJson(json),
            )
            .toList();
        this.notifyListeners();
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }

  bool isLastPage(int previousCount) {
    print("item count $totalItemCount");
    print("previous count $previousCount");
    print("is last page: ${totalItemCount <= previousCount}");

    return totalItemCount <= previousCount;
  }

  dynamic helperData;
  int previousTenderId;
  getHelperData(int id) async {
    if (previousTenderId != id) {
      Dio dio = Dio();
      try {
        final response = await dio.get(Apis.tenderHelperData(id));
        if (response.statusCode == 200) {
          helperData = response.data;
          previousTenderId = id;
          notifyListeners();
          return helperData;
        }
      } catch (error) {
        print(error);
        throw error;
      }
    } else {
      return helperData;
    }
  }
}
