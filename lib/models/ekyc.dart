import 'package:furcare_app/models/user_info.dart';

class Ekyc {
  final Account account;
  final Profile profile;

  Ekyc({required this.account, required this.profile});

  factory Ekyc.fromJson(Map<String, dynamic> json) {
    return Ekyc(
      account: Account.fromJson(json['account']),
      profile: Profile.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> profileJson = profile.toJson();
    profileJson.remove('isActive');
    profileJson.remove('gender');
    return {'account': account.toJson(), 'profile': profileJson};
  }
}

class Account {
  final String email;
  final String username;
  final String password;

  Account({
    required this.email,
    required this.username,
    required this.password,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['email'],
      username: json['username'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'username': username, 'password': password};
  }
}
