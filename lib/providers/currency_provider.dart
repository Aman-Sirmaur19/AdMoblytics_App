import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currencyCode = "USD";
  String _currencySymbol = "\$"; // default for USD

  String get currencyCode => _currencyCode;

  String get currencySymbol => _currencySymbol;

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString("currencyCode") ?? "USD";
    _currencySymbol = prefs.getString("currencySymbol") ?? "\$";
    notifyListeners();
  }

  Future<void> setCurrency(String code, String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = code;
    _currencySymbol = symbol;
    await prefs.setString("currencyCode", code);
    await prefs.setString("currencySymbol", symbol);
    notifyListeners();
  }
}
