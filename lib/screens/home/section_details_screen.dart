import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admob_service.dart';
import '../../utils/apps_earning_util.dart';
import '../../providers/tab_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_tab_indicator.dart';
import '../../widgets/internet_connectivity_button.dart';
import '../../widgets/earnings/earnings_section_details.dart';

class SectionDetailsScreen extends StatefulWidget {
  final String section;
  final String appId;

  const SectionDetailsScreen({
    super.key,
    required this.section,
    this.appId = '',
  });

  @override
  State<SectionDetailsScreen> createState() => _SectionDetailsScreenState();
}

class _SectionDetailsScreenState extends State<SectionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
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

  Future<dynamic> _loadReport(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final admobService = AdMobService(authProvider.accessToken!);
    final dimensionName = widget.section == 'AD_UNIT'
        ? "AD_UNIT"
        : widget.section == 'APP'
            ? "APP"
            : "COUNTRY";
    final selectedTabIndex =
        Provider.of<TabProvider>(context, listen: false).selectedTabIndex;
    final dateRangeData = AppsEarningUtil(
      tabIndex: selectedTabIndex,
      dimensionName: dimensionName,
    ).getDateRange();
    final startDate = dateRangeData["startDate"];
    final endDate = dateRangeData["endDate"];
    final dimensions = dateRangeData["dimensions"];
    final sortConditions = dateRangeData["sortConditions"];
    final report = await admobService.generateNetworkReport(
      accessToken: authProvider.accessToken!,
      accountId: authProvider.accountId!,
      customBody: admobService.buildAdMobReportBody(
        startDate: startDate,
        endDate: endDate,
        dimensions: dimensions,
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
    );
    return List.from(report).sublist(1, report.length - 1);
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
                ? 'Apps'
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
                        return EarningsSectionDetails(
                          section: widget.section,
                          data: data,
                          appId: widget.appId,
                        );
                      }
                    })),
          ),
        );
      }),
    );
  }
}
