import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../providers/currency_provider.dart';
import 'line_chart_widget.dart';

class EarningsGrid extends StatefulWidget {
  final dynamic data;
  final dynamic pastData;

  const EarningsGrid({super.key, required this.data, this.pastData});

  @override
  State<EarningsGrid> createState() => _EarningsGridState();
}

class _EarningsGridState extends State<EarningsGrid> {
  bool _isPastDataEmpty = false;
  bool _showLineChart = false;

  @override
  Widget build(BuildContext context) {
    _isPastDataEmpty = Utils.isDataEmpty(widget.pastData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_isPastDataEmpty)
              IconButton(
                onPressed: () {
                  setState(() {
                    _showLineChart = !_showLineChart;
                  });
                },
                tooltip: _showLineChart ? 'Grid view' : 'Line chart',
                icon: Icon(_showLineChart
                    ? Icons.more_horiz_rounded
                    : Icons.stacked_line_chart_rounded),
              ),
          ],
        ),
        Container(
          width: double.infinity,
          height: _showLineChart ? 300 : 100,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: widget.data.isEmpty
              ? const Text('No any data to show')
              : _showLineChart
                  ? LineChartWidget(
                      data: widget.data,
                      pastData: widget.pastData,
                    )
                  : MetricsGrid(
                      data: widget.data,
                      pastData: widget.pastData ?? [],
                      isPastDataEmpty: _isPastDataEmpty,
                    ),
        ),
      ],
    );
  }
}

class MetricsGrid extends StatelessWidget {
  final List<dynamic> data; // Current daily data
  final List<dynamic> pastData; // Past daily data
  final bool isPastDataEmpty;

  const MetricsGrid({
    super.key,
    required this.data,
    required this.pastData,
    required this.isPastDataEmpty,
  });

  // Metric configuration: title, key, type (sum or average)
  static final List<Map<String, dynamic>> metrics = [
    {
      'title': 'Estimated Earnings',
      'key': 'ESTIMATED_EARNINGS',
      'type': 'sum',
      'isMicros': true,
      'isCurrency': true
    },
    {
      'title': 'eCPM',
      'key': 'IMPRESSION_RPM',
      'type': 'average',
      'isCurrency': true
    },
    {'title': 'Impressions', 'key': 'IMPRESSIONS', 'type': 'sum'},
    {'title': 'Ad Requests', 'key': 'AD_REQUESTS', 'type': 'sum'},
    {'title': 'Matched Requests', 'key': 'MATCHED_REQUESTS', 'type': 'sum'},
    {
      'title': 'Match Rate',
      'key': 'MATCH_RATE',
      'type': 'average',
      'isPercentage': true
    },
    {
      'title': 'Show Rate',
      'key': 'SHOW_RATE',
      'type': 'average',
      'isPercentage': true
    },
    {'title': 'Clicks', 'key': 'CLICKS', 'type': 'sum'},
    {
      'title': 'CTR',
      'key': 'IMPRESSION_CTR',
      'type': 'average',
      'isPercentage': true
    },
  ];

  double _extractValue(Map<String, dynamic> row, String key,
      {bool isMicros = false}) {
    if (row['metricValues']?[key] == null) return 0.0;
    final metric = row['metricValues'][key];
    double value = 0.0;

    if (metric['doubleValue'] != null) {
      value = (metric['doubleValue'] as num).toDouble();
    } else if (metric['integerValue'] != null) {
      value = double.parse(metric['integerValue']);
    } else if (isMicros && metric['microsValue'] != null) {
      value = double.parse(metric['microsValue']) / 1e6;
    }

    return value;
  }

  double _aggregate(List<dynamic> rows, Map<String, dynamic> metric) {
    final key = metric['key'];
    final type = metric['type'];
    final isMicros = metric['isMicros'] ?? false;
    final isPercentage = metric['isPercentage'] ?? false; // add this

    List<double> values = rows
        .map((row) => _extractValue(row['row'] ?? {}, key, isMicros: isMicros))
        .toList();

    if (values.isEmpty) return 0.0;

    double result = 0.0;
    if (type == 'sum') {
      result = values.reduce((a, b) => a + b);
    } else if (type == 'average') {
      result = values.reduce((a, b) => a + b) / values.length;
    }

    if (isPercentage) result *= 100; // convert to percentage scale
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);

    return GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 5,
        mainAxisExtent: 150,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];

        double value = _aggregate(data, metric);
        double pastValue =
            !isPastDataEmpty ? _aggregate(pastData, metric) : 0.0;
        double difference = value - pastValue;

// MODIFIED: Calculate the percentage as a 'double', not a 'String'.
// Renamed to 'percentValue' for clarity.
        double percentValue =
            pastValue == 0 ? 0.0 : (difference * 100 / pastValue);

// This part is correct and unchanged
        String displayValue = metric['isPercentage'] == true
            ? '${value.toStringAsFixed(2)} %'
            : metric['isCurrency'] == true
                ? '${currencyProvider.currencySymbol} ${value.toStringAsFixed(3)}'
                : value.toStringAsFixed(0);

// MODIFIED: Use the 'percentValue' double and format it directly inside the string.
// This fixes the error. I also simplified the logic for adding the '+' sign.
        String pastValueString = !isPastDataEmpty
            ? metric['isPercentage'] == true
                ? '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(2)} % (${percentValue > 0 ? '+' : ''}${Utils.formatCompactCustom(percentValue)} %)'
                : metric['isCurrency'] == true
                    ? '${currencyProvider.currencySymbol} ${difference > 0 ? '+' : ''}${Utils.formatCompactCustom(difference)} (${percentValue > 0 ? '+' : ''}${Utils.formatCompactCustom(percentValue)} %)'
                    : '${difference > 0 ? '+' : ''}${Utils.formatCompactCustom(difference)} (${percentValue > 0 ? '+' : ''}${Utils.formatCompactCustom(percentValue)} %)'
            : '';

        return _customCard(
          context,
          title: metric['title'],
          value: displayValue,
          pastValueString: pastValueString,
          difference: difference,
        );
      },
    );
  }

  Widget _customCard(
    BuildContext context, {
    required String title,
    required String value,
    String pastValueString = '',
    double difference = 0.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: pastValueString.isEmpty ? 0 : 4),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          if (pastValueString.isEmpty) const Spacer(),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (pastValueString.isEmpty) const Spacer(),
          if (pastValueString.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: difference < 0
                    ? Colors.red.withOpacity(.2)
                    : difference == 0
                        ? Colors.amber.withOpacity(.2)
                        : Colors.green.withOpacity(.2),
              ),
              child: Text(
                '$pastValueString ${difference >= 0 ? '↑' : '↓'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: difference < 0
                      ? Colors.red
                      : difference == 0
                          ? Theme.of(context).brightness == Brightness.light
                              ? Colors.amber.shade700
                              : Colors.amber
                          : Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
