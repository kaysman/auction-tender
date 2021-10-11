class Rule {
  Rule({
    this.id,
    this.rule_name,
    this.rule_location,
    this.rule_type,
    this.is_active = false,
    this.userAgreed = false,
  });

  final int id;
  final String rule_name;
  final int rule_type;
  final int rule_location;
  final bool is_active;
  bool userAgreed;

  factory Rule.fromMap(Map<String, dynamic> json) {
    if (json == null) return null;

    return Rule(
      id: json['id'],
      rule_name: json['rule_name'],
      rule_type: json['rule_type'],
      rule_location: json['rule_location'],
      is_active: json['is_active'],
    );
  }
}
