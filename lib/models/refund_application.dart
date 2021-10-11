class RefundApplication {
  final String note;
  final bool status;
  final bool isApplied;

  RefundApplication({
    this.isApplied,
    this.note,
    this.status,
  });

  factory RefundApplication.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return RefundApplication(
      note: json['note'] ?? '',
      status: json['status'],
      isApplied: json['is_applied'] ?? false,
    );
  }
}
