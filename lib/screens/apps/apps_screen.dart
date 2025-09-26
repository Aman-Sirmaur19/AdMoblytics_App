import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../utils/dialogs.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../services/admob_service.dart';
import '../../providers/apps_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../dashboard_screen.dart';
import '../home/app_summary_screen.dart';

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
            onPressed: () {
              context.read<NavigationProvider>().increment();
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const DashboardScreen(),
                ),
              );
            },
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
                final app = apps[index];
                final storeUrl = Utils.getStoreUrl(
                    app['appApprovalState'] == 'APPROVED'
                        ? app['linkedAppInfo']['appStoreId']
                        : app['appApprovalState']);

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 10, right: 5),
                    tileColor: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onTap: () {
                      context.read<NavigationProvider>().increment();
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => AppSummaryScreen(
                            section: 'APP',
                            appName: app['linkedAppInfo'] != null
                                ? app['linkedAppInfo']['displayName']
                                : app['manualAppInfo']['displayName'],
                            appId: app['appId'],
                            customStartDate: DateTime.now(),
                            customEndDate: DateTime.now(),
                          ),
                        ),
                      );
                    },
                    leading: AppIcon(appData: {
                      'appId': app['appId'],
                      'appStoreId': app['appApprovalState'] == 'APPROVED'
                          ? app['linkedAppInfo']['appStoreId']
                          : app['appApprovalState'],
                      'platform': app['platform'],
                    }),
                    title: Text(
                      app['linkedAppInfo'] != null
                          ? app['linkedAppInfo']['displayName']
                          : app['manualAppInfo']['displayName'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app['linkedAppInfo'] != null
                              ? app['linkedAppInfo']['appStoreId']
                              : app['appApprovalState'],
                          style: TextStyle(
                            fontSize: app['linkedAppInfo'] != null ? 14 : 12,
                            color: app['linkedAppInfo'] != null
                                ? Colors.grey
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          app['platform'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        if (storeUrl != null) {
                          Utils.launchInBrowser(context, storeUrl);
                        } else {
                          Dialogs.showErrorSnackBar(
                              context, 'App not yet published!');
                        }
                      },
                      tooltip: 'Visit Store',
                      icon: const Icon(
                        CupertinoIcons.link,
                        size: 20,
                        color: Colors.blue,
                      ),
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
