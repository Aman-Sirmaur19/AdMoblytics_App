import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tab_provider.dart';
import '../../widgets/custom_tab_indicator.dart';
import '../dashboard_screen.dart';
import 'home_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging ||
        _tabController.animation!.status == AnimationStatus.completed) {
      Provider.of<TabProvider>(context, listen: false)
          .updateTabIndex(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      initialIndex: 0,
      child: Consumer<TabProvider>(
        builder: (context, tabProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_tabController.index != tabProvider.selectedTabIndex) {
              _tabController.index = tabProvider.selectedTabIndex;
            }
          });
          return Scaffold(
            appBar: AppBar(
              title: const Text('AdMob Dashboard'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const DashboardScreen())),
                  tooltip: 'Dashboard',
                  icon: const Icon(CupertinoIcons.square_grid_2x2),
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
                onTap: (index) =>
                    Provider.of<TabProvider>(context, listen: false)
                        .updateTabIndex(index),
                tabs: const <Widget>[
                  Tab(text: 'Today'),
                  Tab(text: 'Yesterday'),
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
              children: List.generate(8, (index) => const HomeScreen()),
            ),
          );
        },
      ),
    );
  }
}
