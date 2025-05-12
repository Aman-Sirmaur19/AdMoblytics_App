import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_icon.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../services/admob_service.dart';
import '../../providers/apps_provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard_screen.dart';
import '../home/card_summary_screen.dart';

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final admobService = AdMobService(authProvider.accessToken!);
    final appsProvider = Provider.of<AppsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const DashboardScreen())),
            tooltip: 'Dashboard',
            icon: const Icon(CupertinoIcons.square_grid_2x2),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: FutureBuilder(
        future: appsProvider.isLoaded
            ? Future.value(null)
            : admobService.fetchPublishedApps(
                accessToken: authProvider.accessToken!,
                accountId: authProvider.accountId!,
              ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (!appsProvider.isLoaded && snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final data = snapshot.data as Map<String, dynamic>;
                appsProvider.setApps(
                    (data['apps'] as List).cast<Map<String, dynamic>>());
              });
            }
            final apps = appsProvider.apps;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final appId = apps[index]['linkedAppInfo']?['appStoreId'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => CardSummaryScreen(
                          section: 'APP',
                          appName: apps[index]['linkedAppInfo'] != null
                              ? apps[index]['linkedAppInfo']['displayName']
                              : apps[index]['manualAppInfo']['displayName'],
                          appId: apps[index]['appId'],
                        ),
                      ),
                    ),
                    leading: AppIcon(appId: appId),
                    title: Text(
                      apps[index]['linkedAppInfo'] != null
                          ? apps[index]['linkedAppInfo']['displayName']
                          : apps[index]['manualAppInfo']['displayName'],
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apps[index]['linkedAppInfo'] != null
                              ? apps[index]['linkedAppInfo']['appStoreId']
                              : apps[index]['appApprovalState'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          apps[index]['platform'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
