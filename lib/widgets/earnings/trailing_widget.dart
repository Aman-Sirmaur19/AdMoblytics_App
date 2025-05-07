import 'package:flutter/material.dart';

class TrailingWidget extends StatelessWidget {
  final String tabName;
  final dynamic item;

  const TrailingWidget({super.key, required this.tabName, required this.item});

  @override
  Widget build(BuildContext context) {
    final metrics = item['row']['metricValues'];
    switch (tabName) {
      case 'Estimated Earnings':
        final micros = metrics['ESTIMATED_EARNINGS']?['microsValue'];
        return Text(
            '\$ ${micros != null ? (int.parse(micros) / 1000000).toStringAsFixed(4) : '0.0'}');

      case 'eCPM':
        final rpm = metrics['IMPRESSION_RPM']?['doubleValue'];
        return Text('\$ ${rpm != null ? rpm.toStringAsFixed(3) : '0.0'}');

      case 'Impressions':
        return Text(metrics['IMPRESSIONS']?['integerValue'] ?? '0');

      case 'Ad Requests':
        return Text(metrics['AD_REQUESTS']?['integerValue'] ?? '0');

      case 'Matched Requests':
        return Text(metrics['MATCHED_REQUESTS']?['integerValue'] ?? '0');

      case 'Match Rate':
        final matchRate = metrics['MATCH_RATE']?['doubleValue'];
        return Text(
            '${matchRate != null ? (matchRate * 100).toStringAsFixed(2) : '0'} %');

      case 'Show Rate':
        final showRate = metrics['SHOW_RATE']?['doubleValue'];
        return Text(
            '${showRate != null ? (showRate * 100).toStringAsFixed(2) : '0'} %');

      case 'Clicks':
        return Text(metrics['CLICKS']?['integerValue'] ?? '0');

      default: // 'CTR'
        final ctr = metrics['IMPRESSION_CTR']?['doubleValue'];
        return Text('${ctr != null ? ctr.toStringAsFixed(2) : '0'} %');
    }
  }
}
