class Buyer {
  final int id;
  final int userId;
  final int lotId;
  final int ticketNumber;
  final bool proceed;
  final int lastBidId;
  final bool connected;
  final String firstname;
  final String lastname;

  Buyer({
    this.connected,
    this.id,
    this.lastBidId,
    this.lotId,
    this.proceed,
    this.ticketNumber,
    this.userId,
    this.firstname,
    this.lastname,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return Buyer(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      lotId: json['lot_id'] ?? 0,
      ticketNumber: json['ticket_number'],
      proceed: json['proceed'],
      lastBidId: json['last_bid_id'],
      connected: json['connected'] ?? false,
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
    );
  }
}
