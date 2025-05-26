import 'package:flutter/material.dart';

class TabProvider with ChangeNotifier {
  int _selectedTabIndex = 2;

  int get selectedTabIndex => _selectedTabIndex;

  void updateTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
}
