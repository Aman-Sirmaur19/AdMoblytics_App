import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';

import '../../utils/utils.dart';
import '../../utils/dialogs.dart';
import '../../providers/currency_provider.dart';

class MetricWorldMap extends StatelessWidget {
  final List<dynamic> data;
  final String tabName;

  const MetricWorldMap({super.key, required this.data, required this.tabName});

  // Step 1: Convert data to country -> value map based on selected metric
  Map<String, double> getCountryMetricMap(List<dynamic> data, String tabName) {
    final Map<String, double> map = {};

    for (var entry in data) {
      final row = entry['row'];
      final country = row['dimensionValues']['COUNTRY']['value'].toLowerCase();
      final metrics = row['metricValues'];

      double value = 0.0;

      switch (tabName) {
        case 'Estimated Earnings':
          final micros = metrics['ESTIMATED_EARNINGS']?['microsValue'];
          value = micros != null ? (int.tryParse(micros) ?? 0) / 1e6 : 0.0;
          break;

        case 'eCPM':
          final rpm = metrics['IMPRESSION_RPM']?['doubleValue'];
          value = rpm ?? 0.0;
          break;

        case 'Impressions':
          final impressions = metrics['IMPRESSIONS']?['integerValue'];
          value =
              impressions != null ? double.tryParse(impressions) ?? 0.0 : 0.0;
          break;

        case 'Ad Requests':
          final adReq = metrics['AD_REQUESTS']?['integerValue'];
          value = adReq != null ? double.tryParse(adReq) ?? 0.0 : 0.0;
          break;

        case 'Matched Requests':
          final matchReq = metrics['MATCHED_REQUESTS']?['integerValue'];
          value = matchReq != null ? double.tryParse(matchReq) ?? 0.0 : 0.0;
          break;

        case 'Match Rate':
          final matchRateRaw = metrics['MATCH_RATE']?['doubleValue'];
          final matchRate =
              matchRateRaw is int ? matchRateRaw.toDouble() : matchRateRaw;
          value = (matchRate ?? 0.0) * 100;
          break;

        case 'Show Rate':
          final showRateRaw = metrics['SHOW_RATE']?['doubleValue'];
          final showRate =
              showRateRaw is int ? showRateRaw.toDouble() : showRateRaw;
          value = (showRate ?? 0.0) * 100;
          break;

        case 'Clicks':
          final clicks = metrics['CLICKS']?['integerValue'];
          value = clicks != null ? double.tryParse(clicks) ?? 0.0 : 0.0;
          break;

        default: // CTR
          final ctrRaw = metrics['IMPRESSION_CTR']?['doubleValue'];
          final ctr = ctrRaw is int ? ctrRaw.toDouble() : ctrRaw;
          value = (ctr ?? 0.0) * 100;
          break;
      }

      map[country] = value;
    }

    return map;
  }

  // Step 2: Map value to color
  Map<String, Color> getCountryColors(Map<String, double> valueMap) {
    final double max = valueMap.values.fold(0.0, (a, b) => a > b ? a : b);
    final shades = [100, 200, 300, 400, 500, 600, 700, 800, 900];

    return valueMap.map((country, value) {
      final normalized = value / (max == 0 ? 1 : max);
      final index = (normalized * (shades.length - 1)).round();
      return MapEntry(country, Colors.blue[shades[index]]!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
    final metricMap = getCountryMetricMap(data, tabName);
    final colorMap = getCountryColors(metricMap);

    return SimpleMap(
      colors: colorMap,
      fit: BoxFit.fitWidth,
      defaultColor: Colors.grey,
      instructions: SMapWorld.instructionsMercator,
      countryBorder:
          CountryBorder(color: Theme.of(context).colorScheme.surface),
      callback: (id, name, tapDetails) {
        final country = Utils.countryCodeToName[id.toUpperCase()];
        final value = metricMap[id] ?? 0.0;
        final label = tabName.contains('Rate') || tabName == 'CTR'
            ? '${value.toStringAsFixed(2)} %'
            : tabName.contains('Earnings') || tabName == 'eCPM'
                ? '${currencyProvider.currencySymbol}${value.toStringAsFixed(4)}'
                : value.toInt();
        Dialogs.showSnackBar(
            context,
            country == null
                ? "Oops! It's Ocean﹏𓊝﹏𓂁﹏"
                : "Country: $country\n$tabName: $label");
      },
    );
  }
}
