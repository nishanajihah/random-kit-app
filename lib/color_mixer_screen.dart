// lib/color_mixer_screen.dart

import 'package:flutter/material.dart';

import 'color_mixer_logic.dart';
import 'widgets/base_feature_screen.dart';

class ColorMixerScreen extends StatefulWidget {
  const ColorMixerScreen({super.key});

  @override
  State<ColorMixerScreen> createState() => _ColorMixerScreenState();
}

class _ColorMixerScreenState extends State<ColorMixerScreen> {
  Color _currentColor = Colors.white;
  String _currentDisplayValue = '#FFFFFF';
  bool _isDisplayingHex = true;

  @override
  void initState() {
    super.initState();
    _mixColor;
  }

  void _mixColor() {
    final newColor = ColorMixerLogic.generateRandomColor();
    final hex = ColorMixerLogic.colorToHex(newColor);
    final rgb = ColorMixerLogic.colorToRGB(newColor);

    setState(() {
      _currentColor = newColor;
      // Set the display value based on the current toggle state
      _currentDisplayValue = _isDisplayingHex ? hex : rgb;
    });
  }

  void _toggleDisplayFormat() {
    setState(() {
      _isDisplayingHex = !_isDisplayingHex;
      // Update the display string immediately upon toggle
      if (_isDisplayingHex) {
        _currentDisplayValue = ColorMixerLogic.colorToHex(_currentColor);
      } else {
        _currentDisplayValue = ColorMixerLogic.colorToRGB(_currentColor);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentColor,
      extendBodyBehindAppBar: false,
      extendBody: true, //
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
              'Color Mixer',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BaseFeatureScreen(
        adUnitIdKey: 'ADMOB_BANNER_ID_COLOR',
        padding: EdgeInsets.zero,
        adBackgroundColor: Theme.of(context).primaryColor,
        children: [
          const SizedBox(height: 20),
          // Display the HEx/RGB code, wrapped in gesturedetector
          GestureDetector(
            onTap: _toggleDisplayFormat,
            child: Column(
              children: [
                Text(
                  _currentDisplayValue,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: _currentColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isDisplayingHex ? 'Tap to view RGB' : 'Tap to view Hex',
                  style: TextStyle(
                    fontSize: 14,
                    color: _currentColor.computeLuminance() > 0.5
                        ? Colors.black.withAlpha(179)
                        : Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: _mixColor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withAlpha(127),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'MIX COLOR',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
