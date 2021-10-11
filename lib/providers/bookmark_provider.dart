import 'package:maliye_app/models/lot.dart';
import 'package:maliye_app/models/tendor_lot.dart';
import 'package:flutter/material.dart';

class BookmarkProvider with ChangeNotifier {
  List<LotBig> bookmarkedAuctionsList = [];
  List<TendorLot> bookmarkedTendersList = [];

  // auction
  bookmark(LotBig item) {
    bool shouldAdd = false;
    if (this.bookmarkedAuctionsList.isEmpty) {
      bookmarkedAuctionsList.add(item);
    } else {
      for (var bmark in this.bookmarkedAuctionsList) {
        if (bmark.id != item.id) {
          shouldAdd = true;
          break;
        }
      }
      if (shouldAdd) {
        this.bookmarkedAuctionsList.add(item);
      }
    }
    notifyListeners();
  }

  unBookmark(LotBig item) {
    bool shouldRemove = false;
    for (var bmark in this.bookmarkedAuctionsList) {
      if (bmark.id == item.id) {
        shouldRemove = true;
        break;
      }
    }
    if (shouldRemove) {
      this.bookmarkedAuctionsList.removeWhere((e) => e.id == item.id);
    }
    notifyListeners();
  }

  bool itemHasBookmarked(LotBig item) {
    bool hasItem = false;
    for (var bMark in this.bookmarkedAuctionsList) {
      if (bMark.id == item.id) {
        hasItem = true;
        break;
      }
    }
    if (hasItem) return true;
    return false;
  }

  List<LotBig> get getBookmarks => this.bookmarkedAuctionsList;

  // tender
  bookmarkTender(TendorLot item) {
    bool shouldAdd = false;
    if (this.bookmarkedTendersList.isEmpty) {
      bookmarkedTendersList.add(item);
    } else {
      for (var bmark in this.bookmarkedTendersList) {
        if (bmark.id != item.id) {
          shouldAdd = true;
          break;
        }
      }
      if (shouldAdd) {
        this.bookmarkedTendersList.add(item);
      }
    }
    notifyListeners();
  }

  unBookmarkTender(TendorLot item) {
    bool shouldRemove = false;
    for (var bmark in this.bookmarkedTendersList) {
      if (bmark.id == item.id) {
        shouldRemove = true;
        break;
      }
    }
    if (shouldRemove) {
      this.bookmarkedTendersList.removeWhere((e) => e.id == item.id);
    }
    notifyListeners();
  }

  bool itemHasBookmarkedTender(TendorLot item) {
    bool hasItem = false;
    for (var bMark in this.bookmarkedTendersList) {
      if (bMark.id == item.id) {
        hasItem = true;
        break;
      }
    }
    if (hasItem) return true;
    return false;
  }

  List<TendorLot> get getTendorBookmarks => this.bookmarkedTendersList;
}
