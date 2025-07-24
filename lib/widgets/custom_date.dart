import 'package:flutter/material.dart';

import '../utils/utils.dart';

class CustomDate extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime start, DateTime end) onDateRangeSelected;
  final bool showButton;

  const CustomDate({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
    this.showButton = true,
  });

  String _formattedDateText() {
    if (startDate == null || endDate == null) return 'Date: --';
    final String start = Utils.formatDate(startDate!);
    final String end = Utils.formatDate(endDate!);
    return start == end ? 'Date: $start' : 'Date: $start to $end';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.primary,
          ),
          padding: const EdgeInsets.all(5),
          child: Text(
            _formattedDateText(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        if (showButton)
          TextButton(
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                keyboardType: TextInputType.name,
                initialDateRange: startDate != null && endDate != null
                    ? DateTimeRange(start: startDate!, end: endDate!)
                    : null,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      appBarTheme: const AppBarTheme()
                          .copyWith(backgroundColor: Colors.blue),
                      colorScheme: Theme.of(context)
                          .colorScheme
                          .copyWith(primary: Colors.blue),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateRangeSelected(picked.start, picked.end);
              }
            },
            child: const Text('Choose Date'),
          ),
      ],
    );
  }
}
