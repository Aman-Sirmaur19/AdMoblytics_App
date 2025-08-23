import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeadingIcon extends StatelessWidget {
  final String section;
  final String value;

  const LeadingIcon({super.key, required this.section, required this.value});

  @override
  Widget build(BuildContext context) {
    if (section == "APP") {
      return const Icon(
        Icons.android_rounded,
        size: 39,
        color: Colors.green,
      );
    } else if (section == "AD_UNIT") {
      if (value.contains("banner")) {
        return _iconContainer("banner", context);
      } else if (value.contains("interstitial")) {
        return _iconContainer("interstitial", context);
      } else if (value.contains("native")) {
        return _iconContainer("native", context);
      } else if (value.contains("rewarded")) {
        return _iconContainer("rewarded", context);
      } else if (value.contains("app")) {
        return _iconContainer("app-open", context);
      } else if (value.contains("rewarded-interstitial")) {
        return _iconContainer("rewarded-interstitial", context);
      } else {
        return const Icon(Icons.ad_units_rounded, color: Colors.orange);
      }
    } else if (section == "COUNTRY") {
      return Image.network(
        // "https://flagcdn.com/w320/${value.toLowerCase()}.png",
        "https://flagcdn.com/128x96/${value.toLowerCase()}.png",
        width: 35,
      );
    }
    return const Icon(Icons.help_outline, color: Colors.grey);
  }

  Widget _iconContainer(String label, BuildContext context) {
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: SvgPicture.asset('assets/images/$label.svg'));
  }
}
