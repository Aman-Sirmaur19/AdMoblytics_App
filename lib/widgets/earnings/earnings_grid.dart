import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class EarningsGrid extends StatefulWidget {
  final dynamic data;
  final dynamic pastData;

  const EarningsGrid({super.key, required this.data, this.pastData});

  @override
  State<EarningsGrid> createState() => _EarningsGridState();
}

class _EarningsGridState extends State<EarningsGrid> {
  bool _isPastDataEmpty = false;

  @override
  Widget build(BuildContext context) {
    _isPastDataEmpty = Utils.isDataEmpty(widget.pastData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 100,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: widget.data.isEmpty
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
                        double value = double.parse(
                                widget.data[0]['row'] != null
                                    ? widget.data[0]['row']['metricValues']
                                        ['ESTIMATED_EARNINGS']['microsValue']
                                    : '0.0') /
                            1e6;
                        double pastValue = double.parse(!_isPastDataEmpty &&
                                    widget.pastData[0]['row'] != null
                                ? widget.pastData[0]['row']['metricValues']
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
                        double value = widget.data[0]['row'] != null &&
                                widget.data[0]['row']['metricValues']
                                        ['IMPRESSION_RPM'] !=
                                    null
                            ? widget.data[0]['row']['metricValues']
                                ['IMPRESSION_RPM']['doubleValue']
                            : 0;
                        double pastValue = !_isPastDataEmpty &&
                                widget.pastData[0]['row'] != null &&
                                widget.pastData[0]['row']['metricValues']
                                        ['IMPRESSION_RPM'] !=
                                    null
                            ? widget.pastData[0]['row']['metricValues']
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
                        double value = widget.data[0]['row'] != null
                            ? double.parse(widget.data[0]['row']['metricValues']
                                ['IMPRESSIONS']['integerValue'])
                            : 0;
                        double pastValue = !_isPastDataEmpty &&
                                widget.pastData[0]['row'] != null
                            ? double.parse(widget.pastData[0]['row']
                                ['metricValues']['IMPRESSIONS']['integerValue'])
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
                        double value = widget.data[0]['row'] != null
                            ? double.parse(widget.data[0]['row']['metricValues']
                                ['AD_REQUESTS']['integerValue'])
                            : 0;
                        double pastValue = !_isPastDataEmpty &&
                                widget.pastData[0]['row'] != null
                            ? double.parse(widget.pastData[0]['row']
                                ['metricValues']['AD_REQUESTS']['integerValue'])
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
                        double value = widget.data[0]['row'] != null
                            ? double.parse(widget.data[0]['row']['metricValues']
                                ['MATCHED_REQUESTS']['integerValue'])
                            : 0;
                        double pastValue = !_isPastDataEmpty &&
                                widget.pastData[0]['row'] != null
                            ? double.parse(widget.pastData[0]['row']
                                    ['metricValues']['MATCHED_REQUESTS']
                                ['integerValue'])
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
                        double value = widget.data[0]['row'] != null &&
                                widget.data[0]['row']['metricValues']
                                        ['MATCH_RATE'] !=
                                    null
                            ? double.parse(widget.data[0]['row']['metricValues']
                                        ['MATCH_RATE']['doubleValue']
                                    .toString()) *
                                100
                            : 0;
                        double pastValue = !_isPastDataEmpty &&
                                widget.pastData[0]['row'] != null &&
                                widget.pastData[0]['row']['metricValues']
                                        ['MATCH_RATE'] !=
                                    null
                            ? double.parse(widget.pastData[0]['row']
                                        ['metricValues']['MATCH_RATE']
                                        ['doubleValue']
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
                        double value = widget.data[0]['row'] != null &&
                                widget.data[0]['row']['metricValues']
                                        ['SHOW_RATE'] !=
                                    null
                            ? double.parse(widget.data[0]['row']['metricValues']
                                        ['SHOW_RATE']['doubleValue']
                                    .toString()) *
                                100
                            : 0;
                        double pastValue = !_isPastDataEmpty &&
                                widget.pastData[0]['row'] != null &&
                                widget.pastData[0]['row']['metricValues']
                                        ['SHOW_RATE'] !=
                                    null
                            ? double.parse(widget.pastData[0]['row']
                                        ['metricValues']['SHOW_RATE']
                                        ['doubleValue']
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
                        double value = widget.data[0]['row'] != null
                            ? double.parse(widget.data[0]['row']['metricValues']
                                ['CLICKS']['integerValue'])
                            : 0;
                        double pastValue = !_isPastDataEmpty &&
                                widget.pastData[0]['row'] != null
                            ? double.parse(widget.pastData[0]['row']
                                ['metricValues']['CLICKS']['integerValue'])
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
                        double value = widget.data[0]['row'] != null &&
                                widget.data[0]['row']['metricValues']
                                        ['IMPRESSION_CTR'] !=
                                    null
                            ? double.parse(widget.data[0]['row']['metricValues']
                                    ['IMPRESSION_CTR']['doubleValue']
                                .toString())
                            : 0;
                        double pastValue = !_isPastDataEmpty &&
                                widget.pastData[0]['row'] != null &&
                                widget.pastData[0]['row']['metricValues']
                                        ['IMPRESSION_CTR'] !=
                                    null
                            ? double.parse(widget.pastData[0]['row']
                                    ['metricValues']['IMPRESSION_CTR']
                                    ['doubleValue']
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: _isPastDataEmpty ? 0 : 4),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
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
          if (_isPastDataEmpty) Spacer(),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_isPastDataEmpty) Spacer(),
          if (!_isPastDataEmpty)
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
