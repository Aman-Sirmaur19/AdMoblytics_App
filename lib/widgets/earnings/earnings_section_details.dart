import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/earnings_util.dart';
import '../../screens/home/card_summary_screen.dart';
import '../custom_tab_indicator.dart';
import 'leading_icon.dart';
import 'trailing_widget.dart';

class EarningsSectionDetails extends StatelessWidget {
  final String section;
  final dynamic data;
  final String appId;

  const EarningsSectionDetails({
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
    return ListView(
      children: [
        for (var index = 0; index < sortedData.length; index++)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: () => section == 'APP'
                  ? Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => CardSummaryScreen(
                                section: section,
                                appName: sortedData[index]['row']
                                        ['dimensionValues'][section]
                                    ['displayLabel'],
                                appId: sortedData[index]['row']
                                    ['dimensionValues'][section]['value'],
                              )))
                  : null,
              leading: LeadingIcon(
                section: section,
                value: sortedData[index]['row']['dimensionValues'][section]
                    ['value'],
              ),
              title: Text(sortedData[index]['row']['dimensionValues'][section]
                  [section == 'COUNTRY' ? 'value' : 'displayLabel']),
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
