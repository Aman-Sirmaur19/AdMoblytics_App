import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'utils/theme.dart';
import 'firebase_options.dart';
import 'providers/tab_provider.dart';
import 'providers/apps_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/bottom_tab_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _initializeMobileAds();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => TabProvider()),
      ChangeNotifierProvider(create: (_) => AppsProvider()),
      ChangeNotifierProvider(create: (_) => AccountProvider()),
      ChangeNotifierProvider(create: (_) => CurrencyProvider()..loadCurrency()),
    ],
    child: const MyApp(),
  ));
}

Future<void> _initializeMobileAds() async {
  await MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moblytics',
      theme: lightMode,
      darkTheme: darkMode,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    return authProvider.accountId != null && authProvider.user != null
        ? const BottomTabScreen()
        : const LoginScreen();
  }
}

/*
currency feature
initial date of admob earning
line graph without past data
line graph axis color
estimated earning in custom days (ML)
upgrade/downgrade subscriptions
line chart not showing from start of the axis
*/
