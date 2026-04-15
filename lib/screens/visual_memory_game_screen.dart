// lib/screens/visual_memory_game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_kit_app/models/memory_game_state.dart';

import '../services/memory_game_engine.dart';
import '../models/memory_game_state.dart';
import '../models/game_item.dart';
import '../logics/visual_memory_game_logic.dart';
import '../widgets/base_feature_screen.dart';

class VisualMemoryGameScreen extends StatefulWidget {
  const VisualMemoryGameScreen({super.key});

  @override
  State<VisualMemoryGameScreen> createState() => _VisualMemoryGameScreenState();
}

class _VisualMemoryGameScreenState extends State<VisualMemoryGameScreen> {
  late MemoryGameEngine _gameEngine;
  MemoryGameState _gameState = const MemoryGameState();
  String? _currentHighlightedColorId;

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
      _gameState = _gameEngine.startNewGame();
    });

    // Small delay before showing first sequence
    await Future.delayed(const Duration(milliseconds: 500));
    await _showNextSequence();
  }

  Future<void> _showNextSequence() async {
    setState(() {
      _gameState = _gameEngine.generateNextSequence();
    });

    // Play the sequence
    final items = _gameEngine.getSequenceItems();
    for (final item in items) {
      await _playColorItem(item as ColorGameItem);
      await Future.delayed(
        const Duration(milliseconds: 300),
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
    HapticFeedback.lightImpact();

    // Wait for duration
    await Future.delayed(Duration(milliseconds: item.durationMs));

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
          durationMs: 400,
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.sentiment_dissatisfied, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Game Over!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Level Reached: ${_gameState.level}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${_gameState.score}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'High Score: ${_gameState.highScore}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _startGame();
            },
            child: const Text(
              'PLAY AGAIN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLevelComplete() async {
    HapticFeedback.mediumImpact();

    // Show succes message briefly
    await Future.delayed(const Duration(milliseconds: 800));

    // Advance to next level
    await _showNextSequence();
    setState(() {
      _gameState = _gameEngine.nextLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseFeatureScreen(
        showHeader: true,
        headerTitle: 'Random Kit+ Idle',
        headerSubtitle: 'Color Memory Game',
        onBackPressed: () => Navigator.of(context).pop(),
        adUnitIdKey: 'ADMOB_BANNER_ID_VISUAL_GAME',
        children: [
          const SizedBox(height: 20),

          // Game info header
          _buildGameInfo(),
          const SizedBox(height: 30),

          // Color grid
          if (_gameState.status == GameStatus.idle)
            _buildStartButton()
          else
            _buildColorGrid(),

          const SizedBox(height: 30),

          // Status message
          _buildStatusMessage(),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Level', '${_gameState.level}', Icons.emoji_events),
          _buildStatItem('Score', '${_gameState.score}', Icons.stars),
          _buildStatItem(
            'Best',
            '${_gameState.highScore}',
            Icons.workspace_premium,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple[700], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'START GAME',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighlighted ? Colors.white : Colors.transparent,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHighlighted
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: isHighlighted ? 20 : 8,
                  spreadRadius: isHighlighted ? 4 : 0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withValues(alpha: 0.3)),
      ),
      child: Text(
        _gameState.message ?? 'Ready',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
        textAlign: TextAlign.center,
      ),
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
