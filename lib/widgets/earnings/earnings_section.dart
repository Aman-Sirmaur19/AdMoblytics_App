import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../utils/earnings_util.dart';
import '../../providers/apps_provider.dart';
import '../../screens/home/app_summary_screen.dart';
import '../../screens/home/section_details_screen.dart';
import '../app_icon.dart';
import '../custom_tab_indicator.dart';
import 'leading_icon.dart';
import 'trailing_widget.dart';
import 'metric_world_map.dart';

class EarningsSection extends StatefulWidget {
  final String section;
  final dynamic data;
  final dynamic pastData;
  final String appId;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const EarningsSection({
    super.key,
    required this.section,
    required this.data,
    this.pastData,
    this.appId = '',
    this.customStartDate,
    this.customEndDate,
  });

  @override
  State<EarningsSection> createState() => _EarningsSectionState();
}

class _EarningsSectionState extends State<EarningsSection> {
  bool _showMapView = false;

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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final totalSize = List.from(widget.data).length;
    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.section == 'APP'
                    ? totalSize < 2
                        ? '$totalSize App'
                        : '$totalSize Apps'
                    : widget.section == 'AD_UNIT'
                        ? totalSize < 2
                            ? '$totalSize Ad Unit'
                            : '$totalSize Ad Units'
                        : totalSize < 2
                            ? '$totalSize Country'
                            : '$totalSize Countries',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.section == 'COUNTRY' && widget.data.length != 0)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showMapView = !_showMapView;
                    });
                  },
                  tooltip: _showMapView ? 'List view' : 'Map view',
                  icon: Icon(
                      _showMapView ? Icons.list_rounded : Icons.public_rounded),
                ),
            ],
          ),
          Container(
            height: _showMapView
                ? isLandscape
                    ? 550
                    : 290
                : widget.data.length == 0
                    ? 100
                    : widget.data.length == 1 && widget.section != 'AD_UNIT'
                        ? 162
                        : widget.data.length == 1 && widget.section == 'AD_UNIT'
                            ? 178
                            : widget.data.length == 2 &&
                                    widget.section != 'AD_UNIT'
                                ? 226
                                : widget.data.length == 2 &&
                                        widget.section == 'AD_UNIT'
                                    ? 258
                                    : widget.section != 'AD_UNIT'
                                        ? 290
                                        : 338,
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
                        .map((tabName) => _customColumn(
                              tabName: tabName,
                              data: widget.data,
                              pastData: widget.pastData,
                              context: context,
                            ))
                        .toList(),
                  ),
                ),
                if (widget.data.length > 0 && !_showMapView)
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => SectionDetailsScreen(
                                  section: widget.section,
                                  appId: widget.appId,
                                  customStartDate: widget.customStartDate,
                                  customEndDate: widget.customEndDate,
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
    required dynamic pastData,
    required BuildContext context,
  }) {
    final appsProvider = Provider.of<AppsProvider>(context, listen: false);
    final apps = appsProvider.apps;
    List sortedData = List.from(data);
    List pastSortedData = List.from(pastData);
    EarningsUtil.sortDataByTab(tabName, sortedData);
    int size = sortedData.length <= 3 ? sortedData.length : 3;
    if (sortedData.isEmpty) {
      return const Center(child: Text('No any data to show'));
    }
    return _showMapView
        ? MetricWorldMap(
            data: widget.data,
            tabName: tabName,
          )
        : Column(
            children: [
              for (var index = 0; index < size; index++)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    horizontalTitleGap: 10,
                    tileColor: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      if (widget.section == 'APP') {
                        final appData =
                            sortedData[index]['row']['dimensionValues']['APP'];
                        final appName = appData['displayLabel'];
                        final appId = appData['value'];
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => AppSummaryScreen(
                              section: widget.section,
                              appName: appName,
                              appId: appId,
                              customStartDate: widget.customStartDate,
                              customEndDate: widget.customEndDate,
                            ),
                          ),
                        );
                      }
                    },
                    leading: widget.section == 'APP'
                        ? AppIcon(
                            appData: Utils.getAppStoreData(
                                apps,
                                sortedData[index]['row']['dimensionValues']
                                    [widget.section]['displayLabel']))
                        : CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            radius: 22,
                            child: LeadingIcon(
                              section: widget.section,
                              value: sortedData[index]['row']['dimensionValues']
                                  [widget.section == 'AD_UNIT'
                                      ? 'FORMAT'
                                      : widget.section]['value'],
                            ),
                          ),
                    title: Text(
                      widget.section == 'COUNTRY'
                          ? (Utils.countryCodeToName[sortedData[index]['row']
                                      ['dimensionValues'][widget.section]
                                  ['value']] ??
                              sortedData[index]['row']['dimensionValues']
                                  [widget.section]['value'])
                          : sortedData[index]['row']['dimensionValues']
                              [widget.section]['displayLabel'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: widget.section == 'AD_UNIT'
                        ? Text(
                            sortedData[index]['row']['dimensionValues']
                                ['FORMAT']['value'],
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: TrailingWidget(
                        tabName: tabName,
                        data: sortedData[index],
                        // pastData: pastSortedData[index],
                      ),
                    ),
                  ),
                ),
            ],
          );
  }
}
