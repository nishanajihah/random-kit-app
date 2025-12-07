// lib/wheel_spinner_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

import 'wheel_spinner_logic.dart';
import 'widgets/base_feature_screen.dart';

class WheelSpinnerScreen extends StatefulWidget {
  const WheelSpinnerScreen({super.key});

  @override
  State<WheelSpinnerScreen> createState() => _WheelSpinnerScreenState();
}

class _WheelSpinnerScreenState extends State<WheelSpinnerScreen> {
  // Default options
  List<String> _options = ['Pizza', 'Burger', 'Sushi', 'Tacos'];

  // Stream controller for wheel animation
  final StreamController<int> _wheelController = StreamController<int>();

  // Track the winning option
  String? _winner;
  bool _isSpinning = false;

  @override
  void dispose() {
    _wheelController.close();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    if (!WheelSpinnerLogic.hasMinimumOptions(_options)) {
      _showMessage('Need at least 2 options to spin!');
      return;
    }

    // Select random winner
    final winningIndex = WheelSpinnerLogic.selectRandomIndex(_options);

    setState(() {
      _isSpinning = true;
      _winner = null; // Clear previous winner
    });

    // Trigger wheel animation
    _wheelController.add(winningIndex);
  }

  void _onSpinComplete(int winningIndex) {
    // Delay slightly to show the wheel has stopped
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _winner = _options[winningIndex];
          _isSpinning = false;
        });
      }
    });
  }

  void _showEditDialog() {
    final controller = TextEditingController(text: _options.join('\n'));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Options (Max ${WheelSpinnerLogic.maxOptions})',
          style: const TextStyle(fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current: ${_options.length}/${WheelSpinnerLogic.maxOptions}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 10,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText:
                      'Enter one option per line\n\nExample:\nPizza\nBurger\nSushi\nTacos',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final newOptions = WheelSpinnerLogic.parseOptions(
                controller.text,
              );

              if (!WheelSpinnerLogic.hasMinimumOptions(newOptions)) {
                _showMessage(
                  'Need at least ${WheelSpinnerLogic.minOptions} options!',
                );
                return;
              }

              if (!WheelSpinnerLogic.isWithinMaxOptions(newOptions)) {
                _showMessage(
                  'Maximum ${WheelSpinnerLogic.maxOptions} options allowed!',
                );
                return;
              }

              setState(() {
                _options = newOptions;
                _winner = null;
              });

              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<FortuneItem> _buildWheelItems() {
    // Use darker colors that won't clash with red arrow
    final colors = [
      const Color(0xFF1976D2), // Dark Blue
      const Color(0xFF388E3C), // Dark Green
      const Color(0xFFE64A19), // Dark Orange
      const Color(0xFF7B1FA2), // Dark Purple
      const Color(0xFF00796B), // Dark Teal
      const Color(0xFFC2185B), // Dark Pink
      const Color(0xFF303F9F), // Dark Indigo
      const Color(0xFFF57C00), // Dark Amber
      const Color(0xFF0097A7), // Dark Cyan
      const Color(0xFF5D4037), // Brown
    ];

    return _options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final color = colors[index % colors.length];

      return FortuneItem(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            option,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        style: FortuneItemStyle(
          color: color,
          borderWidth: 3,
          borderColor: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              'Wheel Spinner',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BaseFeatureScreen(
        adUnitIdKey: 'ADMOB_BANNER_ID_WHEEL',
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        adBackgroundColor: Theme.of(context).primaryColor,
        children: [
          // The wheel - main focus
          SizedBox(
            height: 300,
            child: FortuneWheel(
              selected: _wheelController.stream,
              items: _buildWheelItems(),
              animateFirst: false,
              indicators: const [
                FortuneIndicator(
                  alignment: Alignment.topCenter,
                  child: TriangleIndicator(
                    color: Color(0xFFD32F2F), // Solid dark red
                    width: 28,
                    height: 28,
                  ),
                ),
              ],
              onAnimationEnd: () {
                // Get the winning index from the last value sent to the stream
                // We need to track this separately
                if (mounted) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_isSpinning && mounted) {
                      final winningIndex = WheelSpinnerLogic.selectRandomIndex(
                        _options,
                      );
                      _onSpinComplete(winningIndex);
                    }
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),

          // Winner display - eye-catching design
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: _winner != null
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withAlpha(178),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade200, Colors.grey.shade300],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _winner != null
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withAlpha(102),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: _isSpinning
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'SPINNING...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    )
                  : _winner != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _winner!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    )
                  : const Text(
                      'TAP SPIN TO START',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons - same height
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSpinning ? null : _spinWheel,
                  icon: Icon(
                    _isSpinning ? Icons.hourglass_empty : Icons.play_arrow,
                    size: 20,
                  ),
                  label: Text(
                    _isSpinning ? 'SPINNING' : 'SPIN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSpinning ? null : _showEditDialog,
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text(
                    'EDIT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: _isSpinning
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Info text
          Text(
            '${_options.length} options • Max ${WheelSpinnerLogic.maxOptions}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
