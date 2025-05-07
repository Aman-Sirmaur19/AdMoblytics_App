import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/admob_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_banner_ad.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final accessToken =
        authProvider.user?.authentication.then((auth) => auth.accessToken);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: FutureBuilder(
        future: accessToken,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final token = snapshot.data as String;
            return AdMobDataScreen(
              accessToken: token,
              imgUrl: authProvider.user!.photoUrl!,
              userName: authProvider.user!.displayName!,
            );
          } else {
            return const Center(child: Text('Failed to load data.'));
          }
        },
      ),
    );
  }
}

class AdMobDataScreen extends StatelessWidget {
  final String accessToken;
  final String imgUrl;
  final String userName;

  const AdMobDataScreen({
    super.key,
    required this.accessToken,
    required this.imgUrl,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final admobService = AdMobService(accessToken);

    return FutureBuilder(
      future: admobService.fetchAccountDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.blue));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data as Map<String, dynamic>;
          final account = data['account']?[0];
          final accountId = account['publisherId'] ?? 'Unknown';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: imgUrl,
                      height: 60,
                      width: 60,
                    )),
                const SizedBox(height: 20),
                _customRichText('Name:\n', userName),
                const SizedBox(height: 20),
                _customRichText('Publisher ID:\n', accountId),
                const SizedBox(height: 20),
                _customRichText('Currency Code:\n', account['currencyCode']),
                const SizedBox(height: 20),
                _customRichText('Time Zone:\n', account['reportingTimeZone']),
              ],
            ),
          );
        } else {
          return const Center(child: Text('Failed to fetch account details.'));
        }
      },
    );
  }

  Widget _customRichText(String title, String value) {
    return RichText(
        text: TextSpan(
      text: title,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.bold,
      ),
      children: [
        TextSpan(
          text: value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ));
  }
}
