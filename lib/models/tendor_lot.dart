import 'package:maliye_app/models/document.dart';

import 'lot_image.dart';
import 'organization.dart';
import 'package:maliye_app/config/extensions.dart';

class TendorLot {
  final int id;
  final int tendorId;
  final bool status;
  final int lotNumber;
  final DateTime startingDate;
  final Organization organization;
  final bool finished;
  final int winnerBuyerId;
  final String assetName;
  final BusinessLine businessLine;
  final List<LotImage> lotImages;
  final List<LotImage> technicalRequirements;
  final List<Document> documents;
  final int seller_id;
  final bool formSubmission;
  final bool applicationSubmission;
  final String link;
  final String linkText;

  TendorLot({
    this.id,
    this.status,
    this.lotNumber,
    this.startingDate,
    this.organization,
    this.finished,
    this.winnerBuyerId,
    this.assetName,
    this.businessLine,
    this.lotImages,
    this.tendorId,
    this.seller_id,
    this.formSubmission,
    this.technicalRequirements,
    this.applicationSubmission,
    this.documents,
    this.link,
    this.linkText,
  });

  factory TendorLot.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return TendorLot(
      id: json['id'] ?? 0,
      tendorId: json['tender_id'] ?? 0,
      seller_id: json['seller_id'],
      status: json['status'],
      lotNumber: json['lot_number'],
      startingDate: DateTime.tryParse(json['starting_date']),
      organization: Organization.fromJson(json['organization']),
      finished: json['finished'] ?? false,
      winnerBuyerId: json['winner_buyer_id'] ?? 0,
      assetName: json['project_name'] ?? '',
      businessLine: BusinessLine.fromJson(json["line"]),
      formSubmission: json["form_submission"],
      applicationSubmission: json['application_submission'],
      link: json['link'],
      linkText: json['link_text'],
      documents: json['documents'] == null
          ? null
          : (json['documents'] ?? {}).keys.map<Document>((key) {
              return Document(
                title: key,
                // files: (((json['documents'] ?? {})[key]['files'] ?? []) as List)
                //     .map((json) => File.fromJson(json))
                //     .toList(),
                status: json['documents'][key]['status'],
                note: json['documents'][key]['note'],
              );
            }).toList(),
      lotImages: ((json["photos"] ?? []) as List)
          .map((json) => LotImage.fromJson(json))
          .toList(),
      technicalRequirements: ((json['technical_requirements'] ?? []) as List)
          .map((json) => LotImage.fromJson(json))
          .toList(),
    );
  }

  String formattedStartingDate() {
    String formatPattern = "dd/MM/yyyy   |   HH:mm";
    var date = startingDate;
    return date.toLocal().format(formatPattern);
  }

  @override
  String toString() {
    return "Lot No: $id Name: $assetName";
  }
}
