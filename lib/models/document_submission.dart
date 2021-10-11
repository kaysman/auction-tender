import 'package:maliye_app/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum Status { APPROVED, REJECTED, INREVIEW }

extension Props on Status {
  Color get getBackgroundColor {
    switch (this) {
      case Status.APPROVED:
        return const Color(Constants.appBlue);
      case Status.REJECTED:
        return Colors.red;
      case Status.INREVIEW:
        return Color(0xFFFDB51B);
      default:
        return Colors.transparent;
    }
  }

  SvgPicture get getIcon {
    switch (this) {
      case Status.APPROVED:
        return SvgPicture.asset("assets/svg/check.svg");
      case Status.REJECTED:
        return SvgPicture.asset("assets/svg/reject.svg");
      case Status.INREVIEW:
        return SvgPicture.asset("assets/svg/pause.svg");
      default:
        return SvgPicture.asset("assets/svg/file.svg");
    }
  }
}

class DocumentSubmissionStatus {
  final String note;
  final Status status;

  DocumentSubmissionStatus({this.note, this.status});

  factory DocumentSubmissionStatus.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return DocumentSubmissionStatus(
      note: json['note'] ?? "",
      status: (json['status'] == true)
          ? Status.APPROVED
          : (json['status'] == false)
              ? Status.REJECTED
              : Status.INREVIEW,
    );
  }
}
