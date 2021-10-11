class Organization {
  final int id;
  final String name;
  final String phone;
  final String address;

  Organization({this.id, this.name, this.address, this.phone});

  factory Organization.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Organization(
      id: json['id'],
      name: json['value'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "address": address,
    };
  }

  String get getPhone => phone.isNotEmpty ? "+" + phone : "";
}

class BusinessLine {
  final int id;
  final String name;

  BusinessLine({this.id, this.name});

  factory BusinessLine.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return BusinessLine(id: json['id'] ?? 0, name: json['value'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "value": name};
  }
}
