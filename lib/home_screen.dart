// lib/home_screen.dart

import 'package:flutter/material.dart';

// Note: The new screens we will create/modify
import 'dice_roller_screen.dart';
import 'number_generator_screen.dart';
import 'coin_flipper_screen.dart';
import 'color_mixer_screen.dart';
import 'wheel_spinner_screen.dart';
import 'haptic_generator_screen.dart';

import 'widgets/ad_banner_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Random Kit+ Idle',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Choose Your Tool',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withAlpha(230),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Main Content area with vertical scrolling
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Dice Roller - Icon on LEFT
                _buildFeatureButton(
                  context: context,
                  icon: Icons.casino,
                  title: 'Dice Roller',
                  color: Colors.orange,
                  isIconOnLeft: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DiceRollerScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 2. Number Generator - Icon on RIGHT
                _buildFeatureButton(
                  context: context,
                  icon: Icons.numbers,
                  title: 'Number Generator',
                  color: Colors.teal,
                  isIconOnLeft: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NumberGeneratorScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 3. Coin Flipper - Icon on LEFT
                _buildFeatureButton(
                  context: context,
                  icon: Icons.shuffle,
                  title: 'Coin Flip',
                  color: Colors.amber,
                  isIconOnLeft: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CoinFlipperScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 4. Color Mixer - Icon on RIGHT
                _buildFeatureButton(
                  context: context,
                  icon: Icons.color_lens,
                  title: 'Color Mixer',
                  color: Colors.red,
                  isIconOnLeft: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ColorMixerScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 5. Wheel Spinner - Icon on LEFT
                _buildFeatureButton(
                  context: context,
                  icon: Icons.track_changes,
                  title: 'Wheel Spinner',
                  color: Colors.purple,
                  isIconOnLeft: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WheelSpinnerScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 6. Haptic Generator - Icon on RIGHT
                _buildFeatureButton(
                  context: context,
                  icon: Icons.vibration,
                  title: 'Haptic Generator',
                  color: Colors.indigo,
                  isIconOnLeft: false, // RIGHT to follow zigzag pattern
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HapticGeneratorScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Ad Banner at bottom - blue background extends to edge
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                AdBannerWidget(adUnitIdKey: 'ADMOB_BANNER_ID'),
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom > 0
                      ? MediaQuery.of(context).viewPadding.bottom + 8.0
                      : 8.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required bool isIconOnLeft,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha(178), color.withAlpha(153)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: isIconOnLeft
                  ? [
                      // Icon on LEFT
                      Icon(icon, size: 48, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ]
                  : [
                      // Text on LEFT, Icon on RIGHT
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(icon, size: 48, color: Colors.white),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
