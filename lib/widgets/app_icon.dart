import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../providers/apps_provider.dart';

class AppIcon extends StatelessWidget {
  final Map<String, String>? appData;

  const AppIcon({super.key, required this.appData});

  @override
  Widget build(BuildContext context) {
    final appsProvider = Provider.of<AppsProvider>(context);

    if (appData?['appId'] == null || appData?['appId'] == 'ACTION_REQUIRED') {
      return Icon(
        appData?['platform'] == 'ANDROID'
            ? Icons.android_rounded
            : Icons.apple_rounded,
        size: 39,
        color: appData?['platform'] == 'ANDROID' ? Colors.green : Colors.grey,
      );
    }

    final cachedIcon = appsProvider.getAppIcon(appData!['appId']!);
    if (cachedIcon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(cachedIcon, height: 40, width: 40),
      );
    }

    return FutureBuilder(
      future: StoreIconFetcher.fetchAppIconUrl(appData!['appId']!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Icon(
            appData?['platform'] == 'ANDROID'
                ? Icons.android_rounded
                : Icons.apple_rounded,
            size: 39,
            color:
                appData?['platform'] == 'ANDROID' ? Colors.green : Colors.grey,
          );
        } else if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appsProvider.setAppIcon(appData!['appId']!, snapshot.data!);
          });
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(snapshot.data!, height: 40, width: 40),
          );
        } else {
          return Icon(
            appData?['platform'] == 'ANDROID'
                ? Icons.android_rounded
                : Icons.apple_rounded,
            size: 39,
            color:
                appData?['platform'] == 'ANDROID' ? Colors.green : Colors.grey,
          );
        }
      },
    );
  }
}

class StoreIconFetcher {
  static Future<String?> fetchAppIconUrl(String appId) async {
    if (appId.contains("com")) {
      final url =
          Uri.parse('https://play.google.com/store/apps/details?id=$appId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final htmlContent = response.body;
        final iconRegex = RegExp(
          r'<img.*?src="(https://play-lh\.googleusercontent\.com/[^"]*)"',
          multiLine: true,
        );
        final match = iconRegex.firstMatch(htmlContent);
        if (match != null) {
          return match.group(1);
        }
      }
    } else {
      final url = Uri.parse('https://apps.apple.com/app/id$appId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final htmlContent = response.body;
        // Apple stores icons in "og:image" meta tag
        final iconRegex = RegExp(
          r'<meta property="og:image" content="([^"]+)"',
          multiLine: true,
        );
        final match = iconRegex.firstMatch(htmlContent);
        if (match != null) {
          return match.group(1); // App Store icon URL
        }
      }
    }
    return null; // Fallback if not found
  }
}
