import 'package:flutter/foundation.dart';

import '../services/ad_service.dart';

class NavigationProvider with ChangeNotifier {
  final AdService _adService = AdService();
  int _navigationCount = 0;

  void increment() {
    _navigationCount++;
    if (_navigationCount >= 5) {
      _adService.showInterstitialAd();
      _navigationCount = 0;
    }
    notifyListeners();
  }
}
