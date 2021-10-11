import 'dart:developer';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/models/document.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuctionListProvider with ChangeNotifier {
  int totalItemCount = 0;

  Future getLotsList(
    int auctionId,
    int orgId,
    int lineId,
    int regionId,
  ) async {
    Dio dio = Dio();
    try {
      var response = await dio.get(Apis.getAuctionLotsListApi(
        auctionId,
        orgId: orgId,
        lineId: lineId,
        regionId: regionId,
      ));

      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioError catch (e) {
      log(e.response.toString());
      throw e;
    }
  }

  List<UploadFile> requiredFiles = [];
  Future<void> getRequiredDocuments() async {
    if (requiredFiles.isEmpty) {
      Dio dio = Dio();

      try {
        var response = await dio.get(Apis.getDocumentListApi);

        if (response.statusCode == 200) {
          requiredFiles = ((response.data ?? []) as List)
              .map(
                (json) => UploadFile.fromJson(json),
              )
              .toList();
        }
        this.notifyListeners();
        return requiredFiles;
      } catch (error) {
        throw error;
      }
    } else {
      return requiredFiles;
    }
  }

  clearDocumentsData() {
    // for (var e in requiredFiles) {
    requiredFiles.first.fileName = null;
    requiredFiles.first.paths = null;
    this.notifyListeners();
    // }
  }

  bool isLastPage(int previousCount) {
    print("item count $totalItemCount");
    print("previous count $previousCount");
    print("is last page: ${totalItemCount <= previousCount}");

    return totalItemCount <= previousCount;
  }

  dynamic helperData;
  int previousId;
  Future getHelperData(int id) async {
    if (previousId != id) {
      Dio dio = Dio();
      try {
        final response = await dio.get(Apis.auctionHelperData(id));
        if (response.statusCode == 200) {
          helperData = response.data;
          previousId = id;
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
