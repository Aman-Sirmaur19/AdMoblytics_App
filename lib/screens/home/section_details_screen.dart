import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../utils/earnings_util.dart';
import '../../utils/apps_earning_util.dart';
import '../../services/admob_service.dart';
import '../../providers/tab_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/leading_icon.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_tab_indicator.dart';
import '../../widgets/earnings/trailing_widget.dart';
import '../../widgets/earnings/metric_world_map.dart';
import '../../widgets/earnings/earnings_pie_chart.dart';
import '../../widgets/internet_connectivity_button.dart';
import 'app_summary_screen.dart';

class SectionDetailsScreen extends StatefulWidget {
  final String section;
  final String appId;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const SectionDetailsScreen({
    super.key,
    required this.section,
    this.appId = '',
    this.customStartDate,
    this.customEndDate,
  });

  @override
  State<SectionDetailsScreen> createState() => _SectionDetailsScreenState();
}

class _SectionDetailsScreenState extends State<SectionDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _tabs = [
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
  late TabController _tabController;
  late Future<dynamic> _future;
  bool _showMapView = false;
  bool _showPieChart = false;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _customStartDate = widget.customStartDate;
    _customEndDate = widget.customEndDate;
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_handleTabChange);
    _future = _loadReport(context);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging ||
        _tabController.animation!.status == AnimationStatus.completed) {
      Provider.of<TabProvider>(context, listen: false)
          .updateTabIndex(_tabController.index);
      setState(() {
        _future = _loadReport(context);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadReport(context);
    });
  }

  Future<Map<String, dynamic>> _loadReport(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
    final admobService = AdMobService(authProvider.accessToken!);
    final dimensionName = widget.section == 'AD_UNIT'
        ? "AD_UNIT"
        : widget.section == 'APP'
            ? "APP"
            : "COUNTRY";
    final tabIndex =
        Provider.of<TabProvider>(context, listen: false).selectedTabIndex;
    _customStartDate = tabIndex == 0
        ? _customStartDate ?? DateTime.now()
        : widget.customStartDate;
    _customEndDate =
        tabIndex == 0 ? _customEndDate ?? DateTime.now() : widget.customEndDate;
    final dateRangeData = AppsEarningUtil.getDateRange(
      selectedTabIndex: tabIndex,
      dimensionName: dimensionName,
      customStartDate: _customStartDate,
      customEndDate: _customEndDate,
    );
    final dimensions = dateRangeData["dimensions"];
    final sortConditions = dateRangeData["sortConditions"];
    final reports = await Future.wait([
      admobService.generateNetworkReport(
        accessToken: authProvider.accessToken!,
        accountId: authProvider.accountId!,
        customBody: admobService.buildAdMobReportBody(
          startDate: dateRangeData["startDate"],
          endDate: dateRangeData["endDate"],
          dimensions: dimensions,
          currencyCode: currencyProvider.currencyCode,
          sortConditions: sortConditions,
          dimensionFilters: widget.appId != ''
              ? [
                  {
                    "dimension": "APP",
                    "matchesAny": {
                      "values": [widget.appId]
                    }
                  }
                ]
              : [],
        ),
      ),
      if (tabIndex != 8)
        admobService.generateNetworkReport(
          accessToken: authProvider.accessToken!,
          accountId: authProvider.accountId!,
          customBody: admobService.buildAdMobReportBody(
            startDate: dateRangeData["pastStartDate"],
            endDate: dateRangeData["pastEndDate"],
            dimensions: dimensions,
            currencyCode: currencyProvider.currencyCode,
            sortConditions: sortConditions,
            dimensionFilters: widget.appId != ''
                ? [
                    {
                      "dimension": "APP",
                      "matchesAny": {
                        "values": [widget.appId]
                      }
                    }
                  ]
                : [],
          ),
        ),
    ]);
    return {
      'present': List.from(reports[0]).sublist(1, reports[0].length - 1),
      if (tabIndex != 8)
        'past': List.from(reports[1]).sublist(1, reports[1].length - 1),
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> dateRange;
    return DefaultTabController(
      length: 9,
      initialIndex: 2,
      child: Consumer<TabProvider>(builder: (context, tabProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_tabController.index != tabProvider.selectedTabIndex) {
            _tabController.index = tabProvider.selectedTabIndex;
          }
          try {
            dateRange = EarningsUtil.getDateRange(
              selectedTabIndex: tabProvider.selectedTabIndex,
              customStartDate: _customStartDate,
              customEndDate: _customEndDate,
            );
          } catch (_) {
            dateRange = {
              'startDate': DateTime.now(),
              'endDate': DateTime.now(),
            };
          }
          _customStartDate = dateRange['startDate'];
          _customEndDate = dateRange['endDate'];
        });
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
              icon: const Icon(CupertinoIcons.chevron_back),
            ),
            title: Text(widget.section == 'APP'
                ? 'Apps'
                : widget.section == 'AD_UNIT'
                    ? 'Ad Units'
                    : 'Countries'),
            actions: [
              if (widget.section == 'COUNTRY')
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
            bottom: TabBar(
              isScrollable: true,
              controller: _tabController,
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
              tabs: const <Widget>[
                Tab(text: 'Custom'),
                Tab(text: 'Yesterday'),
                Tab(text: 'Today'),
                Tab(text: 'Last 7 days'),
                Tab(text: 'This month'),
                Tab(text: 'Last month'),
                Tab(text: 'This year'),
                Tab(text: 'Last year'),
                Tab(text: 'Total'),
              ],
            ),
          ),
          bottomNavigationBar: const CustomBannerAd(),
          body: TabBarView(
            controller: _tabController,
            children: List.generate(
                9,
                (index) => FutureBuilder(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.blue));
                      } else if (snapshot.hasError) {
                        return RefreshIndicator(
                          onRefresh: _refresh,
                          color: Colors.blue,
                          backgroundColor: Colors.blue.shade50,
                          child:
                              InternetConnectivityButton(onPressed: _refresh),
                        );
                      } else {
                        final data = snapshot.data;
                        return DefaultTabController(
                          length: _tabs.length,
                          initialIndex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                isScrollable: true,
                                dividerColor: Colors.transparent,
                                labelColor: Colors.blue,
                                unselectedLabelColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                tabAlignment: TabAlignment.start,
                                splashBorderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                indicator: CustomTabIndicator(),
                                tabs:
                                    _tabs.map((tab) => Tab(text: tab)).toList(),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: _tabs
                                      .map((tabName) => _customColumn(
                                            tabIndex:
                                                tabProvider.selectedTabIndex,
                                            tabName: tabName,
                                            data: data['present'],
                                            pastData: data['past'],
                                            context: context,
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    })),
          ),
        );
      }),
    );
  }

  Widget _customColumn({
    required int tabIndex,
    required String tabName,
    required dynamic data,
    required dynamic pastData,
    required BuildContext context,
  }) {
    // List sortedData = List.from(data);
    List sortedData = data is List ? List.from(data) : [];
    EarningsUtil.sortDataByTab(tabName, sortedData);
    List pastSortedData = Utils.alignPastDataToCurrent(
      currentData: sortedData,
      pastData: pastData is List ? pastData : [],
      section: widget.section,
    );
    return ListView(
      padding: EdgeInsets.symmetric(
        // horizontal: _showMapView ? 0 : 5,
        // vertical: _showMapView ? 20 : 0,
        horizontal: 5,
      ),
      children: [
        const SizedBox(height: 5),
        CustomDate(
          startDate: _customStartDate,
          endDate: _customEndDate,
          showButton: tabIndex == 0,
          onDateRangeSelected: (start, end) {
            setState(() {
              _customStartDate = start;
              _customEndDate = end;
              _future = _loadReport(context);
            });
          },
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                '${sortedData.length} ${widget.section == 'APP' ? 'Apps' : widget.section == 'AD_UNIT' ? 'Ad Units' : 'Countries'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (_showPieChart)
          SizedBox(
            height: 200,
            child: EarningsPieChart(
              tabName: tabName,
              currentData: sortedData,
              section: widget.section,
            ),
          )
        else if (_showMapView)
          MetricWorldMap(
            data: data,
            tabName: tabName,
          )
        else
          for (var index = 0; index < sortedData.length; index++)
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
                    context.read<NavigationProvider>().increment();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => AppSummaryScreen(
                          section: widget.section,
                          appName: sortedData[index]['row']['dimensionValues']
                              [widget.section]['displayLabel'],
                          appId: sortedData[index]['row']['dimensionValues']
                              [widget.section]['value'],
                          customStartDate: _customStartDate,
                          customEndDate: _customEndDate,
                        ),
                      ),
                    );
                  }
                },
                leading: widget.section == 'APP'
                    ? AppIcon(
                        appData: Utils.getAppStoreData(
                        sortedData[index]['row']['dimensionValues']
                            [widget.section]['value'],
                        context,
                      ))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LeadingIcon(
                          section: widget.section,
                          value: sortedData[index]['row']['dimensionValues'][
                              widget.section == 'AD_UNIT'
                                  ? 'FORMAT'
                                  : widget.section]['value'],
                        ),
                      ),
                title: Text(
                  widget.section == 'COUNTRY'
                      ? (Utils.countryCodeToName[sortedData[index]['row']
                              ['dimensionValues'][widget.section]['value']] ??
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
                        sortedData[index]['row']['dimensionValues']['FORMAT']
                            ['value'],
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
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
