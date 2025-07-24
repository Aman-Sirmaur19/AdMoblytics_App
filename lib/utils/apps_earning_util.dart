class AppsEarningUtil {
  static Map<String, dynamic> getDateRange({
    required int selectedTabIndex,
    required String dimensionName,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    final DateTime currentDate = DateTime.now();
    DateTime startDate, endDate, pastStartDate, pastEndDate;
    List<String> dimensions = [dimensionName];
    List<Map<String, String>> sortConditions = [
      {"metric": "ESTIMATED_EARNINGS", "order": "DESCENDING"},
    ];

    switch (selectedTabIndex) {
      case 0: // Custom
        if (customStartDate == null || customEndDate == null) {
          // throw Exception("Custom startDate and endDate must be provided.");
          customStartDate = currentDate;
          customEndDate = currentDate;
        }
        startDate = customStartDate;
        endDate = customEndDate;
        dimensions = [dimensionName];
        final difference = customEndDate.difference(customStartDate).inDays;
        pastEndDate = customStartDate.subtract(const Duration(days: 1));
        pastStartDate = pastEndDate.subtract(Duration(days: difference));
        break;

      case 1: // Yesterday
        startDate = currentDate.subtract(const Duration(days: 1));
        endDate = currentDate.subtract(const Duration(days: 1));
        dimensions = ["DATE", dimensionName];
        pastStartDate = currentDate.subtract(const Duration(days: 2));
        pastEndDate = currentDate.subtract(const Duration(days: 2));
        break;

      case 2: // Today
        startDate = currentDate;
        endDate = currentDate;
        dimensions = ["DATE", dimensionName];
        pastStartDate = currentDate.subtract(const Duration(days: 1));
        pastEndDate = currentDate.subtract(const Duration(days: 1));
        break;

      case 3: // Last 7 days
        startDate = currentDate.subtract(const Duration(days: 6));
        endDate = currentDate;
        pastStartDate = currentDate.subtract(const Duration(days: 13));
        pastEndDate = currentDate.subtract(const Duration(days: 7));
        break;

      case 4: // This month
        startDate = DateTime(currentDate.year, currentDate.month, 1);
        endDate = currentDate;
        dimensions = ["MONTH", dimensionName];
        pastStartDate = DateTime(currentDate.year, currentDate.month - 1, 1);
        pastEndDate = DateTime(currentDate.year, currentDate.month, 1)
            .subtract(const Duration(days: 1));
        break;

      case 5: // Last month
        final lastMonth = DateTime(currentDate.year, currentDate.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(currentDate.year, currentDate.month, 1)
            .subtract(const Duration(days: 1));
        dimensions = ["MONTH", dimensionName];
        pastStartDate = DateTime(currentDate.year, currentDate.month - 2, 1);
        pastEndDate = DateTime(currentDate.year, currentDate.month - 1, 1)
            .subtract(const Duration(days: 1));
        break;

      case 6: // This year
        startDate = DateTime(currentDate.year, 1, 1);
        endDate = currentDate;
        pastStartDate = DateTime(currentDate.year - 1, 1, 1);
        pastEndDate = DateTime(currentDate.year - 1, 12, 31);
        break;

      case 7: // Last year
        startDate = DateTime(currentDate.year - 1, 1, 1);
        endDate = DateTime(currentDate.year - 1, 12, 31);
        pastStartDate = DateTime(currentDate.year - 2, 1, 1);
        pastEndDate = DateTime(currentDate.year - 2, 12, 31);
        break;

      case 8: // Total
        startDate = DateTime(1970, 1, 1); // Example: start from epoch
        endDate = currentDate;
        pastStartDate = DateTime(1970, 1, 1);
        pastEndDate = currentDate;
        break;

      default:
        throw Exception("Invalid tab index");
    }

    if (dimensionName == 'AD_UNIT' && !dimensions.contains('FORMAT')) {
      dimensions.add('FORMAT');
    }

    return {
      "startDate": startDate,
      "endDate": endDate,
      "dimensions": dimensions,
      "sortConditions": sortConditions,
      "pastStartDate": pastStartDate,
      "pastEndDate": pastEndDate,
    };
  }
}
