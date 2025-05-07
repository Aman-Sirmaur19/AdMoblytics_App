import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_banner_ad.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AdMob Login')),
      bottomNavigationBar: const CustomBannerAd(),
      body: Center(
        child: ElevatedButton(
          onPressed: authProvider.isLoading
              ? null
              : () async {
                  await authProvider.login();
                },
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Text('Login with Google'),
        ),
      ),
    );
  }
}
