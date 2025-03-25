import 'package:flutter/material.dart';

class FeesProvider extends ChangeNotifier {
  List<dynamic>? _serviceFees;

  List<dynamic>? get serviceFees => _serviceFees;

  void setServiceFees(List<dynamic> serviceFees) {
    _serviceFees = serviceFees;
    notifyListeners();
  }
}
