// lib/home_screen.dart

import 'package:flutter/material.dart';

// Note: The new screens we will create/modify
import 'dice_roller_screen.dart';
import 'number_generator_screen.dart';
import 'coin_flipper_screen.dart';
import 'widgets/ad_banner_widget.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dynamic AppBar that changes based on selected screen
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Random Kit+ Idle',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
      ),

      body: Column(
        children: [
          // Main Content area
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo or Title
                    Icon(
                      Icons.casino,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose Your Tool',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Feature Button Grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        // Go to Dice Roller
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.casino,
                          title: 'Dice Roller',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DiceRollerScreen(),
                              ),
                            );
                          },
                        ),
                        //  Go to Number Generator
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.numbers,
                          title: 'Number\nGenerator',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NumberGeneratorScreen(),
                              ),
                            );
                          },
                        ),
                        // Go to Coin Flipper
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.shuffle,
                          title: 'Coin Flip',
                          color: Colors.amber,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CoinFlipperScreen(),
                              ),
                            );
                          },
                        ),
                        // _buildFeatureCard(
                        //   context: context,
                        //   icon: Icons.style,
                        //   title: 'Card Draw',
                        //   color: Colors.red,
                        //   onTap: () {},
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Ad Banner at bottom
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: AdBannerWidget(adUnitIdKey: 'ADMOB_BANNER_ID'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha(178), color.withAlpha(153)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
