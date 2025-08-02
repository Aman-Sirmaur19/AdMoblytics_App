import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../utils/utils.dart';
import '../../utils/earnings_util.dart';

class EarningsPieChart extends StatelessWidget {
  final String tabName;
  final List currentData;
  final String section;

  const EarningsPieChart({
    super.key,
    required this.tabName,
    required this.currentData,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    double total = 0;
    final values = <double>[];
    final labels = <String>[];
    const List<Color> distinctColors = [
      Colors.red,
      Colors.amber,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.deepPurpleAccent,
      Colors.pink,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lime,
      Colors.teal,
      Colors.lightBlue,
      Colors.lightGreen,
      Color(0xFFF032E6),
      Color(0xFFFFE119),
      Color(0xFF46F0F0),
    ];

    for (var entry in currentData) {
      double value = EarningsUtil.getTrailingValue(entry, tabName);
      total += value;
      values.add(value);
      final label = section == 'COUNTRY'
          ? (Utils.countryCodeToName[entry['row']['dimensionValues'][section]
                  ['value']] ??
              entry['row']['dimensionValues'][section]['value'])
          : entry['row']['dimensionValues'][section]['displayLabel'];
      labels.add(label);
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(PieChartData(
              sectionsSpace: 0.2,
              centerSpaceRadius: 30,
              sections: List.generate(values.length, (i) {
                return PieChartSectionData(
                  color: distinctColors[i % distinctColors.length],
                  value: values[i],
                  showTitle: false,
                  radius: 40,
                );
              }),
            )),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(values.length, (i) {
                  final percent = total == 0 ? 0.0 : (values[i] / total) * 100;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 15,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: distinctColors[i % distinctColors.length],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: distinctColors[
                                              i % distinctColors.length]
                                          .withOpacity(.2)),
                                  child: Text(
                                    labels[i],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: distinctColors[
                                            i % distinctColors.length]
                                        .withOpacity(.2)),
                                child: Text(
                                  '${percent.toStringAsFixed(2)}%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getDistinctColor(int index, int total) {
    final hslColor = HSLColor.fromAHSL(1.0, (360 / total) * index, 0.9, 0.5);
    return hslColor.toColor();
  }
}
