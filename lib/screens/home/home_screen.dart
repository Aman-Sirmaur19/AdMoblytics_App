import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/earnings_util.dart';
import '../../utils/apps_earning_util.dart';
import '../../services/admob_service.dart';
import '../../providers/tab_provider.dart';
import '../../providers/apps_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/earnings/earnings_grid.dart';
import '../../widgets/earnings/earnings_section.dart';
import '../../widgets/internet_connectivity_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _future;
  TabProvider? _tabProvider;
  DateTime now = DateTime.now();
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _future = _loadAllReports(context);
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _future = _loadAllReports(context);
    });
  }

  Future<Map<String, dynamic>> _loadAllReports(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appsProvider = Provider.of<AppsProvider>(context, listen: false);
    final admobService = AdMobService(authProvider.accessToken!);
    if (!appsProvider.isLoaded) {
      final publishedApps = await admobService.fetchPublishedApps(
        accessToken: authProvider.accessToken!,
        accountId: authProvider.accountId!,
      );
      final appsList =
          (publishedApps['apps'] as List).cast<Map<String, dynamic>>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appsProvider.setApps(appsList);
      });
    }
    final earningsGridRange = EarningsUtil.getDateRange(
      selectedTabIndex: _tabProvider!.selectedTabIndex,
      customStartDate:
          _tabProvider!.selectedTabIndex == 0 ? _customStartDate ?? now : null,
      customEndDate:
          _tabProvider!.selectedTabIndex == 0 ? _customEndDate ?? now : null,
    );
    final appRange = AppsEarningUtil.getDateRange(
      selectedTabIndex: _tabProvider!.selectedTabIndex,
      dimensionName: 'APP',
      customStartDate:
          _tabProvider!.selectedTabIndex == 0 ? _customStartDate : null,
      customEndDate:
          _tabProvider!.selectedTabIndex == 0 ? _customEndDate : null,
    );
    final adUnitRange = AppsEarningUtil.getDateRange(
      selectedTabIndex: _tabProvider!.selectedTabIndex,
      dimensionName: 'AD_UNIT',
      customStartDate:
          _tabProvider!.selectedTabIndex == 0 ? _customStartDate : null,
      customEndDate:
          _tabProvider!.selectedTabIndex == 0 ? _customEndDate : null,
    );
    final countryRange = AppsEarningUtil.getDateRange(
      selectedTabIndex: _tabProvider!.selectedTabIndex,
      dimensionName: 'COUNTRY',
      customStartDate:
          _tabProvider!.selectedTabIndex == 0 ? _customStartDate : null,
      customEndDate:
          _tabProvider!.selectedTabIndex == 0 ? _customEndDate : null,
    );

    final reports = await Future.wait([
      admobService.generateNetworkReport(
        accessToken: authProvider.accessToken!,
        accountId: authProvider.accountId!,
        customBody: admobService.buildAdMobReportBody(
          startDate: earningsGridRange['startDate'],
          endDate: earningsGridRange['endDate'],
          dimensions: earningsGridRange['dimensions'],
        ),
      ),
      admobService.generateNetworkReport(
        accessToken: authProvider.accessToken!,
        accountId: authProvider.accountId!,
        customBody: admobService.buildAdMobReportBody(
          startDate: appRange['startDate'],
          endDate: appRange['endDate'],
          dimensions: appRange['dimensions'],
          sortConditions: appRange['sortConditions'],
        ),
      ),
      admobService.generateNetworkReport(
        accessToken: authProvider.accessToken!,
        accountId: authProvider.accountId!,
        customBody: admobService.buildAdMobReportBody(
          startDate: adUnitRange['startDate'],
          endDate: adUnitRange['endDate'],
          dimensions: adUnitRange['dimensions'],
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
          sortConditions: countryRange['sortConditions'],
        ),
      ),
      if (_tabProvider!.selectedTabIndex != 8)
        admobService.generateNetworkReport(
          accessToken: authProvider.accessToken!,
          accountId: authProvider.accountId!,
          customBody: admobService.buildAdMobReportBody(
            startDate: earningsGridRange['pastStartDate'],
            endDate: earningsGridRange['pastEndDate'],
            dimensions: earningsGridRange['dimensions'],
          ),
        ),
      if (_tabProvider!.selectedTabIndex != 8)
        admobService.generateNetworkReport(
          accessToken: authProvider.accessToken!,
          accountId: authProvider.accountId!,
          customBody: admobService.buildAdMobReportBody(
            startDate: appRange['pastStartDate'],
            endDate: appRange['pastEndDate'],
            dimensions: appRange['dimensions'],
            sortConditions: appRange['sortConditions'],
          ),
        ),
      if (_tabProvider!.selectedTabIndex != 8)
        admobService.generateNetworkReport(
          accessToken: authProvider.accessToken!,
          accountId: authProvider.accountId!,
          customBody: admobService.buildAdMobReportBody(
            startDate: adUnitRange['pastStartDate'],
            endDate: adUnitRange['pastEndDate'],
            dimensions: adUnitRange['dimensions'],
            sortConditions: adUnitRange['sortConditions'],
          ),
        ),
      if (_tabProvider!.selectedTabIndex != 8)
        admobService.generateNetworkReport(
          accessToken: authProvider.accessToken!,
          accountId: authProvider.accountId!,
          customBody: admobService.buildAdMobReportBody(
            startDate: countryRange['pastStartDate'],
            endDate: countryRange['pastEndDate'],
            dimensions: countryRange['dimensions'],
            sortConditions: countryRange['sortConditions'],
          ),
        ),
    ]);

    return {
      'earningsGrid': List.from(reports[0]).sublist(1, reports[0].length - 1),
      'app': List.from(reports[1]).sublist(1, reports[1].length - 1),
      'adUnit': List.from(reports[2]).sublist(1, reports[2].length - 1),
      'country': List.from(reports[3]).sublist(1, reports[3].length - 1),
      if (_tabProvider!.selectedTabIndex != 8)
        'pastEarningsGrid':
            List.from(reports[4]).sublist(1, reports[4].length - 1),
      if (_tabProvider!.selectedTabIndex != 8)
        'pastApp': List.from(reports[5]).sublist(1, reports[5].length - 1),
      if (_tabProvider!.selectedTabIndex != 8)
        'pastAdUnit': List.from(reports[6]).sublist(1, reports[6].length - 1),
      if (_tabProvider!.selectedTabIndex != 8)
        'pastCountry': List.from(reports[7]).sublist(1, reports[7].length - 1),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Store tabProvider reference safely
    _tabProvider ??= Provider.of<TabProvider>(context);
    _tabProvider?.addListener(_onTabIndexChanged);
  }

  void _onTabIndexChanged() {
    if (_tabProvider?.selectedTabIndex != 0) {
      _customStartDate = null;
      _customEndDate = null;
    }
    if (mounted) {
      _refresh();
    }
  }

  @override
  void dispose() {
    // Use the stored reference instead of accessing context
    _tabProvider?.removeListener(_onTabIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> dateRange;
    try {
      dateRange = EarningsUtil.getDateRange(
        selectedTabIndex: _tabProvider!.selectedTabIndex,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
      );
    } catch (_) {
      dateRange = {
        'startDate': now,
        'endDate': now,
      };
    }
    _customStartDate = dateRange['startDate'];
    _customEndDate = dateRange['endDate'];
    return Scaffold(
      bottomNavigationBar: const CustomBannerAd(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.blue,
        backgroundColor: Colors.blue.shade50,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.blue));
            } else if (snapshot.hasError) {
              return InternetConnectivityButton(onPressed: _refresh);
            }
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView(
                children: [
                  CustomDate(
                    startDate: _customStartDate,
                    endDate: _customEndDate,
                    showButton: _tabProvider!.selectedTabIndex == 0,
                    onDateRangeSelected: (start, end) {
                      setState(() {
                        _customStartDate = start;
                        _customEndDate = end;
                        _future = _loadAllReports(context);
                      });
                    },
                  ),
                  const SizedBox(height: 5),
                  EarningsGrid(
                    data: data['earningsGrid'],
                    pastData: data['pastEarningsGrid'],
                  ),
                  const SizedBox(height: 10),
                  EarningsSection(
                    section: 'APP',
                    data: data['app'],
                    customStartDate: _customStartDate,
                    customEndDate: _customEndDate,
                    pastData: data['pastApp'],
                  ),
                  const SizedBox(height: 10),
                  EarningsSection(
                    section: 'AD_UNIT',
                    data: data['adUnit'],
                    customStartDate: _customStartDate,
                    customEndDate: _customEndDate,
                    pastData: data['pastAdUnit'],
                  ),
                  const SizedBox(height: 10),
                  EarningsSection(
                    section: 'COUNTRY',
                    data: data['country'],
                    customStartDate: _customStartDate,
                    customEndDate: _customEndDate,
                    pastData: data['pastCountry'],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
