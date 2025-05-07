class AppsEarningUtil {
  final int tabIndex;
  final String dimensionName;

  AppsEarningUtil({required this.tabIndex, required this.dimensionName});

  Map<String, dynamic> getDateRange() {
    final DateTime currentDate = DateTime.now();
    DateTime startDate, endDate;
    List<String> dimensions = [dimensionName];
    List<Map<String, String>> sortConditions = [
      {"metric": "ESTIMATED_EARNINGS", "order": "DESCENDING"},
    ];

    switch (tabIndex) {
      case 0: // Today
        startDate = currentDate;
        endDate = currentDate;
        dimensions = ["DATE", dimensionName];
        break;

      case 1: // Yesterday
        startDate = currentDate.subtract(const Duration(days: 1));
        endDate = currentDate.subtract(const Duration(days: 1));
        dimensions = ["DATE", dimensionName];
        break;

      case 2: // Last 7 days
        startDate = currentDate.subtract(const Duration(days: 7));
        endDate = currentDate;
        break;

      case 3: // This month
        startDate = DateTime(currentDate.year, currentDate.month, 1);
        endDate = currentDate;
        dimensions = ["MONTH", dimensionName];
        break;

      case 4: // Last month
        final lastMonth = DateTime(currentDate.year, currentDate.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(currentDate.year, currentDate.month, 1)
            .subtract(const Duration(days: 1));
        dimensions = ["MONTH", dimensionName];
        break;

      case 5: // This year
        startDate = DateTime(currentDate.year, 1, 1);
        endDate = currentDate;
        break;

      case 6: // Last year
        startDate = DateTime(currentDate.year - 1, 1, 1);
        endDate = DateTime(currentDate.year - 1, 12, 31);
        break;

      case 7: // Total
        startDate = DateTime(1970, 1, 1); // Example: start from epoch
        endDate = currentDate;
        break;

      default:
        throw Exception("Invalid tab index");
    }

    return {
      "startDate": startDate,
      "endDate": endDate,
      "dimensions": dimensions,
      "sortConditions": sortConditions,
    };
  }
}
