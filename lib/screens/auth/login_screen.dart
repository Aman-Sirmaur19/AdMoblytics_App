import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../widgets/custom_banner_ad.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      bottomNavigationBar: const CustomBannerAd(),
      body: Column(
        children: [
          SizedBox(height: isLandscape ? 30 : 200),
          Expanded(
            child: ListView(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 30,
                  child: Image.asset('assets/images/icon.png', height: 40),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'M',
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.red,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'o',
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'b',
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'lytics',
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLandscape) ...[
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
                ],
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
            onPressed: () {
              context.read<NavigationProvider>().increment();
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const DemoTabsScreen(),
                ),
              );
            },
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
          SizedBox(height: isLandscape ? 20 : 50),
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
