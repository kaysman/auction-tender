import 'package:maliye_app/config/extensions.dart';

class Competition {
  final int id;
  final String title;
  final String lotCount;
  final DateTime createdAt;

  Competition({this.id, this.title, this.createdAt, this.lotCount});

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      lotCount: json['lot_count'],
      createdAt: DateTime.tryParse(json['created_at']),
    );
  }

  String get getCreatedAt => this.createdAt.format("dd/MM/yyyy");
}
