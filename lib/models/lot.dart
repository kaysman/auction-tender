import 'package:maliye_app/models/region.dart';
import 'package:intl/intl.dart';
import 'bid.dart';
import 'buyer.dart';
import 'buyer_application.dart';
import 'buyer_submission.dart';
import 'document.dart';
import 'document_submission.dart';
import 'lot_image.dart';
import 'organization.dart';
import 'package:maliye_app/config/extensions.dart';

import 'refund_application.dart';

class LotBig {
  final int id;
  final int auctionId;
  final bool status;
  final int lotNumber;
  final int buyer_id;
  final String startingPrice;
  final DateTime startingDate;
  final double increasePercentage;
  final int timer;
  final Organization organization;
  final bool finished;
  final int winnerBuyerId;
  final String assetName;
  final double assetArea;
  final String assetAddress;
  final String constructionYear;
  final BusinessLine businessLine;
  final List<LotImage> lotImages;
  final BuyerSubmissionStatus buyerSubmissionStatus;
  final bool formSubmission;
  final DocumentSubmissionStatus documentSubmissionStatus;
  final BuyerApplication buyerApplication;
  final ApplicationSubmission applicationSubmission;
  final List<Document> documents;
  final Region region;
  final int ticketNo;
  final String link;
  final String linkText;

  final RefundApplication refunApplication;
  final int step;
  final bool isWinner;

  final List<Buyer> buyerList;
  final Buyer me;
  // final List<Bid> adminBids;
  final Bid currentBid;
  final String token;

  LotBig({
    this.id,
    this.auctionId,
    this.status,
    this.lotNumber,
    this.startingPrice,
    this.startingDate,
    this.increasePercentage,
    this.timer,
    this.organization,
    this.finished,
    this.winnerBuyerId,
    this.assetArea,
    this.assetName,
    this.assetAddress,
    this.businessLine,
    this.constructionYear,
    this.buyer_id,
    this.lotImages,
    this.buyerSubmissionStatus,
    this.documentSubmissionStatus,
    this.formSubmission,
    this.buyerApplication,
    this.applicationSubmission,
    this.documents,
    this.region,
    this.ticketNo,
    this.refunApplication,
    this.buyerList,
    this.currentBid,
    this.me,
    this.token,
    this.isWinner,
    this.step,
    this.link,
    this.linkText,
  });

  factory LotBig.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return LotBig(
      id: json['id'] ?? 0,
      auctionId: json['auction_id'],
      status: json['status'],
      lotNumber: json['lot_number'] ?? 0,
      startingPrice: json['starting_price'].toString(),
      startingDate: DateTime.tryParse(json['starting_date']),
      increasePercentage: double.tryParse(json['increase_percentage'] ?? ''),
      timer: json['timer'] ?? 0,
      organization: Organization.fromJson(json['organization']),
      finished: json['finished'] ?? false,
      winnerBuyerId: json['winner_buyer_id'] ?? 0,
      assetName: json['project_name'] ?? '',
      assetArea: double.tryParse(json['project_area']?.toString() ?? '0'),
      assetAddress: json["project_address"] ?? "",
      constructionYear: json['construction_year'] ?? '',
      businessLine: BusinessLine.fromJson(json["business_line"]),
      buyer_id: json['buyer_id'] ?? 0,
      link: json['link'],
      linkText: json['link_text'],
      lotImages: ((json["photos"] ?? []) as List)
          .map((json) => LotImage.fromJson(json))
          .toList(),
      buyerSubmissionStatus:
          BuyerSubmissionStatus.fromJson(json['buyer_submission_status']),
      documentSubmissionStatus: DocumentSubmissionStatus.fromJson(
        json['documents_submission'],
      ),
      formSubmission: json['form_submission'],
      buyerApplication: BuyerApplication.fromJson(json['buyer_application']),
      refunApplication: RefundApplication.fromJson(json['refund_application']),
      applicationSubmission: ApplicationSubmission.fromJson(
        json['applicaton_submission'],
      ),
      region: Region.fromJson(json['region']),
      documents: json['documents'] == null
          ? null
          : (json['documents'] ?? {}).keys.map<Document>((key) {
              return Document(
                title: key,
                status: json['documents'][key]['status'],
                note: json['documents'][key]['note'],
              );
            }).toList(),
      ticketNo: json['ticket_number'],
      buyerList: ((json['buyer_list'] ?? []) as List)
          .map((json) => Buyer.fromJson(json))
          .toList(),
      me: Buyer.fromJson(json['buyer'] ?? {}),
      currentBid: Bid.fromJson(json['current_bid']),
      token: json['token'] ?? '',
      step: json['step'],
      isWinner: json['is_winner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': this.id,
        'auction_id': this.auctionId,
        'status': this.status,
        'lot_number': this.lotNumber,
        'starting_price': this.startingPrice,
        'starting_date': this.startingDate?.toIso8601String(),
        'increase_percentage': this.increasePercentage,
        'timer': this.timer,
        'organization': this.organization.toJson(),
        'finished': this.finished,
        'winner_buyer_id': this.winnerBuyerId,
      };

  String formattedStartingDate() {
    String formatPattern = "dd/MM/yyyy   |   HH:mm";
    // var date = startingDate.isUtc ? startingDate : startingDate.toUtc();
    var date = startingDate;
    return date.format(formatPattern);
  }

  String formmattedArea() {
    return assetArea != null
        ? NumberFormat.currency(locale: 'uz', symbol: '').format(assetArea)
        : "0";
  }

  @override
  String toString() => "Lot No: $lotNumber Name: $assetName";
}
