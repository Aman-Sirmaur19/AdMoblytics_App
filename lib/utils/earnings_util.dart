class EarningsUtil {
  static Map<String, dynamic> getDateRange(int selectedTabIndex) {
    final DateTime currentDate = DateTime.now();
    DateTime startDate, endDate;
    List<String> dimensions = ["DATE"];

    switch (selectedTabIndex) {
      case 0: // Custom
        startDate = currentDate;
        endDate = currentDate;
        break;

      case 1: // Yesterday
        startDate = currentDate.subtract(const Duration(days: 1));
        endDate = currentDate.subtract(const Duration(days: 1));
        break;

      case 2: // Today
        startDate = currentDate;
        endDate = currentDate;
        break;

      case 3: // Last 7 days
        startDate = currentDate.subtract(const Duration(days: 7));
        endDate = currentDate;
        dimensions = [];
        break;

      case 4: // This month
        startDate = DateTime(currentDate.year, currentDate.month, 1);
        endDate = currentDate;
        dimensions = ["MONTH"];
        break;

      case 5: // Last month
        final lastMonth = DateTime(currentDate.year, currentDate.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(currentDate.year, currentDate.month, 1)
            .subtract(const Duration(days: 1));
        dimensions = ["MONTH"];
        break;

      case 6: // This year
        startDate = DateTime(currentDate.year, 1, 1);
        endDate = currentDate;
        dimensions = [];
        break;

      case 7: // Last year
        startDate = DateTime(currentDate.year - 1, 1, 1);
        endDate = DateTime(currentDate.year - 1, 12, 31);
        dimensions = [];
        break;

      case 8: // Total
        startDate = DateTime(1970, 1, 1); // Example: start from epoch
        endDate = currentDate;
        dimensions = [];
        break;

      default:
        throw Exception("Invalid tab index");
    }

    return {
      "startDate": startDate,
      "endDate": endDate,
      "dimensions": dimensions,
    };
  }

  static void sortDataByTab(String tabName, List data) {
    data.sort((a, b) {
      if (a['row'] != null && b['row'] != null) {
        final aValue = _getTrailingValue(a, tabName);
        final bValue = _getTrailingValue(b, tabName);
        return bValue.compareTo(aValue); // Descending order
      }
      return 0;
    });
  }

  static double _getTrailingValue(Map<String, dynamic> entry, String tabName) {
    final metrics = entry['row']['metricValues'];
    switch (tabName) {
      case 'Estimated Earnings':
        return metrics['ESTIMATED_EARNINGS'] != null
            ? int.parse(metrics['ESTIMATED_EARNINGS']['microsValue']) / 1000000
            : 0.0;
      case 'eCPM':
        return metrics['IMPRESSION_RPM']?['doubleValue'] ?? 0.0;
      case 'Impressions':
        return double.tryParse(
                metrics['IMPRESSIONS']?['integerValue'] ?? '0') ??
            0.0;
      case 'Ad Requests':
        return double.tryParse(
                metrics['AD_REQUESTS']?['integerValue'] ?? '0') ??
            0.0;
      case 'Matched Requests':
        return double.tryParse(
                metrics['MATCHED_REQUESTS']?['integerValue'] ?? '0') ??
            0.0;
      case 'Match Rate':
        return ((metrics['MATCH_RATE']?['doubleValue'] as num?) ?? 0)
                .toDouble() *
            100;
      case 'Show Rate':
        return ((metrics['SHOW_RATE']?['doubleValue'] as num?) ?? 0)
                .toDouble() *
            100;
      case 'Clicks':
        return double.tryParse(metrics['CLICKS']?['integerValue'] ?? '0') ??
            0.0;
      case 'CTR':
      default:
        return ((metrics['IMPRESSION_CTR']?['doubleValue'] as num?) ?? 0)
            .toDouble();
    }
  }
}
