class Region {
  final int id;
  final String value;
  final String filial;
  final String location;
  final List<Contact> faxList;
  final List<Contact> phoneList;

  Region({
    this.faxList,
    this.filial,
    this.id,
    this.location,
    this.phoneList,
    this.value,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return Region(
      id: json['id'],
      value: json['value'],
      filial: json['filial'],
      faxList: ((json['fax_list'] ?? []) as List)
          .map((json) => Contact.fromJson(json))
          .toList(),
      phoneList: ((json['phone_list'] ?? []) as List)
          .map((json) => Contact.fromJson(json))
          .toList(),
    );
  }

  String get getPhoneList =>
      phoneList.map((e) => "+993 " + e.value + " ").join(",");

  String get getFaxList =>
      faxList.map((e) => "+993 " + e.value + " ").join(",");
}

class Contact {
  final String id;
  final String value;
  final String type;

  Contact({this.id, this.type, this.value});

  factory Contact.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return Contact(
      id: json['id'],
      value: json['value'],
      type: json['type'],
    );
  }
}
