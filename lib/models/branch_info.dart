class Branch {
  final String? id;
  final String name;
  final String address;
  final bool isActive;
  final String mobileNo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Branch({
    this.id,
    required this.name,
    required this.address,
    required this.isActive,
    required this.mobileNo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      isActive: json['isActive'],
      mobileNo: json['mobileNo'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
