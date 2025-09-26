import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../utils/utils.dart';
import '../../providers/currency_provider.dart';
import '../custom_tab_indicator.dart';

class LineChartWidget extends StatefulWidget {
  final List<dynamic> data; // current data
  final List<dynamic> pastData; // past data

  const LineChartWidget({
    super.key,
    required this.data,
    required this.pastData,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: Utils.metricKeys.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            dividerColor: Colors.transparent,
            labelColor: Colors.blue,
            unselectedLabelColor:
                Theme.of(context).colorScheme.secondaryContainer,
            tabAlignment: TabAlignment.start,
            splashBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            indicator: CustomTabIndicator(),
            tabs: Utils.metricKeys.keys
                .map((tabName) => Tab(text: tabName))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: Utils.metricKeys.entries.map((entry) {
                return MetricsLineChart(
                  data: widget.data,
                  pastData: widget.pastData,
                  metricKey: entry.value,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricsLineChart extends StatelessWidget {
  final List<dynamic> data;
  final List<dynamic> pastData;
  final String metricKey;

  const MetricsLineChart({
    super.key,
    required this.data,
    required this.pastData,
    required this.metricKey,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        Provider.of<CurrencyProvider>(context, listen: false).currencySymbol;

    final currentData = List<Map<String, dynamic>>.from(data);
    final previousData = List<Map<String, dynamic>>.from(pastData);

    // Helper to parse 'YYYYMMDD' string to DateTime
    DateTime? _parseDate(String? dateStr) {
      if (dateStr == null || dateStr.length != 8) return null;
      return DateTime.tryParse(dateStr);
    }

    // --- NEW: Logic to detect Year-over-Year comparison ---
    bool isYearComparison = false;
    if (data.isNotEmpty && pastData.isNotEmpty && data.length > 31) {
      final firstCurrentDate =
          _parseDate(data.first['row']['dimensionValues']?['DATE']?['value']);
      final firstPastDate = _parseDate(
          pastData.first['row']['dimensionValues']?['DATE']?['value']);

      if (firstCurrentDate != null &&
          firstPastDate != null &&
          data.length > 31) {
        // JUST check the year difference. This is much more reliable.
        if (firstCurrentDate.year == firstPastDate.year + 1) {
          isYearComparison = true;
        }
      }
    }

    // --- MODIFIED: Prepare FlSpot lists conditionally ---
    List<FlSpot> currentSpots;
    List<FlSpot> pastSpots;

    // Helper functions for parsing and scaling
    double parseMetric(dynamic metric) {
      if (metric == null) return 0.0;
      if (metric['doubleValue'] != null) {
        return (metric['doubleValue'] as num).toDouble();
      }
      if (metric['integerValue'] != null) {
        return double.parse(metric['integerValue']);
      }
      if (metric['microsValue'] != null) {
        return double.parse(metric['microsValue']) / 1e6;
      }
      return 0.0;
    }

    final isPercentageMetric = metricKey == 'MATCH_RATE' ||
        metricKey == 'SHOW_RATE' ||
        metricKey == 'IMPRESSION_CTR';

    double scaleValue(double value) {
      return isPercentageMetric ? value * 100 : value;
    }

    if (isYearComparison) {
      // 1. Create lookup maps for BOTH current and past data ('MMDD' -> value)
      final Map<String, double> currentValuesMap = {};
      for (var item in currentData) {
        final dateStr = item['row']['dimensionValues']?['DATE']?['value'] ?? '';
        if (dateStr.length == 8) {
          final key = dateStr.substring(4, 8); // 'MMDD'
          final value = parseMetric(item['row']['metricValues']?[metricKey]);
          currentValuesMap[key] = scaleValue(value);
        }
      }

      final Map<String, double> pastValuesMap = {};
      for (var item in previousData) {
        final dateStr = item['row']['dimensionValues']?['DATE']?['value'] ?? '';
        if (dateStr.length == 8) {
          final key = dateStr.substring(4, 8); // 'MMDD'
          final value = parseMetric(item['row']['metricValues']?[metricKey]);
          pastValuesMap[key] = scaleValue(value);
        }
      }

      // 2. Determine the longer list to define the chart's timeline
      final driverList = currentData.length >= previousData.length
          ? currentData
          : previousData;

      currentSpots = [];
      pastSpots = [];

      // 3. Loop over the LONGER list to build both spot lists
      for (int i = 0; i < driverList.length; i++) {
        final item = driverList[i];
        final dateStr = item['row']['dimensionValues']?['DATE']?['value'] ?? '';

        if (dateStr.length == 8) {
          final key = dateStr.substring(4, 8); // 'MMDD' from the driver list

          // 4. Look up values from BOTH maps, using 0.0 as a fallback
          final currentValue = currentValuesMap[key] ?? 0.0;
          final pastValue = pastValuesMap[key] ?? 0.0;

          currentSpots.add(FlSpot(i.toDouble(), currentValue));
          pastSpots.add(FlSpot(i.toDouble(), pastValue));
        }
      }
    } else {
      // --- ORIGINAL: Index-based logic for all other time ranges ---
      final currentValues = currentData
          .map((item) =>
              scaleValue(parseMetric(item['row']['metricValues']?[metricKey])))
          .toList();
      final pastValues = previousData
          .map((item) =>
              scaleValue(parseMetric(item['row']['metricValues']?[metricKey])))
          .toList();

      currentSpots = List.generate(currentValues.length,
          (index) => FlSpot(index.toDouble(), currentValues[index]));
      pastSpots = List.generate(pastValues.length,
          (index) => FlSpot(index.toDouble(), pastValues[index]));
    }

    // Extract dates for tooltip
    List<String> extractDates(List<Map<String, dynamic>> input) {
      return input.map((item) {
        final dateStr = item['row']['dimensionValues']?['DATE']?['value'] ?? '';
        if (dateStr.length == 8) {
          return "${dateStr.substring(6, 8)}/${dateStr.substring(4, 6)}/${dateStr.substring(0, 4)}";
        }
        return '';
      }).toList();
    }

    final currentDates = extractDates(currentData);
    final pastDates = extractDates(previousData);

    // --- MODIFIED: Calculate maxY from the generated spots ---
    final allValues = [
      ...currentSpots.map((spot) => spot.y),
      ...pastSpots.map((spot) => spot.y)
    ];
    final maxValue =
        allValues.isNotEmpty ? allValues.reduce((a, b) => a > b ? a : b) : 0.0;

    double getRoundedMax(double value) {
      if (value <= 1) return (value / 0.1).ceilToDouble() * 0.1;
      if (value <= 10) return (value / 1).ceilToDouble() * 1;
      if (value <= 100) return (value / 10).ceilToDouble() * 10;
      if (value <= 1000) return (value / 100).ceilToDouble() * 100;
      if (value <= 10000) return (value / 1000).ceilToDouble() * 1000;
      return (value / 10000).ceilToDouble() * 10000;
    }

    final maxY = getRoundedMax(maxValue);
    final intervalY = maxY > 0 ? (maxY / 5) : 1.0;

    // Center graph dynamically for 1–2 points
    final maxLength = currentSpots.length > pastSpots.length
        ? currentSpots.length
        : pastSpots.length;
    double padding = maxLength <= 2 ? 0.5 : 0.0;
    double minX = 0 - padding;
    double maxX = (maxLength - 1).toDouble() + padding;

    return Column(
      children: [
        const SizedBox(height: 4),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: 0,
              maxY: maxY,
              gridData: const FlGridData(show: true, drawVerticalLine: true),
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: intervalY,
                    getTitlesWidget: (value, _) {
                      final formatted = isPercentageMetric
                          ? '${value.toStringAsFixed(1)}%'
                          : (metricKey == 'ESTIMATED_EARNINGS' ||
                                  metricKey == 'IMPRESSION_RPM')
                              ? value.toStringAsFixed(1)
                              : value.toInt().toString();
                      return Text(
                        isPercentageMetric
                            ? formatted
                            : (metricKey == 'ESTIMATED_EARNINGS' ||
                                    metricKey == 'IMPRESSION_RPM')
                                ? '$currencySymbol$formatted'
                                : formatted,
                        style: const TextStyle(
                            fontSize: 6, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                _buildLine(pastSpots, Colors.orange),
                _buildLine(currentSpots, Colors.blue),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) =>
                      Theme.of(context).colorScheme.secondary,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  tooltipMargin: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isCurrentLine = spot.bar.color == Colors.blue;

                      String formattedValue;
                      if (metricKey == 'ESTIMATED_EARNINGS' ||
                          metricKey == 'IMPRESSION_RPM') {
                        formattedValue =
                            '$currencySymbol${spot.y.toStringAsFixed(2)}';
                      } else if (isPercentageMetric) {
                        formattedValue = '${spot.y.toStringAsFixed(2)}%';
                      } else {
                        formattedValue = spot.y.toInt().toString();
                      }

                      // --- MODIFIED: Tooltip date lookup ---
                      // We now need to handle aligned vs. non-aligned data
                      final index = spot.x.toInt();
                      String date = '';

                      if (isCurrentLine) {
                        if (index < currentDates.length) {
                          date = currentDates[index];
                        }
                      } else {
                        // For year comparison, we must derive the past date
                        // from the current date's timeline
                        if (isYearComparison) {
                          if (index < currentDates.length) {
                            final currentDateStr = currentDates[index];
                            if (currentDateStr.length == 10) {
                              final year =
                                  int.parse(currentDateStr.substring(6, 10));
                              date =
                                  "${currentDateStr.substring(0, 6)}${year - 1}";
                            }
                          }
                        } else {
                          // Original logic for other ranges
                          if (index < pastDates.length) {
                            date = pastDates[index];
                          }
                        }
                      }

                      return LineTooltipItem(
                        '${isCurrentLine ? "Current: " : "Past: "}$formattedValue\nDate: $date',
                        TextStyle(
                          color: isCurrentLine ? Colors.blue : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendBox(Colors.blue, "Current"),
            const SizedBox(width: 16),
            _legendBox(Colors.orange, "Past"),
          ],
        ),
      ],
    );
  }

  // --- MODIFIED: _buildLine now accepts a List<FlSpot> ---
  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: data.length > 31 ? 1.5 : 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
          radius: data.length > 31 ? 1.5 : 4,
          color: p2.color!,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.0),
          ],
        ),
      ),
      isStrokeCapRound: true,
      preventCurveOverShooting: true,
    );
  }

  Widget _legendBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
