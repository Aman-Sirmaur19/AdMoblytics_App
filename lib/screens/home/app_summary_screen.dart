import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/earnings_util.dart';
import '../../utils/apps_earning_util.dart';
import '../../services/admob_service.dart';
import '../../providers/tab_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_tab_indicator.dart';
import '../../widgets/earnings/earnings_grid.dart';
import '../../widgets/earnings/earnings_section.dart';
import '../../widgets/internet_connectivity_button.dart';

class AppSummaryScreen extends StatefulWidget {
  final String section;
  final String appName;
  final String appId;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const AppSummaryScreen({
    super.key,
    required this.section,
    required this.appName,
    this.appId = '',
    this.customStartDate,
    this.customEndDate,
  });

  @override
  State<AppSummaryScreen> createState() => _AppSummaryScreenState();
}

class _AppSummaryScreenState extends State<AppSummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _future;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _customStartDate = widget.customStartDate;
    _customEndDate = widget.customEndDate;
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_handleTabChange);
    _future = _loadAllReports(context);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging ||
        _tabController.animation!.status == AnimationStatus.completed) {
      Provider.of<TabProvider>(context, listen: false)
          .updateTabIndex(_tabController.index);
      setState(() {
        _future = _loadAllReports(context);
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
      _future = _loadAllReports(context);
    });
  }

  Future<Map<String, dynamic>> _loadAllReports(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final admobService = AdMobService(authProvider.accessToken!);
    final tabIndex =
        Provider.of<TabProvider>(context, listen: false).selectedTabIndex;
    _customStartDate = tabIndex == 0
        ? _customStartDate ?? DateTime.now()
        : widget.customStartDate;
    _customEndDate =
        tabIndex == 0 ? _customEndDate ?? DateTime.now() : widget.customEndDate;
    final earningsGridRange = EarningsUtil.getDateRange(
      selectedTabIndex: tabIndex,
      customStartDate: _customStartDate,
      customEndDate: _customEndDate,
    );
    final adUnitRange = AppsEarningUtil.getDateRange(
      selectedTabIndex: tabIndex,
      dimensionName: 'AD_UNIT',
      customStartDate: _customStartDate,
      customEndDate: _customEndDate,
    );
    final countryRange = AppsEarningUtil.getDateRange(
      selectedTabIndex: tabIndex,
      dimensionName: 'COUNTRY',
      customStartDate: _customStartDate,
      customEndDate: _customEndDate,
    );

    final reports = await Future.wait([
      admobService.generateNetworkReport(
        accessToken: authProvider.accessToken!,
        accountId: authProvider.accountId!,
        customBody: admobService.buildAdMobReportBody(
          startDate: earningsGridRange['startDate'],
          endDate: earningsGridRange['endDate'],
          dimensions: earningsGridRange['dimensions'],
          dimensionFilters: [
            {
              "dimension": "APP",
              "matchesAny": {
                "values": [widget.appId]
              }
            }
          ],
        ),
      ),
      admobService.generateNetworkReport(
        accessToken: authProvider.accessToken!,
        accountId: authProvider.accountId!,
        customBody: admobService.buildAdMobReportBody(
          startDate: adUnitRange['startDate'],
          endDate: adUnitRange['endDate'],
          dimensions: adUnitRange['dimensions'],
          dimensionFilters: [
            {
              "dimension": "APP",
              "matchesAny": {
                "values": [widget.appId]
              }
            }
          ],
          sortConditions: adUnitRange['sortConditions'],
        ),
      ),
      admobService.generateNetworkReport(
        accessToken: authProvider.accessToken!,
        accountId: authProvider.accountId!,
        customBody: admobService.buildAdMobReportBody(
          startDate: countryRange['startDate'],
          endDate: countryRange['endDate'],
          dimensions: countryRange['dimensions'],
          dimensionFilters: [
            {
              "dimension": "APP",
              "matchesAny": {
                "values": [widget.appId]
              }
            }
          ],
          sortConditions: countryRange['sortConditions'],
        ),
      ),
      if (tabIndex != 8)
        admobService.generateNetworkReport(
          accessToken: authProvider.accessToken!,
          accountId: authProvider.accountId!,
          customBody: admobService.buildAdMobReportBody(
            startDate: earningsGridRange['pastStartDate'],
            endDate: earningsGridRange['pastEndDate'],
            dimensions: earningsGridRange['dimensions'],
            dimensionFilters: [
              {
                "dimension": "APP",
                "matchesAny": {
                  "values": [widget.appId]
                }
              }
            ],
          ),
        ),
      if (tabIndex != 8)
        admobService.generateNetworkReport(
          accessToken: authProvider.accessToken!,
          accountId: authProvider.accountId!,
          customBody: admobService.buildAdMobReportBody(
            startDate: adUnitRange['pastStartDate'],
            endDate: adUnitRange['pastEndDate'],
            dimensions: adUnitRange['dimensions'],
            dimensionFilters: [
              {
                "dimension": "APP",
                "matchesAny": {
                  "values": [widget.appId]
                }
              }
            ],
            sortConditions: adUnitRange['sortConditions'],
          ),
        ),
      if (tabIndex != 8)
        admobService.generateNetworkReport(
          accessToken: authProvider.accessToken!,
          accountId: authProvider.accountId!,
          customBody: admobService.buildAdMobReportBody(
            startDate: countryRange['pastStartDate'],
            endDate: countryRange['pastEndDate'],
            dimensions: countryRange['dimensions'],
            dimensionFilters: [
              {
                "dimension": "APP",
                "matchesAny": {
                  "values": [widget.appId]
                }
              }
            ],
            sortConditions: countryRange['sortConditions'],
          ),
        ),
    ]);

    return {
      'earningsGrid': List.from(reports[0]).sublist(1, reports[0].length - 1),
      'adUnit': List.from(reports[1]).sublist(1, reports[1].length - 1),
      'country': List.from(reports[2]).sublist(1, reports[2].length - 1),
      if (tabIndex != 8)
        'pastEarningsGrid':
            List.from(reports[3]).sublist(1, reports[3].length - 1),
      if (tabIndex != 8)
        'pastAdUnit': List.from(reports[4]).sublist(1, reports[4].length - 1),
      if (tabIndex != 8)
        'pastCountry': List.from(reports[5]).sublist(1, reports[5].length - 1),
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
          // _customStartDate = tabProvider.selectedTabIndex == 0 &&
          //         (widget.customStartDate == null ||
          //             widget.customEndDate == null)
          //     ? DateTime.now()
          //     : widget.customStartDate;
          // _customEndDate = tabProvider.selectedTabIndex == 0 &&
          //         (widget.customStartDate == null ||
          //             widget.customEndDate == null)
          //     ? DateTime.now()
          //     : widget.customEndDate;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
                icon: const Icon(CupertinoIcons.chevron_back),
              ),
              title: Text(widget.section == 'APP'
                  ? widget.appName
                  : widget.section == 'AD_UNIT'
                      ? 'Ad Units'
                      : 'Countries'),
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
                onTap: (index) =>
                    Provider.of<TabProvider>(context, listen: false)
                        .updateTabIndex(index),
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
                (index) => RefreshIndicator(
                  onRefresh: _refresh,
                  color: Colors.blue,
                  backgroundColor: Colors.blue.shade50,
                  child: FutureBuilder<Map<String, dynamic>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.blue));
                        } else if (snapshot.hasError) {
                          return InternetConnectivityButton(
                              onPressed: _refresh);
                        }
                        final data = snapshot.data!;
                        return ListView(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 5),
                          children: [
                            CustomDate(
                              startDate: _customStartDate,
                              endDate: _customEndDate,
                              showButton: tabProvider.selectedTabIndex == 0,
                              onDateRangeSelected: (start, end) {
                                setState(() {
                                  _customStartDate = start;
                                  _customEndDate = end;
                                  _future = _loadAllReports(context);
                                });
                              },
                            ),
                            EarningsGrid(
                              data: data['earningsGrid'],
                              pastData: data['pastEarningsGrid'],
                            ),
                            const SizedBox(height: 10),
                            EarningsSection(
                              section: 'AD_UNIT',
                              data: data['adUnit'],
                              appId: widget.appId,
                              customStartDate: _customStartDate,
                              customEndDate: _customEndDate,
                              pastData: data['pastAdUnit'],
                            ),
                            const SizedBox(height: 10),
                            EarningsSection(
                              section: 'COUNTRY',
                              data: data['country'],
                              appId: widget.appId,
                              customStartDate: _customStartDate,
                              customEndDate: _customEndDate,
                              pastData: data['pastCountry'],
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ),
          );
        }));
  }
}
