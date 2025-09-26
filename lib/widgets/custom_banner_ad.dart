import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../secrets.dart';

class CustomBannerAd extends StatefulWidget {
  // Now you can specify the ad size when you create the widget.
  final AdSize adSize;

  const CustomBannerAd({
    super.key,
    this.adSize = AdSize.banner, // Defaults to standard banner.
  });

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  double _adHeight = 0; // Will be set dynamically.
  Timer? _retryTimer;

  int _retryAttempt = 0;
  static const int _maxRetryDelay = 300; // max 5 minutes
  static const int _maxRetryAttempts = 3;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    // Set the initial shimmer height based on the passed-in ad size.
    _adHeight = widget.adSize.height.toDouble();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (_retryAttempt >= _maxRetryAttempts) return;

    _bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: Secrets.bannerAdId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _resetRetry();
          if (!mounted) return;
          setState(() {
            _nativeAd?.dispose();
            _nativeAd = null;
            _adHeight = _bannerAd!.size.height.toDouble();
          });
        },
        onAdFailedToLoad: (ad, error) {
          log('BannerAd failed: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            _loadNativeAd();
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  void _loadNativeAd() {
    if (_retryAttempt >= _maxRetryAttempts) return;

    _nativeAd = NativeAd(
      adUnitId: Secrets.nativeAdId,
      request: const AdRequest(),
      nativeTemplateStyle:
          NativeTemplateStyle(templateType: TemplateType.small),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _resetRetry();
          if (!mounted) return;
          setState(() {
            _adHeight = 85; // Native small template has a fixed height.
          });
        },
        onAdFailedToLoad: (ad, error) {
          log('NativeAd failed: ${error.message}');
          ad.dispose();
          _nativeAd = null;
          if (mounted) {
            _scheduleRetry();
          }
        },
      ),
    );

    _nativeAd!.load();
  }

  void _scheduleRetry() {
    _retryAttempt++;
    if (_retryAttempt > _maxRetryAttempts) {
      log('Max retry attempts reached. No more ad attempts.');
      if (mounted) {
        setState(() {
          _bannerAd = null;
          _nativeAd = null;
        });
      }
      return;
    }

    int delaySeconds = (30 * (1 << (_retryAttempt - 1)));
    if (delaySeconds > _maxRetryDelay) delaySeconds = _maxRetryDelay;

    log('Retrying ad load in $delaySeconds seconds (attempt $_retryAttempt)');

    _cancelRetry();
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      // ✨ IMPROVEMENT: Add 'mounted' check in async timer callback.
      if (mounted) {
        _loadBannerAd();
      }
    });

    if (mounted) {
      setState(() {
        _bannerAd = null;
        _nativeAd = null;
        // Reset shimmer height to the expected banner size.
        _adHeight = widget.adSize.height.toDouble();
      });
    }
  }

  void _resetRetry() {
    _cancelRetry();
    _retryAttempt = 0;
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  void dispose() {
    _cancelRetry();
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (The build method remains the same and is already excellent)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColors = isDark
        ? [Colors.grey.shade900, Colors.grey.shade800, Colors.grey.shade900]
        : [Colors.grey.shade300, Colors.grey.shade100, Colors.grey.shade300];

    final adToShow = _bannerAd ?? _nativeAd;

    if (adToShow != null) {
      return SizedBox(
        height: _adHeight,
        child: AdWidget(ad: adToShow),
      );
    }

    if (_retryAttempt >= _maxRetryAttempts) {
      return const SizedBox.shrink(); // Hide after all retries fail.
    }

    // Shimmer placeholder while loading or waiting for retry.
    return SizedBox(
      height: _adHeight,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: shimmerColors,
                stops: const [0.1, 0.5, 0.9],
                begin: Alignment(-1 + 2 * _shimmerController.value, 0),
                end: Alignment(0 + 2 * _shimmerController.value, 0),
              ),
            ),
          );
        },
      ),
    );
  }
}
