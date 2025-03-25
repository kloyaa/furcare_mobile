import 'package:flutter/material.dart';
import 'package:furcare_app/models/user_info.dart';

class ClientProvider extends ChangeNotifier {
  Profile? _profile;
  List<dynamic>? _pets;
  Owner? _ownerProfile;

  Profile? get profile => _profile;
  Owner? get ownerProfile => _ownerProfile;
  List<dynamic>? get pets => _pets;

  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  void setOwner(Owner ownerProfile) {
    _ownerProfile = ownerProfile;
    notifyListeners();
  }

  void setPets(List<dynamic> pets) {
    _pets = pets;
    notifyListeners();
  }
}
