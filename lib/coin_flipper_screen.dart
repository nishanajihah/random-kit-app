// lib/coin_flipper_screen.dart

import 'package:flutter/material.dart';

import 'coin_flipper_logic.dart';
import 'widgets/base_feature_screen.dart';

class CoinFlipperScreen extends StatefulWidget {
  const CoinFlipperScreen({super.key});

  @override
  State<CoinFlipperScreen> createState() => _CoinFlipperScreenState();
}

class _CoinFlipperScreenState extends State<CoinFlipperScreen> {
  String _currentResult = 'Heads';

  void _flipCoin() {
    final newResult = CoinFlipperLogic.flip();
    setState(() {
      _currentResult = newResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Random Kit+ Idle',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(204),
              ),
            ),
            const Text(
              'Coin Flipper',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BaseFeatureScreen(
        adUnitIdKey: 'ADMOB_BANNER_ID_COIN',
        children: [
          const SizedBox(height: 50),
          Text(
            _currentResult, // Display Heads or Tails
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.amber[700],
            ),
          ),
          const SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: _flipCoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'FLIP COIN',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
