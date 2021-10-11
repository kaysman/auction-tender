class Region {
  Region({this.id, this.value});

  final int id;
  final String value;

  factory Region.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Region(
      id: json['id'],
      value: json['value'],
    );
  }
}

class Line {
  Line({this.id, this.value});

  final int id;
  final String value;

  factory Line.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Line(
      id: json['id'],
      value: json['value'],
    );
  }
}
