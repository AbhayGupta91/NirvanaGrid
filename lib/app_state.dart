import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _selectedAppliance = '';

  String get selectedAppliance => _selectedAppliance;

  void setSelectedAppliance(String appliance) {
    _selectedAppliance = appliance;
    notifyListeners();
  }
}