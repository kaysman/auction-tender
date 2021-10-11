class BuyerSubmissionStatus {
  final int id;
  final String value;
  final String code;

  BuyerSubmissionStatus({this.id, this.value, this.code});

  factory BuyerSubmissionStatus.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return BuyerSubmissionStatus(
      id: json['id'] ?? 0,
      value: json['value'] ?? '',
      code: json['code'] ?? '',
    );
  }
}
