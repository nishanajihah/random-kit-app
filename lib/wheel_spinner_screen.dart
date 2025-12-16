// lib/wheel_spinner_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

import 'utils/app_logger.dart';
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

  // Stream controller for wheel animation - BROADCAST to allow multiple listeners
  final StreamController<int> _wheelController =
      StreamController<int>.broadcast();

  // Track the winning option and index
  String? _winner;
  int? _winningIndex;
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

    // Select random winner ONCE
    final winningIndex = WheelSpinnerLogic.selectRandomIndex(_options);

    AppLogger.debug('Selected winning index: $winningIndex');
    AppLogger.debug('Winner will be: ${_options[winningIndex]}');

    setState(() {
      _isSpinning = true;
      _winner = null;
      _winningIndex = winningIndex;
    });

    // Trigger wheel animation to this specific index
    _wheelController.add(winningIndex);

    // FALLBACK: In case onAnimationEnd doesn't fire
    Future.delayed(const Duration(seconds: 6), () {
      if (_isSpinning && mounted) {
        AppLogger.debug('Fallback triggered - showing winner');
        _onSpinComplete();
      }
    });
  }

  void _onSpinComplete() {
    AppLogger.debug('onSpinComplete called');
    AppLogger.debug('Winning index: $_winningIndex');

    if (_winningIndex != null && mounted) {
      setState(() {
        _winner = _options[_winningIndex!];
        _isSpinning = false;
        AppLogger.debug('Winner displayed: $_winner');
      });
    }
  }

  void _showEditDialog() {
    // Create a temporary copy to work with
    List<String> tempOptions = List.from(_options);
    final addController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Options', style: const TextStyle(fontSize: 18)),
                Text(
                  '${tempOptions.length}/${WheelSpinnerLogic.maxOptions}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // Add new option input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: addController,
                          decoration: const InputDecoration(
                            hintText: 'Add new option...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty &&
                                tempOptions.length <
                                    WheelSpinnerLogic.maxOptions) {
                              setDialogState(() {
                                tempOptions.add(value.trim());
                                addController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (addController.text.trim().isNotEmpty &&
                              tempOptions.length <
                                  WheelSpinnerLogic.maxOptions) {
                            setDialogState(() {
                              tempOptions.add(addController.text.trim());
                              addController.clear();
                            });
                          } else if (tempOptions.length >=
                              WheelSpinnerLogic.maxOptions) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Maximum ${WheelSpinnerLogic.maxOptions} options!',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).primaryColor,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // List of current options
                  Expanded(
                    child: tempOptions.isEmpty
                        ? Center(
                            child: Text(
                              'No options yet.\nAdd at least 2 to continue.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: tempOptions.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    tempOptions[index],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setDialogState(() {
                                        tempOptions.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!WheelSpinnerLogic.hasMinimumOptions(tempOptions)) {
                    // Show dialog instead of snackbar
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            const Text('Not Enough Options'),
                          ],
                        ),
                        content: Text(
                          'You need at least ${WheelSpinnerLogic.minOptions} options to spin the wheel.\n\nPlease add ${WheelSpinnerLogic.minOptions - tempOptions.length} more option(s).',
                          style: const TextStyle(fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _options = tempOptions;
                    _winner = null;
                    _winningIndex = null;
                  });

                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('SAVE'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<FortuneItem> _buildWheelItems() {
    // Use darker, vibrant colors that contrast well with red arrow
    final colors = [
      const Color(0xFF1565C0), // Deep Blue
      const Color(0xFF2E7D32), // Forest Green
      const Color(0xFFD84315), // Deep Orange
      const Color(0xFF6A1B9A), // Deep Purple
      const Color(0xFF00695C), // Teal
      const Color(0xFFC2185B), // Pink
      const Color(0xFF283593), // Indigo
      const Color(0xFFEF6C00), // Orange
      const Color(0xFF00838F), // Cyan
      const Color(0xFF4E342E), // Brown
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
              key: ValueKey(
                '${_options.length}-${_options.join(',')}',
              ), // Force rebuild when options change
              selected: _wheelController.stream,
              items: _buildWheelItems(),
              animateFirst: false,
              indicators: const [
                FortuneIndicator(
                  alignment: Alignment.topCenter,
                  child: TriangleIndicator(
                    color: Color(0xFFFF1744), // Bright red for visibility
                    width: 28,
                    height: 28,
                  ),
                ),
              ],
              onAnimationEnd: _onSpinComplete,
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
                        Theme.of(context).primaryColor.withAlpha(200),
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
                  ? const Row(
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
                        SizedBox(width: 12),
                        Text(
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

          // Action buttons
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
