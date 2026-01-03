// lib/haptic_generator_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import 'haptic_generator_logic.dart';
import 'widgets/base_feature_screen.dart';

class HapticGeneratorScreen extends StatefulWidget {
  const HapticGeneratorScreen({super.key});

  @override
  State<HapticGeneratorScreen> createState() => _HapticGeneratorScreenState();
}

class _HapticGeneratorScreenState extends State<HapticGeneratorScreen>
    with SingleTickerProviderStateMixin {
  String _currentPatternName = 'Tap to Feel!';
  String _currentDescription = 'Generate random vibration patterns';
  bool _hasVibrator = true;
  bool _isVibrating = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkVibrationSupport();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkVibrationSupport() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (mounted) {
      setState(() {
        _hasVibrator = hasVibrator;
      });
      if (!hasVibrator) {
        _showNoVibratorDialog();
      }
    }
  }

  void _showNoVibratorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('No Vibration Support'),
          ],
        ),
        content: const Text(
          'Your device doesn\'t support vibration or it\'s disabled in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerVibration() async {
    if (!_hasVibrator || _isVibrating) return;

    setState(() {
      _isVibrating = true;
    });

    // Animate button press
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Light haptic feedback first
    HapticFeedback.mediumImpact();

    final patternObj = HapticGeneratorLogic.getRandomPattern();

    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(pattern: patternObj.pattern);
        if (mounted) {
          setState(() {
            _currentPatternName = patternObj.name;
            _currentDescription = patternObj.description;
          });
        }

        // Wait for pattern to complete
        final totalDuration = patternObj.pattern.reduce((a, b) => a + b);
        await Future.delayed(Duration(milliseconds: totalDuration + 100));
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isVibrating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Random Kit+ Idle',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              'Haptic Generator',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BaseFeatureScreen(
        adUnitIdKey: 'ADMOB_BANNER_ID_HAPTIC',
        children: [
          const SizedBox(height: 20),

          // Pattern name display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _currentPatternName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),

          // Vibration button with animation
          GestureDetector(
            onTap: _hasVibrator ? _triggerVibration : null,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _hasVibrator
                        ? [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ]
                        : [Colors.grey, Colors.grey[400]!],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _hasVibrator
                          ? Theme.of(context).primaryColor.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isVibrating ? Icons.vibration : Icons.touch_app,
                      size: 80,
                      color: Colors.white,
                    ),
                    if (_isVibrating) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'BUZZING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Instructions
          Text(
            _hasVibrator
                ? 'Tap the circle to generate a random vibration!'
                : 'Vibration not available on this device',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Pattern count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${HapticGeneratorLogic.getTotalPatternsCount()} unique patterns',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
