import 'package:flutter/material.dart';

import '../../widgets/custom_banner_ad.dart';
import '../../widgets/custom_tab_indicator.dart';

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen>
    with TickerProviderStateMixin {
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

  final _gridData = {
    'Estimated Earnings': {'value': 0.735, 'pastValue': 1.34},
    'eCPM': {'value': 1.61, 'pastValue': 1.97},
    'Impressions': {'value': 457, 'pastValue': 681},
    'Ad Requests': {'value': 2136, 'pastValue': 2198},
    'Matched Requests': {'value': 1263, 'pastValue': 1197},
    'Match Rate': {'value': 59.12, 'pastValue': 54.45},
    'Show Rate': {'value': 36.18, 'pastValue': 56.89},
    'Clicks': {'value': 3, 'pastValue': 2},
    'CTR': {'value': 0.66, 'pastValue': 0.29},
  };

  final _appsData = {
    'College Attendance Tracker': {
      'icon': Icons.apps,
      'data': {
        'Estimated Earnings': 1.23,
        'eCPM': 2.34,
        'Impressions': 1234,
        'Ad Requests': 2345,
        'Matched Requests': 2000,
        'Match Rate': 85.4,
        'Show Rate': 78.3,
        'Clicks': 34,
        'CTR': 2.3,
      }
    },
    'StudyBuddy': {
      'icon': Icons.android,
      'data': {
        'Estimated Earnings': 0.89,
        'eCPM': 1.75,
        'Impressions': 980,
        'Ad Requests': 1980,
        'Matched Requests': 1600,
        'Match Rate': 82.1,
        'Show Rate': 76.8,
        'Clicks': 28,
        'CTR': 1.9,
      }
    },
    'Bhagavad Gita': {
      'icon': Icons.phone_android,
      'data': {
        'Estimated Earnings': 1.11,
        'eCPM': 2.21,
        'Impressions': 1340,
        'Ad Requests': 2210,
        'Matched Requests': 2100,
        'Match Rate': 88.2,
        'Show Rate': 79.3,
        'Clicks': 32,
        'CTR': 2.1,
      }
    },
    'HabitO - Habit Tracker': {
      'icon': Icons.ad_units,
      'data': {
        'Estimated Earnings': 0.99,
        'eCPM': 1.99,
        'Impressions': 890,
        'Ad Requests': 1890,
        'Matched Requests': 1700,
        'Match Rate': 84.0,
        'Show Rate': 75.5,
        'Clicks': 25,
        'CTR': 1.8,
      }
    },
  };

  final _adUnitsData = {
    'Banner Top': {
      'icon': Icons.view_day,
      'data': {
        'Estimated Earnings': 0.45,
        'eCPM': 1.25,
        'Impressions': 670,
        'Ad Requests': 900,
        'Matched Requests': 800,
        'Match Rate': 88.8,
        'Show Rate': 73.3,
        'Clicks': 10,
        'CTR': 1.5,
      }
    },
    'Interstitial': {
      'icon': Icons.fullscreen,
      'data': {
        'Estimated Earnings': 0.75,
        'eCPM': 2.50,
        'Impressions': 1240,
        'Ad Requests': 1400,
        'Matched Requests': 1300,
        'Match Rate': 92.0,
        'Show Rate': 80.0,
        'Clicks': 20,
        'CTR': 1.8,
      }
    },
  };

  final _countriesData = {
    'IN': {
      'name': 'India',
      'data': {
        'Estimated Earnings': 0.46,
        'eCPM': 0.85,
        'Impressions': 540,
        'Ad Requests': 1650,
        'Matched Requests': 1020,
        'Match Rate': 61.8,
        'Show Rate': 52.9,
        'Clicks': 3,
        'CTR': 0.55,
      }
    },
    'US': {
      'name': 'United States',
      'data': {
        'Estimated Earnings': 1.01,
        'eCPM': 3.45,
        'Impressions': 295,
        'Ad Requests': 378,
        'Matched Requests': 349,
        'Match Rate': 92.3,
        'Show Rate': 84.6,
        'Clicks': 2,
        'CTR': 0.67,
      }
    },
    'GB': {
      'name': 'United Kingdom',
      'data': {
        'Estimated Earnings': 0.27,
        'eCPM': 2.98,
        'Impressions': 90,
        'Ad Requests': 110,
        'Matched Requests': 98,
        'Match Rate': 89.1,
        'Show Rate': 91.8,
        'Clicks': 1,
        'CTR': 1.11,
      }
    },
  };

  late TabController _appsTabController;
  late TabController _adUnitsTabController;
  late TabController _countriesTabController;

  @override
  void initState() {
    super.initState();
    _appsTabController = TabController(length: _tabs.length, vsync: this);
    _adUnitsTabController = TabController(length: _tabs.length, vsync: this);
    _countriesTabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBannerAd(),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _buildHorizontalGrid(),
          ..._buildSection(
              'Apps',
              _appsData.map((key, value) => MapEntry(
                    key,
                    (value['data'] as Map<String, num>)
                        .map((k, v) => MapEntry(k, v.toDouble())),
                  )),
              _appsTabController),
          ..._buildSection(
              'Ad Units',
              _adUnitsData.map((key, value) => MapEntry(
                    key,
                    (value['data'] as Map<String, num>)
                        .map((k, v) => MapEntry(k, v.toDouble())),
                  )),
              _adUnitsTabController),
          ..._buildSection('Countries', _countriesData.map((key, value) {
            final rawData = value['data'] as Map<String, num>? ?? {};
            final doubleData = rawData.map((k, v) => MapEntry(k, v.toDouble()));
            return MapEntry(key, doubleData);
          }), _countriesTabController),
        ],
      ),
    );
  }

  Widget _buildHorizontalGrid() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _gridData.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 6,
          mainAxisExtent: 150,
        ),
        itemBuilder: (context, index) {
          final title = _gridData.keys.elementAt(index);
          final value = _gridData[title]!['value'];
          final pastValue = _gridData[title]!['pastValue'];
          final difference = value! - pastValue!;
          final isCurrency = title == 'Estimated Earnings' || title == 'eCPM';
          final isPercentage = title.contains('Rate') || title == 'CTR';
          final valueText = isCurrency
              ? '\$$value'
              : isPercentage
                  ? '$value%'
                  : value.toString();
          final pastValueText = isCurrency
              ? '\$$pastValue'
              : isPercentage
                  ? '$pastValue%'
                  : pastValue.toString();

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                Text(
                  valueText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: difference < 0
                        ? Colors.red.withOpacity(.2)
                        : difference == 0
                            ? Colors.amber.withOpacity(.2)
                            : Colors.green.withOpacity(.2),
                  ),
                  child: Text(
                    '$pastValueText ${difference >= 0 ? '↑' : '↓'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: difference < 0
                          ? Colors.red
                          : difference == 0
                              ? Colors.amber
                              : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSection(String title,
      Map<String, Map<String, num>> dataMap, TabController controller) {
    final sortedEntries = dataMap.entries.toList()
      ..sort((a, b) {
        final aVal = a.value[_tabs[controller.index]] ?? 0;
        final bVal = b.value[_tabs[controller.index]] ?? 0;
        return (bVal).compareTo(aVal);
      });
    return [
      SizedBox(height: 20),
      Text(
        '${dataMap.length} $title',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            TabBar(
              controller: controller,
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
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              onTap: (_) => setState(() {}),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedEntries.length,
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
                final name = entry.key;
                final value = entry.value[_tabs[controller.index]] ?? 0;
                final tab = _tabs[controller.index];

                String formattedValue = value.toString();
                if (tab == 'Estimated Earnings' || tab == 'eCPM') {
                  formattedValue = '\$${value.toStringAsFixed(2)}';
                } else if (tab.contains('Rate') || tab == 'CTR') {
                  formattedValue = '${value.toStringAsFixed(2)}%';
                } else if (value is double && value == value.roundToDouble()) {
                  formattedValue = value.toStringAsFixed(0);
                }
                final isAdUnit = title == 'Ad Units';
                final isCountry = title == 'Countries';
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 15, right: 10),
                    tileColor: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(15)),
                    leading: isCountry
                        ? Image.network(
                            'https://flagcdn.com/128x96/${name.toLowerCase()}.png',
                            width: 30,
                          )
                        : Icon(
                            isAdUnit
                                ? Icons.ad_units_rounded
                                : Icons.apps_rounded,
                            color: isAdUnit ? Colors.orange : Colors.blue,
                          ),
                    title: Text(
                      isCountry
                          ? (_countriesData[name]?['name'] as String?) ?? name
                          : name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusGeometry.circular(8),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        formattedValue,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ];
  }
}
