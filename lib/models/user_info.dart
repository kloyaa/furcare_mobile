import 'package:furcare_app/models/pet_info.dart';

class BasicInfo {
  final String fullName;
  final String birthdate;

  const BasicInfo({required this.fullName, required this.birthdate});

  factory BasicInfo.fromJson(Map<String, dynamic> json) => BasicInfo(
    fullName: json['fullName'] ?? '',
    birthdate: json['birthdate'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'birthdate': birthdate,
  };
}

class Address {
  final String present;
  final String permanent;

  const Address({required this.present, required this.permanent});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    present: json['present'] ?? '',
    permanent: json['permanent'] ?? '',
  );

  Map<String, dynamic> toJson() => {'present': present, 'permanent': permanent};
}

class Contact {
  final String email;
  final String number;

  const Contact({required this.email, required this.number});

  factory Contact.fromJson(Map<String, dynamic> json) =>
      Contact(email: json['email'] ?? '', number: json['number'] ?? '');

  Map<String, dynamic> toJson() => {'email': email, 'number': number};
}

class Profile {
  final BasicInfo basicInfo;
  final String address;
  final Contact contact;
  final bool isActive;

  final String facebook;
  final String messenger;

  const Profile({
    required this.basicInfo,
    required this.address,
    required this.contact,
    required this.isActive,
    required this.facebook,
    required this.messenger,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    basicInfo: BasicInfo.fromJson(json),
    contact: Contact.fromJson(json['contact'] ?? {}),
    isActive: json['isActive'] ?? false,
    address: json['address'],
    facebook: json['facebook'],
    messenger: json['messenger'],
  );

  Map<String, dynamic> toJson() => {
    ...basicInfo.toJson(),
    'isActive': isActive,
    'address': address,
    'contact': contact.toJson(),
    'facebook': facebook,
    'messenger': messenger,
  };
}

class Customer {
  final String id;
  final String username;
  final String email;
  final String createdAt;
  final String updatedAt;
  final Profile profile;
  final Owner owner;
  final List<Pet> pets;

  const Customer({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
    required this.owner,
    required this.pets,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['_id'] ?? '',
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
    profile: Profile.fromJson(json['profile'] ?? {}),
    owner: Owner.fromJson(json['owner'] ?? {}),
    pets:
        (json['pets'] as List<dynamic>? ?? [])
            .map((petJson) => Pet.fromJson(petJson))
            .toList(),
  );
}

class Owner {
  final String id;
  final String name;
  final String address;
  final String mobileNo;
  final String email;
  final String emergencyContactNo;
  final String work;
  final String createdAt;
  final String updatedAt;

  const Owner({
    required this.id,
    required this.name,
    required this.address,
    required this.mobileNo,
    required this.email,
    required this.emergencyContactNo,
    required this.work,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    mobileNo: json['mobileNo'] ?? '',
    email: json['email'] ?? '',
    emergencyContactNo: json['emergencyContactNo'] ?? '',
    work: json['work'] ?? '',
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
  );
}
