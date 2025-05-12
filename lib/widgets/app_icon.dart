import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../providers/apps_provider.dart';

class AppIcon extends StatelessWidget {
  final String? appId;

  const AppIcon({super.key, required this.appId});

  @override
  Widget build(BuildContext context) {
    final appsProvider = Provider.of<AppsProvider>(context);

    if (appId == null) {
      return const Icon(Icons.apps_outage_rounded,
          size: 40, color: Colors.grey);
    }

    final cachedIcon = appsProvider.getAppIcon(appId!);
    if (cachedIcon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(cachedIcon, height: 40, width: 40),
      );
    }

    return FutureBuilder(
      future: PlayStoreIconFetcher.fetchAppIconUrl(appId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Icon(Icons.apps_outage_rounded,
              size: 40, color: Colors.grey);
        } else if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appsProvider.setAppIcon(appId!, snapshot.data!);
          });
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(snapshot.data!, height: 40, width: 40),
          );
        } else {
          return const Icon(Icons.apps_outage_rounded,
              size: 40, color: Colors.grey);
        }
      },
    );
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
