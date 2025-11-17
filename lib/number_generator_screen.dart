// lib/number_generator_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'utils/app_logger.dart';
import 'package:random_kit_app/number_generator_logic.dart';

class NumberGeneratorScreen extends StatefulWidget {
  const NumberGeneratorScreen({super.key});

  @override
  State<NumberGeneratorScreen> createState() => _NumberGeneratorScreenState();
}

class _NumberGeneratorScreenState extends State<NumberGeneratorScreen> {
  int _currentResult = 0;
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(
    text: '100',
  );

  // Decentralized Admob State & Logic (Copied/Modified from Dice Roller Screen)
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
    _minController.dispose();
    _maxController.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    // Retrieve the banner ID safely from the loaded environment file
    final adUnitId =
        dotenv.env['ADMOB_BANNER_ID_GENERATOR'] ??
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

  void _generateNumber() {
    final int min = int.tryParse(_minController.text) ?? 1;
    final int max = int.tryParse(_maxController.text) ?? 100;
    final newResult = NumberGeneratorLogic.generateNumber(min, max);

    setState(() {
      _currentResult = newResult;
    });
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar here, it's provided by HomeScreen
      body: CustomScrollView(
        slivers: <Widget>[
          // 1. Main Content List - Everything that scrolls
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(child: _buildInputField('Min', _minController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField('Max', _maxController)),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  '$_currentResult',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _generateNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'GENERATE NUMBER',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 50),
                // Spacer to ensure content scrolls above the ad and bottom navigation bar
                const SizedBox(height: 80),
              ]),
            ),
          ),

          // 2. Ad Banner Placement - fixed above the BottomNavigationBar
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: _buildAdBanner(), // Use the local ad builder
              ),
            ),
          ),
        ],
      ),
    );
  }
}
