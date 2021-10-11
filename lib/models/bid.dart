class Bid {
  final int id;
  final double bidAmount;
  // final DateTime bidTime;
  final bool isAccepting;

  Bid({
    this.id,
    this.bidAmount,
    // this.bidTime,
    this.isAccepting,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Bid(
      id: json['id'],
      bidAmount: double.tryParse(json['bid_amount'].toString()) ?? 0.0,
      // bidTime: DateTime.tryParse(json['bid_time']) ?? '',
      isAccepting: json['is_accepting'] ?? false,
    );
  }
}
