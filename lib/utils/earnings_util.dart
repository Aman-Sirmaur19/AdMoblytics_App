class EarningsUtil {
  static Map<String, dynamic> getDateRange({
    required int selectedTabIndex,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    final DateTime currentDate = DateTime.now();
    DateTime startDate, endDate, pastStartDate, pastEndDate;
    List<String> dimensions = ["DATE"];

    switch (selectedTabIndex) {
      case 0: // Custom
        if (customStartDate == null || customEndDate == null) {
          throw Exception("Custom startDate and endDate must be provided.");
          // customStartDate = currentDate;
          // customEndDate = currentDate;
        }
        startDate = customStartDate;
        endDate = customEndDate;
        // dimensions = [];
        final difference = customEndDate.difference(customStartDate).inDays;
        pastEndDate = customStartDate.subtract(const Duration(days: 1));
        pastStartDate = pastEndDate.subtract(Duration(days: difference));
        break;

      case 1: // Yesterday
        startDate = currentDate.subtract(const Duration(days: 1));
        endDate = currentDate.subtract(const Duration(days: 1));
        pastStartDate = currentDate.subtract(const Duration(days: 2));
        pastEndDate = currentDate.subtract(const Duration(days: 2));
        break;

      case 2: // Today
        startDate = currentDate;
        endDate = currentDate;
        pastStartDate = currentDate.subtract(const Duration(days: 1));
        pastEndDate = currentDate.subtract(const Duration(days: 1));
        break;

      case 3: // Last 7 days
        startDate = currentDate.subtract(const Duration(days: 6));
        endDate = currentDate;
        // dimensions = [];
        pastStartDate = currentDate.subtract(const Duration(days: 13));
        pastEndDate = currentDate.subtract(const Duration(days: 7));
        break;

      case 4: // This month
        startDate = DateTime(currentDate.year, currentDate.month, 1);
        endDate = currentDate;
        // dimensions = ["MONTH"];
        pastStartDate = DateTime(currentDate.year, currentDate.month - 1, 1);
        pastEndDate = DateTime(currentDate.year, currentDate.month, 1)
            .subtract(const Duration(days: 1));
        break;

      case 5: // Last month
        startDate = DateTime(currentDate.year, currentDate.month - 1, 1);
        endDate = DateTime(currentDate.year, currentDate.month, 1)
            .subtract(const Duration(days: 1));
        // dimensions = ["MONTH"];
        pastStartDate = DateTime(currentDate.year, currentDate.month - 2, 1);
        pastEndDate = DateTime(currentDate.year, currentDate.month - 1, 1)
            .subtract(const Duration(days: 1));
        break;

      case 6: // This year
        startDate = DateTime(currentDate.year, 1, 1);
        endDate = currentDate;
        // dimensions = [];
        pastStartDate = DateTime(currentDate.year - 1, 1, 1);
        pastEndDate = DateTime(currentDate.year - 1, 12, 31);
        break;

      case 7: // Last year
        startDate = DateTime(currentDate.year - 1, 1, 1);
        endDate = DateTime(currentDate.year - 1, 12, 31);
        // dimensions = [];
        pastStartDate = DateTime(currentDate.year - 2, 1, 1);
        pastEndDate = DateTime(currentDate.year - 2, 12, 31);
        break;

      case 8: // Total
        startDate = DateTime(1970, 1, 1); // Epoch start
        endDate = currentDate;
        // dimensions = [];
        pastStartDate = DateTime(1970, 1, 1);
        pastEndDate = currentDate;
        break;

      default:
        throw Exception("Invalid tab index");
    }

    return {
      "startDate": startDate,
      "endDate": endDate,
      "dimensions": dimensions,
      "pastStartDate": pastStartDate,
      "pastEndDate": pastEndDate,
    };
  }

  static void sortDataByTab(String tabName, List data) {
    data.sort((a, b) {
      if (a['row'] != null && b['row'] != null) {
        final aValue = getTrailingValue(a, tabName);
        final bValue = getTrailingValue(b, tabName);
        return bValue.compareTo(aValue); // Descending order
      }
      return 0;
    });
  }

  static double getTrailingValue(Map<String, dynamic> entry, String tabName) {
    final metrics = entry['row']['metricValues'];
    switch (tabName) {
      case 'Estimated Earnings':
        return metrics['ESTIMATED_EARNINGS'] != null
            ? int.parse(metrics['ESTIMATED_EARNINGS']['microsValue']) / 1000000
            : 0.0;
      case 'eCPM':
        return (metrics['IMPRESSION_RPM']?['doubleValue'] as num?)
                ?.toDouble() ??
            0.0;
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
        return ((metrics['IMPRESSION_CTR']?['doubleValue'] as num?) ?? 0.0)
                .toDouble() *
            100;
      default:
        return ((metrics['IMPRESSION_CTR']?['doubleValue'] as num?) ?? 0)
            .toDouble();
    }
  }
}
