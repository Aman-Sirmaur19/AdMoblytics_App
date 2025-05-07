import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import '../../services/admob_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_banner_ad.dart';

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final accessToken =
        authProvider.user?.authentication.then((auth) => auth.accessToken);
    return Scaffold(
      appBar: AppBar(title: const Text('Apps')),
      bottomNavigationBar: const CustomBannerAd(),
      body: FutureBuilder(
        future: accessToken,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final token = snapshot.data as String;
            return PublishedApps(accessToken: token);
          } else {
            return const Center(child: Text('Failed to load data.'));
          }
        },
      ),
    );
  }
}

class PublishedApps extends StatefulWidget {
  final String accessToken;

  const PublishedApps({super.key, required this.accessToken});

  @override
  State<PublishedApps> createState() => _PublishedAppsState();
}

class _PublishedAppsState extends State<PublishedApps> {
  final Map<String, String> _appIcons = {};

  @override
  Widget build(BuildContext context) {
    final admobService = AdMobService(widget.accessToken);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return FutureBuilder(
      future: admobService.fetchPublishedApps(
          accessToken: widget.accessToken, accountId: authProvider.accountId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.blue));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data as Map<String, dynamic>;
          final apps = data['apps'];
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  leading: FutureBuilder(
                    future: _getAppIconUrl(apps[index]['linkedAppInfo'] != null
                        ? apps[index]['linkedAppInfo']['appStoreId']
                        : null),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                            color: Colors.blue); // Loading indicator
                      } else if (snapshot.hasData) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data as String,
                            height: 40,
                            width: 40,
                          ),
                        );
                      } else {
                        return const Icon(
                          Icons.apps,
                          size: 40,
                          color: Colors.grey,
                        );
                      }
                    },
                  ),
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
                            : 'In REVIEW',
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
        } else {
          return const Center(child: Text('Failed to apps details.'));
        }
      },
    );
  }

  Future<String?> _getAppIconUrl(String? appId) async {
    if (appId == null) return null;

    if (_appIcons.containsKey(appId)) {
      return _appIcons[appId]; // Return cached icon if available
    }

    final iconUrl = await PlayStoreIconFetcher.fetchAppIconUrl(appId);
    if (iconUrl != null) {
      setState(() {
        _appIcons[appId] = iconUrl;
      });
    }
    return iconUrl;
  }
}

class PlayStoreIconFetcher {
  /// Fetch the app metadata (including icon URL) from Play Store using the app ID
  static Future<String?> fetchAppIconUrl(String appId) async {
    final url =
        Uri.parse('https://play.google.com/store/apps/details?id=$appId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final htmlContent = response.body;
      final iconRegex = RegExp(
          r'<img.*?src="(https://play-lh.googleusercontent.com/[^"]*)"',
          multiLine: true);
      final match = iconRegex.firstMatch(htmlContent);
      if (match != null) {
        return match.group(1); // Return the first match (icon URL)
      }
    }
    return null; // Fallback if no icon is found
  }
}
