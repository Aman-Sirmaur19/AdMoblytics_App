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
        return SvgPicture.asset('assets/images/banner.svg', width: 40);
      } else if (value.contains("interstitial")) {
        return SvgPicture.asset('assets/images/interstitial.svg', width: 40);
      } else if (value.contains("native")) {
        return SvgPicture.asset('assets/images/native.svg', width: 40);
      } else if (value.contains("rewarded")) {
        return SvgPicture.asset('assets/images/rewarded.svg', width: 40);
      } else if (value.contains("app")) {
        return SvgPicture.asset('assets/images/app-open.svg', width: 40);
      } else if (value.contains("rewarded-interstitial")) {
        return SvgPicture.asset('assets/images/rewarded-interstitial.svg',
            width: 40);
      } else {
        return const Icon(Icons.ad_units_rounded, color: Colors.orange);
      }
    } else if (section == "COUNTRY") {
      return Image.network(
        "https://flagcdn.com/w320/${value.toLowerCase()}.png",
        width: 30,
      );
    }
    return const Icon(Icons.help_outline, color: Colors.grey);
  }
}
