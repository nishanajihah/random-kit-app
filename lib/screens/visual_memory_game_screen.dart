// lib/screens/visual_memory_game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/memory_game_engine.dart';
import '../models/memory_game_state.dart';
import '../models/game_item.dart';
import '../logics/visual_memory_game_logic.dart';
import '../widgets/base_feature_screen.dart';
import '../widgets/memory_game_widgets.dart';

class VisualMemoryGameScreen extends StatefulWidget {
  const VisualMemoryGameScreen({super.key});

  @override
  State<VisualMemoryGameScreen> createState() => _VisualMemoryGameScreenState();
}

class _VisualMemoryGameScreenState extends State<VisualMemoryGameScreen> {
  late MemoryGameEngine _gameEngine;
  MemoryGameState _gameState = const MemoryGameState();
  String? _currentHighlightedColorId;
  bool _showCountdown = false;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final availableItems = VisualMemoryGameLogic.getAvailableItems();
    _gameEngine = MemoryGameEngine(availableItems: availableItems);
    setState(() {
      _gameState = _gameEngine.state;
    });
  }

  Future<void> _startGame() async {
    setState(() {
      _gameStarted = true;
      _gameState = _gameEngine.startNewGame();
      _showCountdown = true;
    });

    // Wait for countdown to complete
    await Future.delayed(const Duration(milliseconds: 3800));

    setState(() {
      _showCountdown = false;
    });

    await _showNextSequence();
  }

  Future<void> _showNextSequence() async {
    setState(() {
      _gameState = _gameEngine.generateNextSequence();
    });

    // Samll delay before sequence starts
    await Future.delayed(const Duration(milliseconds: 500));

    // Play the sequence
    final items = _gameEngine.getSequenceItems();
    for (final item in items) {
      await _playColorItem(item as ColorGameItem);
      await Future.delayed(
        const Duration(milliseconds: 400),
      ); // Short gap between colors
    }

    // Now wait for player
    setState(() {
      _gameState = _gameEngine.startPlayerTurn();
    });
  }

  Future<void> _playColorItem(ColorGameItem item) async {
    // Highlight the color
    setState(() {
      _currentHighlightedColorId = item.id;
    });

    // Light haptic feedback
    HapticFeedback.mediumImpact();

    // Wait for duration (increased from 800ms to 1000ms for better visibility)
    await Future.delayed(Duration(milliseconds: 1000));

    // Remove highlight
    setState(() {
      _currentHighlightedColorId = null;
    });
  }

  void _onColorTapped(String colorId) {
    if (_gameState.status != GameStatus.waitingForInput) return;

    // Play the color
    final color = VisualMemoryGameLogic.getColorById(colorId);
    if (color != null) {
      _playColorItem(
        ColorGameItem(
          id: colorId,
          displayName: color.name,
          colorValue: color.color.toARGB32(),
          durationMs: 300,
        ),
      );
    }

    // Update game state
    setState(() {
      _gameState = _gameEngine.playerSelect(colorId);
    });

    // Check result
    if (_gameState.status == GameStatus.wrong) {
      _handleGameOver();
    } else if (_gameState.status == GameStatus.correct) {
      _handleLevelComplete();
    }
  }

  void _handleGameOver() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameOverDialog(
        level: _gameState.level,
        score: _gameState.score,
        highScore: _gameState.highScore,
        primaryColor: Colors.purple,
        onPlayAgain: () {
          Navigator.of(ctx).pop();
          _startGame();
        },
      ),
    );
  }

  Future<void> _handleLevelComplete() async {
    HapticFeedback.mediumImpact();

    // Show succes message briefly
    await Future.delayed(const Duration(milliseconds: 1000));

    // Start countdown for next level
    setState(() {
      _showCountdown = true;
    });

    await Future.delayed(const Duration(milliseconds: 3800));

    setState(() {
      _showCountdown = false;
      _gameState = _gameEngine.nextLevel();
    });

    await _showNextSequence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BaseFeatureScreen(
            showHeader: true,
            headerTitle: 'Random Kit+ Idle',
            headerSubtitle: 'Color Memory Game',
            onBackPressed: () => Navigator.of(context).pop(),
            adUnitIdKey: 'ADMOB_BANNER_ID_VISUAL_GAME',
            children: [
              const SizedBox(height: 20),

              // Show start screen or game content
              if (!_gameStarted)
                StartGameScreen(
                  onStart: _startGame,
                  primaryColor: Colors.purple,
                  gameName: 'Color Memory',
                  instructions:
                      'Watch the sequence of colors, then tap them in the same order. Each level adds one more color!',
                )
              else ...[
                // Game stats header (only show when game started)
                GameStatsHeader(
                  level: _gameState.level,
                  score: _gameState.score,
                  highScore: _gameState.highScore,
                  primaryColor: Colors.purple,
                ),
                const SizedBox(height: 30),

                // Color grid
                _buildColorGrid(),
                const SizedBox(height: 30),

                // Status message
                StatusMessageBanner(
                  message: _gameState.message ?? 'Ready',
                  color: _getStatusColor(),
                ),

                const SizedBox(height: 20),

                // Progress indicator
                if (_gameState.status == GameStatus.waitingForInput)
                  _buildProgressIndicator(),
              ],
            ],
          ),

          // Countdown overlay
          if (_showCountdown)
            CountdownOverlay(
              onComplete: () {
                setState(() {
                  _showCountdown = false;
                });
              },
              primaryColor: Colors.purple,
            ),
        ],
      ),
    );
  }

  Widget _buildColorGrid() {
    final colors = VisualMemoryGameLogic.getAvailableItems();
    final isDisabled = _gameState.status != GameStatus.waitingForInput;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final colorItem = colors[index];
        final isHighlighted = _currentHighlightedColorId == colorItem.id;

        return GestureDetector(
          onTap: isDisabled ? null : () => _onColorTapped(colorItem.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Color(colorItem.colorValue),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHighlighted ? Colors.white : Colors.grey.shade300,
                width: isHighlighted ? 6 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHighlighted
                      ? Colors.white
                      : Colors.black.withValues(alpha: 0.15),
                  blurRadius: isHighlighted ? 30 : 8,
                  spreadRadius: isHighlighted ? 8 : 0,
                ),
                if (isHighlighted)
                  BoxShadow(
                    color: Color(colorItem.colorValue),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
              ],
            ),
            // Pulsing animation when highlighted
            transform: isHighlighted
                ? Matrix4.diagonal3Values(1.1, 1.1, 1.0) // X, Y, Z
                : Matrix4.identity(),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Text(
          'Progress: ${_gameState.playerInput.length}/${_gameState.sequence.length}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _gameState.progress,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_gameState.status) {
      case GameStatus.correct:
        return Colors.green;
      case GameStatus.wrong:
        return Colors.red;
      case GameStatus.showingSequence:
        return Colors.blue;
      case GameStatus.waitingForInput:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
