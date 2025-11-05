import 'package:flutter/material.dart ';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'utils/app_logger.dart';
import 'package:random_kit_app/dice_logic.dart';

class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  int _currentRoll = 1;
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  bool _adFailedToLoad = false;
  int _adRetryAttempt = 0;
  final int _maxRetryAttempts = 3;

  @override
  void initState() {
    super.initState();
    // Start Loading the AdMob banner
    _loadBannerAd();
  }

  @override
  void dispose() {
    // Always clean up resources
    _bannerAd.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    // Retrieve the banner ID safely from the loaded environment file
    final adUnitId =
        dotenv.env['ADMOB_BANNER_ID'] ??
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
          setState(() {
            // Show ad only if successfully loaded
            _isAdLoaded = true;
            _adFailedToLoad = false;
            _adRetryAttempt = 0;
          });
          AppLogger.info('✅ AD LOADED SUCCESSFULLY!');
          // print('✅ AD Loaded Successfully!');
        },
        onAdFailedToLoad: (ad, error) {
          // print('❌ AD Failed to Load: $error');
          AppLogger.error('❌ AD Failed to Load', error);
          ad.dispose();

          setState(() {
            _isAdLoaded = false;
            _adFailedToLoad = true;
          });

          // Retry Ad Logic for network errors
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
        },
      ),
    );
    _bannerAd.load();
  }

  Widget _buildAdBanner() {
    if (_isAdLoaded) {
      return SizedBox(
        height: _bannerAd.size.height.toDouble(),
        width: _bannerAd.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd),
      );
    } else if (_adFailedToLoad) {
      return Container(
        height: 50,
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Ad unavailable - Check internet connection',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 50,
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

  void _rollDice() {
    // Calls the core logic and updates the state (the number on the screen)
    final newRoll = DiceLogic.rollD6();
    // AppLogger.debug('🎲 Rolled: $newRoll');

    setState(() {
      _currentRoll = newRoll;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // The main display for the roll result,
            Text(
              '$_currentRoll',
              // Key for Widget Testing
              key: const Key('diceResultText'),
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 50),
            // The button to trigger the roll,
            ElevatedButton(
              onPressed: _rollDice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'ROLL DICE',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      // AdMob Banner at the bottom
      bottomNavigationBar: _buildAdBanner(),
    );
  }
}
