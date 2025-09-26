import 'package:flutter/material.dart';

import '../../services/admob_service.dart';

class AccountProvider with ChangeNotifier {
  Map<String, dynamic>? _accountDetails;
  bool _isLoading = false;
  bool _hasError = false;

  // Public getters to access the state from the UI
  Map<String, dynamic>? get accountDetails => _accountDetails;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  // Fetches data ONLY if it hasn't been fetched before.
  Future<void> fetchAccountIfNeeded(AdMobService admobService) async {
    // If data already exists, do nothing. This is the key to caching.
    if (_accountDetails != null) {
      return;
    }

    // If there's no data, fetch it.
    await _fetchData(admobService);
  }

  // Forces a refresh, ignoring any cached data.
  Future<void> refreshAccount(AdMobService admobService) async {
    await _fetchData(admobService);
  }

  // Private helper method to handle the actual data fetching and state updates.
  Future<void> _fetchData(AdMobService admobService) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners(); // Notify UI that we are in loading state

    try {
      _accountDetails = await admobService.fetchAccountDetails();
      _hasError = false;
    } catch (e) {
      _hasError = true;
      _accountDetails = null; // Clear old data on error
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is complete (with or without data)
    }
  }
}
