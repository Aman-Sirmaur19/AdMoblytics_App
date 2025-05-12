import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../utils/earnings_util.dart';
import '../../providers/apps_provider.dart';
import '../../screens/home/card_summary_screen.dart';
import '../app_icon.dart';
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
    final appsProvider = Provider.of<AppsProvider>(context, listen: false);
    final apps = appsProvider.apps;
    List sortedData = List.from(data);
    EarningsUtil.sortDataByTab(tabName, sortedData);
    return ListView(
      children: [
        for (var index = 0; index < sortedData.length; index++)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              horizontalTitleGap: 10,
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
              leading: section == 'APP'
                  ? AppIcon(
                      appId: Utils.getAppStoreId(
                          apps,
                          sortedData[index]['row']['dimensionValues'][section]
                              ['displayLabel']))
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      radius: 22,
                      child: LeadingIcon(
                        section: section,
                        value: sortedData[index]['row']['dimensionValues']
                                [section == 'AD_UNIT' ? 'FORMAT' : section]
                            ['value'],
                      ),
                    ),
              title: Text(
                sortedData[index]['row']['dimensionValues'][section]
                    [section == 'COUNTRY' ? 'value' : 'displayLabel'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
              subtitle: section == 'AD_UNIT'
                  ? Text(
                      sortedData[index]['row']['dimensionValues']['FORMAT']
                          ['value'],
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    )
                  : null,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.background,
                ),
                child: TrailingWidget(
                  tabName: tabName,
                  item: sortedData[index],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
