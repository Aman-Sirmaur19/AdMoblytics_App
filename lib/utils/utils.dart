import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/apps_provider.dart';

class Utils {
  static final tabs = [
    'Estimated Earnings',
    'eCPM',
    'Impressions',
    'Ad Requests',
    'Matched Requests',
    'Match Rate',
    'Show Rate',
    'Clicks',
    'CTR',
  ];

  static final metricKeys = {
    'Estimated Earnings': 'ESTIMATED_EARNINGS',
    'eCPM': 'IMPRESSION_RPM',
    'Impressions': 'IMPRESSIONS',
    'Ad Requests': 'AD_REQUESTS',
    'Matched Requests': 'MATCHED_REQUESTS',
    'Match Rate': 'MATCH_RATE',
    'Show Rate': 'SHOW_RATE',
    'Clicks': 'CLICKS',
    'CTR': 'IMPRESSION_CTR',
  };

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

  static Map<String, String>? getAppStoreData(
    String appId,
    BuildContext context,
  ) {
    final appsProvider = Provider.of<AppsProvider>(context, listen: false);
    List<Map<String, dynamic>> apps = appsProvider.apps;
    for (final app in apps) {
      if (app['appId'] == appId) {
        return {
          'appId': appId,
          'appStoreId': app['appApprovalState'] == 'APPROVED'
              ? app['linkedAppInfo']['appStoreId']
              : app['appApprovalState'],
          'platform': app['platform'],
        };
      }
    }
    return null; // if no match found
  }

  static String formatDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  }

  static const Map<String, String> countryCodeToName = {
    'AW': 'Aruba',
    'AF': 'Afghanistan',
    'AO': 'Angola',
    'AI': 'Anguilla',
    'AX': 'Åland Islands',
    'AL': 'Albania',
    'AD': 'Andorra',
    'AE': 'United Arab Emirates',
    'AR': 'Argentina',
    'AM': 'Armenia',
    'AS': 'American Samoa',
    'AQ': 'Antarctica',
    'TF': 'French Southern Territories',
    'AG': 'Antigua and Barbuda',
    'AU': 'Australia',
    'AT': 'Austria',
    'AZ': 'Azerbaijan',
    'BI': 'Burundi',
    'BE': 'Belgium',
    'BJ': 'Benin',
    'BQ': 'Bonaire, Sint Eustatius and Saba',
    'BF': 'Burkina Faso',
    'BD': 'Bangladesh',
    'BG': 'Bulgaria',
    'BH': 'Bahrain',
    'BS': 'Bahamas',
    'BA': 'Bosnia and Herzegovina',
    'BL': 'Saint Barthélemy',
    'BY': 'Belarus',
    'BZ': 'Belize',
    'BM': 'Bermuda',
    'BO': 'Bolivia, Plurinational State of',
    'BR': 'Brazil',
    'BB': 'Barbados',
    'BN': 'Brunei Darussalam',
    'BT': 'Bhutan',
    'BV': 'Bouvet Island',
    'BW': 'Botswana',
    'CF': 'Central African Republic',
    'CA': 'Canada',
    'CC': 'Cocos (Keeling) Islands',
    'CH': 'Switzerland',
    'CL': 'Chile',
    'CN': 'China',
    'CI': "Côte d'Ivoire",
    'CM': 'Cameroon',
    'CD': 'Congo, The Democratic Republic of the',
    'CG': 'Congo',
    'CK': 'Cook Islands',
    'CO': 'Colombia',
    'KM': 'Comoros',
    'CV': 'Cabo Verde',
    'CR': 'Costa Rica',
    'CU': 'Cuba',
    'CW': 'Curaçao',
    'CX': 'Christmas Island',
    'KY': 'Cayman Islands',
    'CY': 'Cyprus',
    'CZ': 'Czechia',
    'DE': 'Germany',
    'DJ': 'Djibouti',
    'DM': 'Dominica',
    'DK': 'Denmark',
    'DO': 'Dominican Republic',
    'DZ': 'Algeria',
    'EC': 'Ecuador',
    'EG': 'Egypt',
    'ER': 'Eritrea',
    'EH': 'Western Sahara',
    'ES': 'Spain',
    'EE': 'Estonia',
    'ET': 'Ethiopia',
    'FI': 'Finland',
    'FJ': 'Fiji',
    'FK': 'Falkland Islands (Malvinas)',
    'FR': 'France',
    'FO': 'Faroe Islands',
    'FM': 'Micronesia, Federated States of',
    'GA': 'Gabon',
    'GB': 'United Kingdom',
    'GE': 'Georgia',
    'GG': 'Guernsey',
    'GH': 'Ghana',
    'GI': 'Gibraltar',
    'GN': 'Guinea',
    'GP': 'Guadeloupe',
    'GM': 'Gambia',
    'GW': 'Guinea-Bissau',
    'GQ': 'Equatorial Guinea',
    'GR': 'Greece',
    'GD': 'Grenada',
    'GL': 'Greenland',
    'GT': 'Guatemala',
    'GF': 'French Guiana',
    'GU': 'Guam',
    'GY': 'Guyana',
    'HK': 'Hong Kong',
    'HM': 'Heard Island and McDonald Islands',
    'HN': 'Honduras',
    'HR': 'Croatia',
    'HT': 'Haiti',
    'HU': 'Hungary',
    'ID': 'Indonesia',
    'IM': 'Isle of Man',
    'IN': 'India',
    'IO': 'British Indian Ocean Territory',
    'IE': 'Ireland',
    'IR': 'Iran, Islamic Republic of',
    'IQ': 'Iraq',
    'IS': 'Iceland',
    'IL': 'Israel',
    'IT': 'Italy',
    'JM': 'Jamaica',
    'JE': 'Jersey',
    'JO': 'Jordan',
    'JP': 'Japan',
    'KZ': 'Kazakhstan',
    'KE': 'Kenya',
    'KG': 'Kyrgyzstan',
    'KH': 'Cambodia',
    'KI': 'Kiribati',
    'KN': 'Saint Kitts and Nevis',
    'KR': 'Korea, Republic of',
    'KW': 'Kuwait',
    'LA': "Lao People's Democratic Republic",
    'LB': 'Lebanon',
    'LR': 'Liberia',
    'LY': 'Libya',
    'LC': 'Saint Lucia',
    'LI': 'Liechtenstein',
    'LK': 'Sri Lanka',
    'LS': 'Lesotho',
    'LT': 'Lithuania',
    'LU': 'Luxembourg',
    'LV': 'Latvia',
    'MO': 'Macao',
    'MF': 'Saint Martin (French part)',
    'MA': 'Morocco',
    'MC': 'Monaco',
    'MD': 'Moldova, Republic of',
    'MG': 'Madagascar',
    'MV': 'Maldives',
    'MX': 'Mexico',
    'MH': 'Marshall Islands',
    'MK': 'North Macedonia',
    'ML': 'Mali',
    'MT': 'Malta',
    'MM': 'Myanmar',
    'ME': 'Montenegro',
    'MN': 'Mongolia',
    'MP': 'Northern Mariana Islands',
    'MZ': 'Mozambique',
    'MR': 'Mauritania',
    'MS': 'Montserrat',
    'MQ': 'Martinique',
    'MU': 'Mauritius',
    'MW': 'Malawi',
    'MY': 'Malaysia',
    'YT': 'Mayotte',
    'NA': 'Namibia',
    'NC': 'New Caledonia',
    'NE': 'Niger',
    'NF': 'Norfolk Island',
    'NG': 'Nigeria',
    'NI': 'Nicaragua',
    'NU': 'Niue',
    'NL': 'Netherlands',
    'NO': 'Norway',
    'NP': 'Nepal',
    'NR': 'Nauru',
    'NZ': 'New Zealand',
    'OM': 'Oman',
    'PK': 'Pakistan',
    'PA': 'Panama',
    'PN': 'Pitcairn',
    'PE': 'Peru',
    'PH': 'Philippines',
    'PW': 'Palau',
    'PG': 'Papua New Guinea',
    'PL': 'Poland',
    'PR': 'Puerto Rico',
    'KP': "Korea, Democratic People's Republic of",
    'PT': 'Portugal',
    'PY': 'Paraguay',
    'PS': 'Palestine, State of',
    'PF': 'French Polynesia',
    'QA': 'Qatar',
    'RE': 'Réunion',
    'RO': 'Romania',
    'RU': 'Russian Federation',
    'RW': 'Rwanda',
    'SA': 'Saudi Arabia',
    'SD': 'Sudan',
    'SN': 'Senegal',
    'SG': 'Singapore',
    'GS': 'South Georgia and the South Sandwich Islands',
    'SH': 'Saint Helena, Ascension and Tristan da Cunha',
    'SJ': 'Svalbard and Jan Mayen',
    'SB': 'Solomon Islands',
    'SL': 'Sierra Leone',
    'SV': 'El Salvador',
    'SM': 'San Marino',
    'SO': 'Somalia',
    'PM': 'Saint Pierre and Miquelon',
    'RS': 'Serbia',
    'SS': 'South Sudan',
    'ST': 'Sao Tome and Principe',
    'SR': 'Suriname',
    'SK': 'Slovakia',
    'SI': 'Slovenia',
    'SE': 'Sweden',
    'SZ': 'Eswatini',
    'SX': 'Sint Maarten (Dutch part)',
    'SC': 'Seychelles',
    'SY': 'Syrian Arab Republic',
    'TC': 'Turks and Caicos Islands',
    'TD': 'Chad',
    'TG': 'Togo',
    'TH': 'Thailand',
    'TJ': 'Tajikistan',
    'TK': 'Tokelau',
    'TM': 'Turkmenistan',
    'TL': 'Timor-Leste',
    'TO': 'Tonga',
    'TT': 'Trinidad and Tobago',
    'TN': 'Tunisia',
    'TR': 'Turkey',
    'TV': 'Tuvalu',
    'TW': 'Taiwan, Province of China',
    'TZ': 'Tanzania, United Republic of',
    'UG': 'Uganda',
    'UA': 'Ukraine',
    'UM': 'United States Minor Outlying Islands',
    'UY': 'Uruguay',
    'US': 'United States',
    'UZ': 'Uzbekistan',
    'VA': 'Holy See (Vatican City State)',
    'VC': 'Saint Vincent and the Grenadines',
    'VE': 'Venezuela, Bolivarian Republic of',
    'VG': 'Virgin Islands, British',
    'VI': 'Virgin Islands, U.S.',
    'VN': 'Viet Nam',
    'VU': 'Vanuatu',
    'WF': 'Wallis and Futuna',
    'WS': 'Samoa',
    'YE': 'Yemen',
    'ZA': 'South Africa',
    'ZM': 'Zambia',
    'ZW': 'Zimbabwe',
  };

  static bool isDataEmpty(dynamic data) {
    if (data == null) return true;
    if (data is List) {
      if (data.isEmpty) return true;
      return data.every((element) {
        if (element == null) return true;
        if (element is Map && element.isEmpty) return true;
        return false;
      });
    }
    if (data is Map && data.isEmpty) return true;
    if (data is String && data.trim().isEmpty) return true;
    return false;
  }

  static List<Map<String, dynamic>> alignPastDataToCurrent({
    required List currentData,
    required List pastData,
    required String section,
  }) {
    Map<String, Map<String, dynamic>> pastDataMap = {};

    for (var item in pastData) {
      final id = item['row']?['dimensionValues']?[section]?['value'];
      if (id != null) {
        pastDataMap[id] = item;
      }
    }

    return currentData.map<Map<String, dynamic>>((item) {
      final id = item['row']?['dimensionValues']?[section]?['value'];
      return pastDataMap[id] ?? {};
    }).toList();
  }

  static Future<void> launchInBrowser(BuildContext context, Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Dialogs.showErrorSnackBar(context, 'Could not launch $url');
    }
  }

  static Uri? getStoreUrl(String appStoreId) {
    if (appStoreId != 'ACTION_REQUIRED') {
      if (appStoreId.contains('com')) {
        return Uri.parse(
            "https://play.google.com/store/apps/details?id=$appStoreId");
      } else {
        return Uri.parse("https://apps.apple.com/app/id$appStoreId");
      }
    }
    return null;
  }

  /// A custom function to format a number into a compact representation (e.g., 1.2k, 5M).
  static String formatCompactCustom(num number) {
    // First, handle numbers that don't need a suffix (e.g., 123 or 123.45)
    if (number.abs() < 1000) {
      // Check if the number is whole
      if (number % 1 == 0) {
        return number.toStringAsFixed(0); // No decimals for whole numbers
      } else {
        return number.toStringAsFixed(1); // Two decimals for fractional numbers
      }
    }

    // Define the suffixes for large numbers
    final Map<double, String> suffixes = {
      1e12: 'T', // Trillion
      1e9: 'B', // Billion
      1e6: 'M', // Million
      1e3: 'k', // Thousand
    };

    // Find the correct suffix and divisor
    for (final threshold in suffixes.keys) {
      if (number.abs() >= threshold) {
        // Calculate the new value (e.g., 2500 becomes 2.5)
        final double value = number / threshold;
        String formattedValue;

        // Check if the NEW value is a whole number (e.g., 2.0)
        // A small tolerance (epsilon) is used for robust floating-point comparison
        if ((value - value.truncate()).abs() < 1e-9) {
          formattedValue = value.toStringAsFixed(0); // e.g., "2"
        } else {
          formattedValue = value.toStringAsFixed(2); // e.g., "2.50"
        }

        // Append the correct suffix and return
        return '$formattedValue${suffixes[threshold]}';
      }
    }

    // Fallback for any unexpected cases
    return number.toStringAsFixed(0);
  }
}
