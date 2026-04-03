// lib/home_screen.dart

import 'package:flutter/material.dart';

// Note: The new screens we will create/modify
import 'dice_roller_screen.dart';
import 'number_generator_screen.dart';
import 'coin_flipper_screen.dart';
import 'color_mixer_screen.dart';
import 'wheel_spinner_screen.dart';
import 'haptic_generator_screen.dart';
import 'settings_screen.dart';

import 'widgets/ad_banner_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade300,
              Colors.orange.shade200,
              Colors.orange.shade50,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Only wrap the top content in SafeArea
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Modern glass app bar
                    _buildGlassAppBar(context),

                    // Main Content with modern cards
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12.0,
                        ),
                        children: [
                          // Modern feature cards
                          _buildModernFeatureCard(
                            context: context,
                            icon: Icons.casino,
                            title: 'Dice Roller',
                            subtitle: 'Roll the dice',
                            color: Colors.orange,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DiceRollerScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildModernFeatureCard(
                            context: context,
                            icon: Icons.numbers,
                            title: 'Number Generator',
                            subtitle: 'Random numbers',
                            color: Colors.teal,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NumberGeneratorScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildModernFeatureCard(
                            context: context,
                            icon: Icons.shuffle,
                            title: 'Coin Flip',
                            subtitle: 'Heads or tails',
                            color: Colors.amber,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CoinFlipperScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildModernFeatureCard(
                            context: context,
                            icon: Icons.color_lens,
                            title: 'Color Mixer',
                            subtitle: 'Random colors',
                            color: Colors.red,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ColorMixerScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildModernFeatureCard(
                            context: context,
                            icon: Icons.track_changes,
                            title: 'Wheel Spinner',
                            subtitle: 'Spin to decide',
                            color: Colors.purple,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WheelSpinnerScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildModernFeatureCard(
                            context: context,
                            icon: Icons.vibration,
                            title: 'Haptic Generator',
                            subtitle: 'Feel the buzz',
                            color: Colors.indigo,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HapticGeneratorScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Modern glass ad banner
                    _buildGlassAdBanner(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern glassmorphism app bar
  Widget _buildGlassAppBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Random Kit+ Idle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Choose Your Tool',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.settings, color: Colors.orange[700], size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // Modern feature card (kept the same as you liked it)
  Widget _buildModernFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(243),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(38),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: color.withAlpha(51),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withAlpha(179)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(102),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Improved ad banner with better positioning
  Widget _buildGlassAdBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Match the bottom part of the screen gradient
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.shade100.withOpacity(0.5),
            Colors.orange.shade50,
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const AdBannerWidget(adUnitIdKey: 'ADMOB_BANNER_ID'),
          SizedBox(
            height: MediaQuery.of(context).viewPadding.bottom > 0
                ? MediaQuery.of(context).viewPadding.bottom
                : 8.0,
          ),
        ],
      ),
    );
  }
}
