import 'package:flutter/material.dart';
import 'package:furcare_app/models/auth_token.dart';
import 'package:furcare_app/models/user_info.dart';

class AuthTokenProvider extends ChangeNotifier {
  AuthToken? _authToken;

  AuthToken? get authToken => _authToken;

  void setAuthToken(String accessToken) {
    _authToken = AuthToken(accessToken);
    notifyListeners();
  }
}

class RegistrationProvider extends ChangeNotifier {
  BasicInfo? _basicInfo;
  Address? _address;
  Contact? _contact;

  BasicInfo? get basicInfo => _basicInfo;
  Address? get address => _address;
  Contact? get contact => _contact;

  void setBasicInfo(BasicInfo value) {
    _basicInfo = value;
    notifyListeners();
  }

  void setAddress(Address value) {
    _address = value;
    notifyListeners();
  }

  void setContact(Contact value) {
    _contact = value;
    notifyListeners();
  }
}
