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
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  bool _adFailedToLoad = false;
  int _adRetryAttempt = 0;
  final int _maxRetryAttempts = 3;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    // Get the ad unit ID from environment variables
    final adUnitId =
        dotenv.env[widget.adUnitIdKey] ??
        'ca-app-pub-3940256099942544/6300978111';

    AppLogger.debug(
      '🎯 Loading ad (attempt ${_adRetryAttempt + 1}/$_maxRetryAttempts) with ID: $adUnitId',
    );

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

            // Retry logic for network errors
            if (error.code == 2 && _adRetryAttempt < _maxRetryAttempts) {
              _adRetryAttempt++;
              AppLogger.info('🔄 Retrying ad load in 5 seconds...');

              Future.delayed(const Duration(seconds: 5), () {
                if (mounted) {
                  _loadBannerAd();
                }
              });
            } else {
              AppLogger.warning(
                '⚠️ Max retry attempts reached or non-network error',
              );
            }
          }
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded) {
      // Center the ad banner - responsive to screen width
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: SizedBox(
            height: _bannerAd.size.height.toDouble(),
            width: _bannerAd.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd),
          ),
        ),
      );
    } else if (_adFailedToLoad) {
      return Container(
        height: 50,
        width: double.infinity,
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Ad unavailable - Check internet connection',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 50,
        width: double.infinity,
        color: Colors.grey[100],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
  }
}
