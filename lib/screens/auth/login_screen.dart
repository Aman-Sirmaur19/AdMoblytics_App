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
      bottomNavigationBar: const CustomBannerAd(),
      body: Column(
        children: [
          const SizedBox(height: 200),
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 30,
                        child: Image.asset(
                          'assets/images/icon-no-bg.png',
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 55,
                        right: 40,
                        child: Container(
                          width: 245,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xff0f9d58),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 40,
                        // Adjust this to control the distance between image and text
                        child: Text(
                          'dMoblytics',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 70),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login your google account to',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '📊 See your apps performance\n📈 Get user trends\n💸 Check earning and payments',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                if (authProvider.accountId == null &&
                    authProvider.user != null) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 80),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'This email is not registered as\n"AdMob Publisher Account"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ElevatedButton(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    await authProvider.logout();
                    await authProvider.login();
                  },
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Sign in with Google'),
          ),
          const SizedBox(height: 50),
          const Text(
            'MADE WITH ❤️ IN 🇮🇳',
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 1.5,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
