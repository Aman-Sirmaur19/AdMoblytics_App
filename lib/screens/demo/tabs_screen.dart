import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/ad_manager.dart';
import '../../widgets/custom_tab_indicator.dart';
import '../dashboard_screen.dart';
import 'home_screen.dart';

class DemoTabsScreen extends StatefulWidget {
  const DemoTabsScreen({super.key});

  @override
  State<DemoTabsScreen> createState() => _DemoTabsScreenState();
}

class _DemoTabsScreenState extends State<DemoTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('AdMob Dashboard'),
        actions: [
          IconButton(
            onPressed: () =>
                AdManager().navigateWithAd(context, const DashboardScreen()),
            tooltip: 'Dashboard',
            icon: const Icon(CupertinoIcons.square_grid_2x2),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
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
      body: TabBarView(
        controller: _tabController,
        children: List.generate(9, (index) => const DemoHomeScreen()),
      ),
    );
  }
}
