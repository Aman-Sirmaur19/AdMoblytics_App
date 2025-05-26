import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/earnings_util.dart';
import '../../utils/apps_earning_util.dart';
import '../../services/admob_service.dart';
import '../../providers/tab_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_tab_indicator.dart';
import '../../widgets/earnings/earnings_grid.dart';
import '../../widgets/earnings/earnings_section.dart';
import '../../widgets/internet_connectivity_button.dart';

class CardSummaryScreen extends StatefulWidget {
  final String section;
  final String appName;
  final String appId;

  const CardSummaryScreen({
    super.key,
    required this.section,
    required this.appName,
    this.appId = '',
  });

  @override
  State<CardSummaryScreen> createState() => _CardSummaryScreenState();
}

class _CardSummaryScreenState extends State<CardSummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
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

    final earningsGridRange = EarningsUtil.getDateRange(tabIndex);
    final adUnitRange =
        AppsEarningUtil(tabIndex: tabIndex, dimensionName: 'AD_UNIT')
            .getDateRange();
    final countryRange =
        AppsEarningUtil(tabIndex: tabIndex, dimensionName: 'COUNTRY')
            .getDateRange();

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
    ]);

    return {
      'earningsGrid': List.from(reports[0]).sublist(1, reports[0].length - 1),
      'adUnit': List.from(reports[1]).sublist(1, reports[1].length - 1),
      'country': List.from(reports[2]).sublist(1, reports[2].length - 1),
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 9,
        initialIndex: 2,
        child: Consumer<TabProvider>(builder: (context, tabProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_tabController.index != tabProvider.selectedTabIndex) {
              _tabController.index = tabProvider.selectedTabIndex;
            }
          });
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
                            EarningsGrid(data: data['earningsGrid']),
                            const SizedBox(height: 10),
                            EarningsSection(
                              section: 'AD_UNIT',
                              data: data['adUnit'],
                              appId: widget.appId,
                            ),
                            const SizedBox(height: 10),
                            EarningsSection(
                              section: 'COUNTRY',
                              data: data['country'],
                              appId: widget.appId,
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
