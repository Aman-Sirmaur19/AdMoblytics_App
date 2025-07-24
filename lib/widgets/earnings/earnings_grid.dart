import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class EarningsGrid extends StatelessWidget {
  final dynamic data;
  final dynamic pastData;

  const EarningsGrid({super.key, required this.data, this.pastData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          width: double.infinity,
          height: 100,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: data.isEmpty
              ? const Text('No any data to show')
              : GridView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 5,
                    mainAxisExtent: 150,
                  ),
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        double value = double.parse(data[0]['row'] != null
                                ? data[0]['row']['metricValues']
                                    ['ESTIMATED_EARNINGS']['microsValue']
                                : '0.0') /
                            1e6;
                        double pastValue = double.parse(
                                !Utils.isDataEmpty(pastData) &&
                                        pastData[0]['row'] != null
                                    ? pastData[0]['row']['metricValues']
                                        ['ESTIMATED_EARNINGS']['microsValue']
                                    : '0.0') /
                            1e6;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'Estimated Earnings',
                          value: '\$ ${value.toStringAsFixed(3)}',
                          pastValueString:
                              '\$ ${difference > 0 ? '+${difference.toStringAsFixed(3)}' : difference.toStringAsFixed(3)} (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      case 1:
                        double value = data[0]['row'] != null &&
                                data[0]['row']['metricValues']
                                        ['IMPRESSION_RPM'] !=
                                    null
                            ? data[0]['row']['metricValues']['IMPRESSION_RPM']
                                ['doubleValue']
                            : 0;
                        double pastValue = !Utils.isDataEmpty(pastData) &&
                                pastData[0]['row'] != null &&
                                pastData[0]['row']['metricValues']
                                        ['IMPRESSION_RPM'] !=
                                    null
                            ? pastData[0]['row']['metricValues']
                                ['IMPRESSION_RPM']['doubleValue']
                            : 0;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'eCPM',
                          value: '\$ ${value.toStringAsFixed(2)}',
                          pastValueString:
                              '\$ ${difference > 0 ? '+${difference.toStringAsFixed(2)}' : difference.toStringAsFixed(2)} (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      case 2:
                        double value = data[0]['row'] != null
                            ? double.parse(data[0]['row']['metricValues']
                                ['IMPRESSIONS']['integerValue'])
                            : 0;
                        double pastValue = !Utils.isDataEmpty(pastData) &&
                                pastData[0]['row'] != null
                            ? double.parse(pastData[0]['row']['metricValues']
                                ['IMPRESSIONS']['integerValue'])
                            : 0;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'Impressions',
                          value: value.toStringAsFixed(0),
                          pastValueString:
                              '${difference > 0 ? '+${difference.toStringAsFixed(0)}' : difference.toStringAsFixed(0)} (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      case 3:
                        double value = data[0]['row'] != null
                            ? double.parse(data[0]['row']['metricValues']
                                ['AD_REQUESTS']['integerValue'])
                            : 0;
                        double pastValue = !Utils.isDataEmpty(pastData) &&
                                pastData[0]['row'] != null
                            ? double.parse(pastData[0]['row']['metricValues']
                                ['AD_REQUESTS']['integerValue'])
                            : 0;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'Ad Requests',
                          value: value.toStringAsFixed(0),
                          pastValueString:
                              '${difference > 0 ? '+${difference.toStringAsFixed(0)}' : difference.toStringAsFixed(0)} (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      case 4:
                        double value = data[0]['row'] != null
                            ? double.parse(data[0]['row']['metricValues']
                                ['MATCHED_REQUESTS']['integerValue'])
                            : 0;
                        double pastValue = !Utils.isDataEmpty(pastData) &&
                                pastData[0]['row'] != null
                            ? double.parse(pastData[0]['row']['metricValues']
                                ['MATCHED_REQUESTS']['integerValue'])
                            : 0;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'Matched Requests',
                          value: value.toStringAsFixed(0),
                          pastValueString:
                              '${difference > 0 ? '+${difference.toStringAsFixed(0)}' : difference.toStringAsFixed(0)} (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      case 5:
                        double value = data[0]['row'] != null &&
                                data[0]['row']['metricValues']['MATCH_RATE'] !=
                                    null
                            ? double.parse(data[0]['row']['metricValues']
                                        ['MATCH_RATE']['doubleValue']
                                    .toString()) *
                                100
                            : 0;
                        double pastValue = !Utils.isDataEmpty(pastData) &&
                                pastData[0]['row'] != null &&
                                pastData[0]['row']['metricValues']
                                        ['MATCH_RATE'] !=
                                    null
                            ? double.parse(pastData[0]['row']['metricValues']
                                        ['MATCH_RATE']['doubleValue']
                                    .toString()) *
                                100
                            : 0;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'Match Rate',
                          value: '${value.toStringAsFixed(2)} %',
                          pastValueString:
                              '${difference > 0 ? '+${difference.toStringAsFixed(2)}' : difference.toStringAsFixed(2)} % (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      case 6:
                        double value = data[0]['row'] != null &&
                                data[0]['row']['metricValues']['SHOW_RATE'] !=
                                    null
                            ? double.parse(data[0]['row']['metricValues']
                                        ['SHOW_RATE']['doubleValue']
                                    .toString()) *
                                100
                            : 0;
                        double pastValue = !Utils.isDataEmpty(pastData) &&
                                pastData[0]['row'] != null &&
                                pastData[0]['row']['metricValues']
                                        ['SHOW_RATE'] !=
                                    null
                            ? double.parse(pastData[0]['row']['metricValues']
                                        ['SHOW_RATE']['doubleValue']
                                    .toString()) *
                                100
                            : 0;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'Show Rate',
                          value: '${value.toStringAsFixed(2)} %',
                          pastValueString:
                              '${difference > 0 ? '+${difference.toStringAsFixed(2)}' : difference.toStringAsFixed(2)} % (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      case 7:
                        double value = data[0]['row'] != null
                            ? double.parse(data[0]['row']['metricValues']
                                ['CLICKS']['integerValue'])
                            : 0;
                        double pastValue = !Utils.isDataEmpty(pastData) &&
                                pastData[0]['row'] != null
                            ? double.parse(pastData[0]['row']['metricValues']
                                ['CLICKS']['integerValue'])
                            : 0;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'Clicks',
                          value: value.toStringAsFixed(0),
                          pastValueString:
                              '${difference > 0 ? '+${difference.toStringAsFixed(0)}' : difference.toStringAsFixed(0)} (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      case 8:
                        double value = data[0]['row'] != null &&
                                data[0]['row']['metricValues']
                                        ['IMPRESSION_CTR'] !=
                                    null
                            ? double.parse(data[0]['row']['metricValues']
                                    ['IMPRESSION_CTR']['doubleValue']
                                .toString())
                            : 0;
                        double pastValue = !Utils.isDataEmpty(pastData) &&
                                pastData[0]['row'] != null &&
                                pastData[0]['row']['metricValues']
                                        ['IMPRESSION_CTR'] !=
                                    null
                            ? double.parse(pastData[0]['row']['metricValues']
                                    ['IMPRESSION_CTR']['doubleValue']
                                .toString())
                            : 0;
                        double difference = value - pastValue;
                        String percent = pastValue == 0
                            ? '0.0'
                            : (difference * 100 / pastValue).toStringAsFixed(1);
                        return _customCard(
                          context,
                          title: 'CTR',
                          value: '${value.toStringAsFixed(2)} %',
                          pastValueString:
                              '${difference > 0 ? '+${difference.toStringAsFixed(2)}' : difference.toStringAsFixed(2)} % (${difference > 0 ? '+$percent' : percent} %)',
                          difference: difference,
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
        ),
      ],
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!Utils.isDataEmpty(pastData))
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
                pastValueString,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
