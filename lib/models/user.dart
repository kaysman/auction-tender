class User {
  final int id;
  final String firstName;
  final String surname;
  final String fatherName;
  final String passportNo;
  final String phone;
  final String fullname;
  final int organizationId;
  final int roleId;
  final bool status;
  final bool isTeamMember;

  User({
    this.id,
    this.phone,
    this.fatherName,
    this.firstName,
    this.passportNo,
    this.surname,
    this.fullname,
    this.organizationId,
    this.roleId,
    this.status,
    this.isTeamMember = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return User(
      id: json['id'] ?? 0,
      firstName: json['firstname'],
      surname: json['lastname'],
      fatherName: json['patronymic'],
      passportNo: json['passport'],
      phone: json['phone'],
      fullname: json['fullname'],
      organizationId: json['organization_id'],
      roleId: json['role_id'],
      status: json['status'],
      isTeamMember: json['type'] == "member",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "firstname": firstName,
      "lastname": surname,
      "patronymic": fatherName,
      "passport": passportNo,
      "phone": phone,
    };
  }

  String get getPhone => "+993 " + phone;
}
