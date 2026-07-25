// lib/widgets/ad_banner_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/app_logger.dart';

class AdBannerWidget extends StatefulWidget {
  final String adUnitIdKey;

  const AdBannerWidget({super.key, required this.adUnitIdKey});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _adFailedToLoad = false;
  int _adRetryAttempt = 0;
  final int _maxRetryAttempts = 5;

  @override
  void initState() {
    super.initState();
    // Wait until the layout tree has completed rendering before requesting banner ad
    // This prevents "Invalid ad width or height: (0, 0)" errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBannerAd();
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final adUnitId =
        dotenv.env[widget.adUnitIdKey] ??
        'ca-app-pub-3940256099942544/6300978111';

    AppLogger.debug(
      '🎯 Loading ad (attempt ${_adRetryAttempt + 1}/$_maxRetryAttempts) for key [${widget.adUnitIdKey}] with ID: $adUnitId',
    );

    // Clean up existing ad instance before re-creating
    _bannerAd?.dispose();

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _adFailedToLoad = false;
              _adRetryAttempt = 0;
            });
            AppLogger.info('✅ AD LOADED SUCCESSFULLY (${widget.adUnitIdKey})');
          }
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.error('❌ AD Failed to Load (${widget.adUnitIdKey})', error);
          ad.dispose();

          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _adFailedToLoad = true;
            });

            // Retry logic for network / initial DNS delays
            if (_adRetryAttempt < _maxRetryAttempts) {
              _adRetryAttempt++;
              final delaySeconds = _adRetryAttempt * 3;
              AppLogger.info('🔄 Retrying ad load in $delaySeconds seconds...');

              Future.delayed(Duration(seconds: delaySeconds), () {
                if (mounted) {
                  _loadBannerAd();
                }
              });
            } else {
              AppLogger.warning('! ! Max retry attempts reached for ${widget.adUnitIdKey}');
            }
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    if (_adFailedToLoad) {
      return const SizedBox.shrink();
    }

    // Placeholder box with subtle loading spinner while banner loads
    return Container(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      alignment: Alignment.center,
      color: Colors.transparent,
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.orange.withAlpha(150),
          ),
        ),
      ),
    );
  }
}
