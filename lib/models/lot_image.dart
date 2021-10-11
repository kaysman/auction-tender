import 'package:maliye_app/config/apis.dart';

class LotImage {
  final int id;
  final String filename;
  final String destination;

  LotImage({this.id, this.filename, this.destination});

  factory LotImage.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return LotImage(
      id: json['id'] ?? 0,
      filename: json['filename'] ?? '',
      destination: json['destination'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "filename": filename,
      "destination": destination,
    };
  }

  String get getImage => baseApiUrl + ":" + filePort + destination + filename;
}
