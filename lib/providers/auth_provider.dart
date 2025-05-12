import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/admob.report',
      'https://www.googleapis.com/auth/admob.readonly',
    ],
  );

  GoogleSignInAccount? _user;
  String? _accessToken;
  String? _accountId;
  bool _isLoading = false;

  GoogleSignInAccount? get user => _user;

  String? get accessToken => _accessToken;

  String? get accountId => _accountId;

  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _googleSignIn.signInSilently();
      if (_user != null) {
        await _fetchAccessToken();
        await _fetchAdMobAccountId();
      }
    } catch (error) {
      throw Exception('Error during silent sign-in: $error');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _googleSignIn.signIn();
      if (_user != null) {
        await _fetchAccessToken();
        await _fetchAdMobAccountId();
      }
    } catch (error) {
      throw Exception('Login failed: $error');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchAccessToken() async {
    final authHeaders = await _user?.authHeaders;
    _accessToken = authHeaders?['Authorization']?.split(' ').last;
    notifyListeners();
  }

  Future<void> _fetchAdMobAccountId() async {
    if (_accessToken == null) return;

    final url = Uri.parse('https://admob.googleapis.com/v1/accounts');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['account'] != null && data['account'].isNotEmpty) {
        _accountId = data['account'][0]['publisherId'];
        notifyListeners();
      } else {}
    } else {}
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    _user = null;
    _accessToken = null;
    _accountId = null;
    notifyListeners();
  }
}
