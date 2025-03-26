import 'package:flutter/material.dart';
import 'package:furcare_app/models/branch_info.dart';

class BranchProvider extends ChangeNotifier {
  Branch? _branch;
  Branch? get branch => _branch;

  void setBranch(Branch branch) {
    _branch = branch;
    notifyListeners();
  }
}
