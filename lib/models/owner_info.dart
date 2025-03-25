class OwnerProfile {
  final String id;
  final String user;
  final String name;
  final String address;
  final String mobileNo;
  final String email;
  final String emergencyContactNo;
  final String work;
  final String createdAt;
  final String updatedAt;
  final int v;

  OwnerProfile({
    required this.id,
    required this.user,
    required this.name,
    required this.address,
    required this.mobileNo,
    required this.email,
    required this.emergencyContactNo,
    required this.work,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    return OwnerProfile(
      id: json['_id'],
      user: json['user'],
      name: json['name'],
      address: json['address'],
      mobileNo: json['mobileNo'],
      email: json['email'],
      emergencyContactNo: json['emergencyContactNo'],
      work: json['work'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class OwnerProfilePayload {
  final String emergencyContactNo;
  final String work;

  OwnerProfilePayload({
    required this.emergencyContactNo,
    required this.work,
  });

  Map<String, dynamic> toJson() {
    return {
      'emergencyContactNo': emergencyContactNo,
      'work': work,
    };
  }
}
