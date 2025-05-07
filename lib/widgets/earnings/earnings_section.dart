import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/earnings_util.dart';
import '../../screens/home/card_summary_screen.dart';
import '../../screens/home/section_details_screen.dart';
import '../custom_tab_indicator.dart';
import 'leading_icon.dart';
import 'trailing_widget.dart';

class EarningsSection extends StatelessWidget {
  final String section;
  final dynamic data;
  final String appId;

  const EarningsSection({
    super.key,
    required this.section,
    required this.data,
    this.appId = '',
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
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
    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section == 'APP'
                ? 'Apps'
                : section == 'AD_UNIT'
                    ? 'Ad Units'
                    : 'Countries',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            height: data.length == 0
                ? 100
                : data.length == 1
                    ? 162
                    : data.length == 2
                        ? 226
                        : 290,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
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
                  tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: tabs
                        .map(
                          (tabName) => _customColumn(
                            tabName: tabName,
                            data: data,
                            context: context,
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (data.length > 0)
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => SectionDetailsScreen(
                                  section: section,
                                  appId: appId,
                                ))),
                    child: const Text('View All'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customColumn({
    required String tabName,
    required dynamic data,
    required BuildContext context,
  }) {
    List sortedData = List.from(data);
    EarningsUtil.sortDataByTab(tabName, sortedData);
    int size = sortedData.length <= 3 ? sortedData.length : 3;
    if (sortedData.isEmpty) {
      return const Center(child: Text('No any data to show'));
    }
    return Column(
      children: [
        for (var index = 0; index < size; index++)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                if (section == 'APP') {
                  final appData =
                      sortedData[index]['row']['dimensionValues']['APP'];
                  final appName = appData['displayLabel'];
                  final appId = appData['value'];

                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => CardSummaryScreen(
                        section: section,
                        appName: appName,
                        appId: appId,
                      ),
                    ),
                  );
                }
              },
              leading: LeadingIcon(
                section: section,
                value: sortedData[index]['row']['dimensionValues'][section]
                    ['value'],
              ),
              title: Text(
                sortedData[index]['row']['dimensionValues'][section]
                    [section == 'COUNTRY' ? 'value' : 'displayLabel'],
                maxLines: 1,
              ),
              trailing: TrailingWidget(
                tabName: tabName,
                item: sortedData[index],
              ),
            ),
          ),
      ],
    );
  }
}
