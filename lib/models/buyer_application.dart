import 'document_submission.dart';

class BuyerApplication {
  final int id;
  final General general;
  final String publishedData;
  final double transferredMoney;
  final double collectionMoney;
  final double totalMoney;
  final String bankAccount;
  final String bank;
  final String settlementAccount;
  final String taxCode;
  final String bab;
  final ApplicationSubmission applicationSubmission;

  BuyerApplication({
    this.id,
    this.general,
    this.publishedData,
    this.transferredMoney,
    this.collectionMoney,
    this.totalMoney,
    this.bank,
    this.bankAccount,
    this.settlementAccount,
    this.taxCode,
    this.bab,
    this.applicationSubmission,
  });

  factory BuyerApplication.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return BuyerApplication(
      id: json['id'],
      general: General.fromJson(json['general']),
      publishedData: json['published_data'],
      transferredMoney: json['transferred_money']?.toDouble(),
      collectionMoney: json['collection_money']?.toDouble(),
      totalMoney: json['total_money']?.toDouble(),
      bankAccount: json['bank_account'],
      bank: json['bank'],
      settlementAccount: json['settlement_account'],
      taxCode: json['tax_code'],
      bab: json['bab'],
      applicationSubmission: ApplicationSubmission.fromJson(
        json['applicaton_submission'],
      ),
    );
  }
}

class General {
  final String name;
  final String type;
  final String address;
  final String lastname;
  final String passport;
  final String position;
  final String firstname;
  final String fathername;
  final bool isOrganization;

  General({
    this.address,
    this.fathername,
    this.firstname,
    this.isOrganization,
    this.lastname,
    this.name,
    this.passport,
    this.position,
    this.type,
  });

  factory General.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return General(
      name: json['name'],
      type: json['type'],
      address: json['address'] ?? '',
      lastname: json['lastname'] ?? '',
      passport: json['passport'] ?? '',
      position: json['position'] ?? '',
      firstname: json['firstname'] ?? '',
      fathername: json['patronymic'] ?? '',
      isOrganization: json['is_organization'] ?? false,
    );
  }
}

class ApplicationSubmission {
  final String note;
  final Status applicationStatus;
  final bool updated;

  ApplicationSubmission({
    this.note,
    this.applicationStatus,
    this.updated,
  });

  factory ApplicationSubmission.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return ApplicationSubmission(
      note: json['note'],
      updated: json['updated'] ?? false,
      applicationStatus: (json['status'] == true)
          ? Status.APPROVED
          : (json['status'] == false)
              ? Status.REJECTED
              : Status.INREVIEW,
    );
  }
}
