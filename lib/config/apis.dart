// String baseApiUrl = "http://95.85.97.206"; // real server
const String baseApiUrl = "http://192.168.31.250"; // local test server
// const String baseApiUrl = "http://45.93.136.141"; // test server

// Ports - Test
// const String baseAuctionPort = "9062";
// const String baseTendorPort = "9063";
// const String filePort = "9064";

// Ports - Test
const String baseAuctionPort = "5000";
const String baseTendorPort = "4000";
const String filePort = "5000";

class Apis {
  static String get baseAuctionApi =>
      baseApiUrl + ":" + baseAuctionPort + "/api/";

  static String get baseTendorApi =>
      baseApiUrl + ":" + baseTendorPort + "/api/";
  static String get baseAuctionFileApi =>
      baseApiUrl + ":" + baseAuctionPort + "/api" /* + ":" + filePort */;

  // refresh access token api
  static String get getUpdateTokenApi => baseAuctionApi + "auth/token-refresh";
  static String get userLogin => baseAuctionApi + "auth/users/login";
  static String get userRegister => baseAuctionApi + "auth/users";
  static String get userActivate => baseAuctionApi + "auth/activate-user";
  static String get userCheck => baseAuctionApi + "auth/check";
  static String get lotLogin => baseAuctionApi + "auth/lots/login";
  static String get forgotPasswordApi =>
      baseAuctionApi + "auth/users/forgot-password";
  static String get changePasswordApi =>
      baseAuctionApi + "auth/users/change-password";

  // auctions api
  static String get getAuctionsList => baseAuctionApi + "auctions";

  static String getAuctionLotsListApi(int auctionId,
      {int orgId, int lineId, int regionId}) {
    String url = baseAuctionApi + "auctions/$auctionId/lots?";
    if (orgId != null) url += "organizations=$orgId&";
    if (lineId != null) url += "lines=$lineId&";
    if (regionId != null) url += "regions=$regionId";
    return url;
  }

  static String get getDocumentListApi =>
      baseAuctionApi + "auctions/required/documents";
  static String applicationApi(int buyer_id) =>
      baseAuctionApi + "auctions/buyers/$buyer_id/application";
  static String requestRefund(int buyer_id) =>
      baseAuctionApi + "auctions/buyers/$buyer_id/claim-refund";
  static String get checkSubmissionApi =>
      baseAuctionApi + "auctions/lots/check/isapplied";
  static String get applyApi => baseAuctionApi + "auctions/lots/apply";
  static String uploadFile(int buyer_id, int lot_id) =>
      baseAuctionApi + "auctions/lots/$lot_id/buyers/$buyer_id";
  static String buyerLots(int userId, bool finished) =>
      baseAuctionApi + "auctions/users/$userId/lots?finished=$finished";
  static String finishedBuyerLots(int userId, bool finished) =>
      baseAuctionApi + "auctions/users/$userId/lots?finished=$finished";
  static String declinedFiles(int lot_id, int buyer_id) =>
      baseAuctionApi + "auctions/lots/$lot_id/buyers/$buyer_id";
  static String lotGameDetail(int lot_id, int buyer_id) =>
      baseAuctionApi + "auctions/realtime/lots/$lot_id/buyers/$buyer_id";
  static String live(int userId) =>
      baseAuctionApi + "auctions/users/$userId/lots-live?finished=false";
  static String auctionHelperData(int auctionId) =>
      baseAuctionApi + "auctions/helper-data/$auctionId";
  static String auctionLotDetail(int lot_id) =>
      baseAuctionApi + 'auctions/mobile-lots/$lot_id';
  static String buyerLotDetail(int userId, int lot_id, bool isFinished) =>
      baseAuctionApi +
      "auctions/users/$userId/lots/$lot_id?finished=$isFinished";
  static String auctionFormSubmit(int buyerId) =>
      baseAuctionApi + "auctions/buyers/$buyerId/form-submit";
  static String getRulesApi(int id) =>
      baseAuctionApi + "auctions/lot-rules/$id";

  // tendors api
  static String get getTendersList => baseTendorApi + "tenders";

  static String tendorLotList(int id, int orgId, int lineId) {
    String url = baseTendorApi + "tenders/$id/lots?";
    if (orgId != null) url += "organizations=$orgId&";
    if (lineId != null) url += "lines=$lineId&";
    return url;
  }

  static String get tendorRequiredDocs =>
      baseTendorApi + "tenders/required/documents";
  static String get tendorCheckSubmission =>
      baseTendorApi + "tenders/lots/check/isapplied";
  static String get tendorApply => baseTendorApi + "tenders/lots/apply";
  static String tendorDetail(int lot_id) =>
      baseTendorApi + "tenders/lots/$lot_id";
  static String tendorFileUpload(int lot_id, int seller_id) =>
      baseTendorApi + "tenders/lots/$lot_id/sellers/$seller_id";
  static String tendorFinishedLots(int userId, bool finished) =>
      baseTendorApi + "tenders/users/$userId/lots?finished=$finished";
  static String tendorBuyerLots(int userId, bool finished) =>
      baseTendorApi + "tenders/users/$userId/lots?finished=$finished";
  static String tenderHelperData(int id) =>
      baseTendorApi + "tenders/helper-data/$id";
  static String tenderApplicationApi(int seller_id) =>
      baseTendorApi + "tenders/sellers/$seller_id/application";
  static String tenderFormSubmit(int seller_id) =>
      baseTendorApi + "tenders/sellers/$seller_id/form-submit";

  // staff member
  static String get staffLogin => baseAuctionApi + "auth/members/login";
  static String get staffOtp => baseAuctionApi + "auth/member/check";
  static String staffLiveLots(int userId, bool finished) =>
      baseAuctionApi + "auctions/members/$userId/lots?finished=$finished";
  static String staffLotData(int lotId, int userId) =>
      baseAuctionApi + "auctions/realtime-member/lots/$lotId/members/$userId";
}

// 63665575 gp221090gp