import 'package:flutter/material.dart';

class TrailingWidget extends StatelessWidget {
  final String tabName;
  final dynamic data;
  final dynamic pastData;

  const TrailingWidget({
    super.key,
    required this.tabName,
    required this.data,
    this.pastData,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = data['row']?['metricValues'] ?? {};
    final pastMetrics =
        pastData.isNotEmpty ? pastData['row']!['metricValues'] ?? {} : {};

    double currentValue = _getValue(metrics, tabName);
    double previousValue = _getValue(pastMetrics, tabName);

    String formattedCurrent = _formatValue(currentValue, tabName);
    String? change = _getChangePercentage(currentValue, previousValue);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formattedCurrent,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        if (change != null)
          Text(
            change,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: currentValue == previousValue
                  ? Theme.of(context).brightness == Brightness.light
                      ? Colors.amber.shade700
                      : Colors.amber
                  : currentValue > previousValue
                      ? Colors.green
                      : Colors.red,
            ),
          ),
      ],
    );
  }

  double _getValue(Map<dynamic, dynamic> metrics, String tab) {
    switch (tab) {
      case 'Estimated Earnings':
        final micros = metrics['ESTIMATED_EARNINGS']?['microsValue'];
        return micros != null ? int.parse(micros) / 1000000 : 0.0;
      case 'eCPM':
        return metrics['IMPRESSION_RPM']?['doubleValue'] ?? 0.0;
      case 'Impressions':
        return double.tryParse(
                metrics['IMPRESSIONS']?['integerValue'] ?? '0') ??
            0.0;
      case 'Ad Requests':
        return double.tryParse(
                metrics['AD_REQUESTS']?['integerValue'] ?? '0') ??
            0.0;
      case 'Matched Requests':
        return double.tryParse(
                metrics['MATCHED_REQUESTS']?['integerValue'] ?? '0') ??
            0.0;
      case 'Match Rate':
        return ((metrics['MATCH_RATE']?['doubleValue'] ?? 0) as num)
                .toDouble() *
            100;
      case 'Show Rate':
        return ((metrics['SHOW_RATE']?['doubleValue'] ?? 0) as num).toDouble() *
            100;
      case 'Clicks':
        return double.tryParse(metrics['CLICKS']?['integerValue'] ?? '0') ??
            0.0;
      default: // 'CTR'
        return ((metrics['IMPRESSION_CTR']?['doubleValue'] ?? 0) as num)
                .toDouble() *
            100;
    }
  }

  String _formatValue(double value, String tab) {
    switch (tab) {
      case 'Estimated Earnings':
      case 'eCPM':
        return '\$ ${value.toStringAsFixed(4)}';
      case 'Match Rate':
      case 'Show Rate':
      case 'CTR':
        return '${value.toStringAsFixed(2)} %';
      default:
        return value.toStringAsFixed(0);
    }
  }

  String? _getChangePercentage(double current, double past) {
    if (past == 0 && current == 0) return null;
    if (past == 0) return '↑ 100%';
    double change = ((current - past) / past) * 100;
    return '${change >= 0 ? '↑' : '↓'} ${change.abs().toStringAsFixed(1)}%';
  }
}
