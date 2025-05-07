import 'package:flutter/material.dart';

class LeadingIcon extends StatelessWidget {
  final String section;
  final String value;

  const LeadingIcon({super.key, required this.section, required this.value});

  @override
  Widget build(BuildContext context) {
    if (section == "APP") {
      return const Icon(Icons.apps_rounded, color: Colors.blue);
    } else if (section == "AD_UNIT") {
      if (value.contains("banner")) {
        return const Icon(Icons.view_module_rounded, color: Colors.green);
      } else if (value.contains("interstitial")) {
        return const Icon(Icons.fullscreen_rounded, color: Colors.red);
      } else if (value.contains("native")) {
        return const Icon(Icons.widgets_rounded, color: Colors.purple);
      } else {
        return const Icon(Icons.ad_units_rounded, color: Colors.orange);
      }
    } else if (section == "COUNTRY") {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          "https://flagcdn.com/w40/${value.toLowerCase()}.png",
        ),
      );
    }
    return const Icon(Icons.help_outline, color: Colors.grey);
  }
}
