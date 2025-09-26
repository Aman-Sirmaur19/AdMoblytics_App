import 'package:flutter/material.dart';

class AppsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _apps = [];
  final Map<String, Map<String, String>> _appIcons = {};
  bool _isLoaded = false;

  List<Map<String, dynamic>> get apps => _apps;

  bool get isLoaded => _isLoaded;

  void setApps(List<Map<String, dynamic>> apps) {
    _apps = apps;
    _isLoaded = true;
    notifyListeners();
  }

  void setAppIcon(String appId, String appStoreId, String iconUrl) {
    _appIcons[appId] = {'appStoreId': appStoreId, 'iconUrl': iconUrl};
    notifyListeners();
  }

  String? getAppIcon(String appId) => _appIcons[appId]?['iconUrl'];
}
