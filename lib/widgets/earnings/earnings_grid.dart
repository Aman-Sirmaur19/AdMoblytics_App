import 'package:flutter/material.dart';

class EarningsGrid extends StatelessWidget {
  final dynamic data;

  const EarningsGrid({super.key, required this.data});

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
                        return _customCard(
                          context,
                          title: 'Estimated Earnings',
                          value: data[0]['row'] != null
                              ? '\$ ${(int.parse(data[0]['row']['metricValues']['ESTIMATED_EARNINGS']['microsValue']) / 1000000).toStringAsFixed(3)}'
                              : '\$ 0.0',
                        );
                      case 1:
                        return _customCard(
                          context,
                          title: 'eCPM',
                          value: data[0]['row'] != null &&
                                  data[0]['row']['metricValues']
                                          ['IMPRESSION_RPM'] !=
                                      null
                              ? '\$ ${data[0]['row']['metricValues']['IMPRESSION_RPM']['doubleValue'].toStringAsFixed(2)}'
                              : '\$ 0.0',
                        );
                      case 2:
                        return _customCard(
                          context,
                          title: 'Impressions',
                          value: data[0]['row'] != null
                              ? data[0]['row']['metricValues']['IMPRESSIONS']
                                  ['integerValue']
                              : '0',
                        );
                      case 3:
                        return _customCard(
                          context,
                          title: 'Ad Requests',
                          value: data[0]['row'] != null
                              ? data[0]['row']['metricValues']['AD_REQUESTS']
                                  ['integerValue']
                              : '0',
                        );
                      case 4:
                        return _customCard(
                          context,
                          title: 'Matched Requests',
                          value: data[0]['row'] != null
                              ? data[0]['row']['metricValues']
                                  ['MATCHED_REQUESTS']['integerValue']
                              : '0',
                        );
                      case 5:
                        return _customCard(
                          context,
                          title: 'Match Rate',
                          value: data[0]['row'] != null
                              ? '${(data[0]['row']['metricValues']['MATCH_RATE']['doubleValue'] * 100).toStringAsFixed(2)} %'
                              : '0 %',
                        );
                      case 6:
                        return _customCard(
                          context,
                          title: 'Show Rate',
                          value: data[0]['row'] != null
                              ? '${(data[0]['row']['metricValues']['SHOW_RATE']['doubleValue'] * 100).toStringAsFixed(2)} %'
                              : '0 %',
                        );
                      case 7:
                        return _customCard(
                          context,
                          title: 'Clicks',
                          value: data[0]['row'] != null
                              ? data[0]['row']['metricValues']['CLICKS']
                                  ['integerValue']
                              : '0',
                        );
                      case 8:
                        return _customCard(
                          context,
                          title: 'CTR',
                          value: data[0]['row'] != null &&
                                  data[0]['row']['metricValues']
                                          ['IMPRESSION_CTR'] !=
                                      null
                              ? '${data[0]['row']['metricValues']['IMPRESSION_CTR']['doubleValue'].toStringAsFixed(2)} %'
                              : '0 %',
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
        ],
      ),
    );
  }
}
