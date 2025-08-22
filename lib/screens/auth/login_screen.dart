import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../services/ad_manager.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_banner_ad.dart';
import '../demo/tabs_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          _update();
        }
      });
    }).catchError((error) {});
  }

  void _update() async {
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {});
  }

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
                            color: const Color(0xff34a853),
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
                        '📊 See your apps performance\n📈 Get user trends\n💸 Check your apps earning',
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
          OutlinedButton(
            onPressed: () =>
                AdManager().navigateWithAd(context, DemoTabsScreen()),
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Try Demo App'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    await authProvider.logout();
                    await authProvider.login();
                  },
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            icon: Image.asset('assets/images/google.png', width: 20),
            label: const Text('Sign in with Google'),
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
