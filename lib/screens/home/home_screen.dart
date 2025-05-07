import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/admob_service.dart';
import '../../utils/earnings_util.dart';
import '../../utils/apps_earning_util.dart';
import '../../providers/tab_provider.dart';
import '../../providers/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _future = _loadAllReports(context);
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
    final appRange = AppsEarningUtil(tabIndex: tabIndex, dimensionName: 'APP')
        .getDateRange();
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
    ]);

    return {
      'earningsGrid': List.from(reports[0]).sublist(1, reports[0].length - 1),
      'app': List.from(reports[1]).sublist(1, reports[1].length - 1),
      'adUnit': List.from(reports[2]).sublist(1, reports[2].length - 1),
      'country': List.from(reports[3]).sublist(1, reports[3].length - 1),
    };
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  EarningsGrid(data: data['earningsGrid']),
                  const SizedBox(height: 10),
                  EarningsSection(section: 'APP', data: data['app']),
                  const SizedBox(height: 10),
                  EarningsSection(section: 'AD_UNIT', data: data['adUnit']),
                  const SizedBox(height: 10),
                  EarningsSection(section: 'COUNTRY', data: data['country']),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
