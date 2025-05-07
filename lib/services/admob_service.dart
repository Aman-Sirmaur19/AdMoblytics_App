import 'dart:convert';
import 'package:http/http.dart' as http;

class AdMobService {
  final String accessToken;

  AdMobService(this.accessToken);

  final String baseUrl = 'https://admob.googleapis.com/v1';

  /// Fetches account details
  Future<Map<String, dynamic>> fetchAccountDetails() async {
    final url = Uri.parse('https://admob.googleapis.com/v1/accounts');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to fetch account details: ${response.statusCode}');
    }
  }

  /// Function to generate a network report
  Future<dynamic> generateNetworkReport({
    required String accessToken,
    required String accountId,
    required Map<String, dynamic> customBody,
  }) async {
    final url =
        Uri.parse('$baseUrl/accounts/$accountId/networkReport:generate');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(customBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is List) {
          return data;
        } else {
          throw Exception('Unexpected response format: $data');
        }
      } else {
        throw Exception('Failed to generate report: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error generating network report: $error');
    }
  }

  Future<Map<String, dynamic>> fetchPublishedApps({
    required String accessToken,
    required String accountId,
  }) async {
    final url = Uri.https(
      'admob.googleapis.com',
      '/v1/accounts/$accountId/apps',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch published apps: ${response.statusCode}');
    }
  }

  Map<String, dynamic> buildAdMobReportBody({
    required DateTime startDate, // Format: YYYY-MM-DD
    required DateTime endDate, // Format: YYYY-MM-DD
    List<String> dimensions = const [
      "DATE"
    ], // Time-based: "DATE", "MONTH", "WEEK"; Non-time-based: "APP", "COUNTRY", etc.
    List<String> metrics = const [
      "AD_REQUESTS",
      "CLICKS",
      "ESTIMATED_EARNINGS",
      "IMPRESSIONS",
      "IMPRESSION_CTR",
      "IMPRESSION_RPM",
      "MATCHED_REQUESTS",
      "MATCH_RATE",
      "SHOW_RATE",
    ],
    String currencyCode = "USD",
    String languageCode = "en",
    List<Map<String, String>> sortConditions = const [],
    List<Map<String, dynamic>> dimensionFilters = const [],
  }) {
    // Function to parse dates into the required format
    Map<String, int> parseDate(DateTime date) {
      return {
        "year": date.year,
        "month": date.month,
        "day": date.day,
      };
    }

    // Build the report spec
    final Map<String, dynamic> body = {
      "reportSpec": {
        "dateRange": {
          "startDate": parseDate(startDate),
          "endDate": parseDate(endDate),
        },
        "dimensions": dimensions,
        "metrics": metrics,
        "dimensionFilters": dimensionFilters,
        "localizationSettings": {
          "currencyCode": currencyCode,
          "languageCode": languageCode,
        },
      },
    };

    // Add sort conditions if specified
    if (sortConditions.isNotEmpty) {
      body["reportSpec"]["sortConditions"] = sortConditions;
    }

    return body;
  }
}
