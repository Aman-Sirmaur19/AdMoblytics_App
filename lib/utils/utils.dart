import 'dart:convert';

import 'package:flutter/material.dart';

class Utils {
  static void printFullData(dynamic data) {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
    const chunkSize = 1000;
    for (var i = 0; i < prettyJson.length; i += chunkSize) {
      final chunk = prettyJson.substring(
          i,
          i + chunkSize > prettyJson.length
              ? prettyJson.length
              : i + chunkSize);
      debugPrint(chunk);
    }
  }

  static String? getAppStoreId(
      List<Map<String, dynamic>> appsList, String targetDisplayName) {
    for (final app in appsList) {
      final manualName = app['manualAppInfo']?['displayName'];
      final linkedName = app['linkedAppInfo']?['displayName'];

      if (manualName == targetDisplayName || linkedName == targetDisplayName) {
        return app['linkedAppInfo']?['appStoreId'];
      }
    }
    return null; // if no match found
  }
}
