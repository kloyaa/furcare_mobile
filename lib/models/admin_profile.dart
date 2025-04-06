class AdminProfileModel {
  final String id;
  final String user;
  final String fullName;
  final String address;
  final Map<String, String> contact;
  final String facebook;
  final String messenger;
  final bool isActive;
  final int v;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminProfileModel({
    required this.id,
    required this.user,
    required this.fullName,
    required this.address,
    required this.contact,
    required this.facebook,
    required this.messenger,
    required this.isActive,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileModel(
      id: json['_id'],
      user: json['user'],
      fullName: json['fullName'],
      address: json['address'],
      contact: Map<String, String>.from(json['contact']),
      facebook: json['facebook'],
      messenger: json['messenger'],
      isActive: json['isActive'],
      v: json['__v'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
