import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ad_manager.dart';
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
import 'earnings_pie_chart.dart';

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
  bool _showPieChart = false;
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
              const Spacer(),
              if (widget.data.length != 0) ...[
                if (widget.section == 'COUNTRY')
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showMapView = !_showMapView;
                      });
                    },
                    tooltip: _showMapView ? 'List view' : 'Map view',
                    icon: Icon(_showMapView
                        ? Icons.list_rounded
                        : Icons.public_rounded),
                  ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showPieChart = !_showPieChart;
                    });
                  },
                  tooltip: _showPieChart ? 'List view' : 'Pie chart',
                  icon: Icon(_showPieChart
                      ? Icons.list_rounded
                      : Icons.pie_chart_rounded),
                ),
              ],
            ],
          ),
          Container(
            height: _showPieChart || _showMapView
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
                    onPressed: () => AdManager().navigateWithAd(
                        context,
                        SectionDetailsScreen(
                          section: widget.section,
                          appId: widget.appId,
                          customStartDate: widget.customStartDate,
                          customEndDate: widget.customEndDate,
                        )),
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
    List sortedData = data is List ? List.from(data) : [];
    EarningsUtil.sortDataByTab(tabName, sortedData);
    List pastSortedData = Utils.alignPastDataToCurrent(
      currentData: sortedData,
      pastData: pastData is List ? pastData : [],
      section: widget.section,
    );
    int size = sortedData.length <= 3 ? sortedData.length : 3;
    if (sortedData.isEmpty) {
      return const Center(child: Text('No any data to show'));
    }
    return _showPieChart
        ? EarningsPieChart(
            tabName: tabName,
            currentData: sortedData,
            section: widget.section,
          )
        : _showMapView
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        horizontalTitleGap: 10,
                        tileColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onTap: () {
                          if (widget.section == 'APP') {
                            final appData = sortedData[index]['row']
                                ['dimensionValues']['APP'];
                            final appName = appData['displayLabel'];
                            final appId = appData['value'];
                            AdManager().navigateWithAd(
                                context,
                                AppSummaryScreen(
                                  section: widget.section,
                                  appName: appName,
                                  appId: appId,
                                  customStartDate: widget.customStartDate,
                                  customEndDate: widget.customEndDate,
                                ));
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
                                    Theme.of(context).colorScheme.surface,
                                radius: 22,
                                child: LeadingIcon(
                                  section: widget.section,
                                  value: sortedData[index]['row']
                                          ['dimensionValues'][
                                      widget.section == 'AD_UNIT'
                                          ? 'FORMAT'
                                          : widget.section]['value'],
                                ),
                              ),
                        title: Text(
                          widget.section == 'COUNTRY'
                              ? (Utils.countryCodeToName[sortedData[index]
                                          ['row']['dimensionValues']
                                      [widget.section]['value']] ??
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
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: TrailingWidget(
                            tabName: tabName,
                            data: sortedData[index],
                            pastData: pastSortedData[index],
                          ),
                        ),
                      ),
                    ),
                ],
              );
  }
}
