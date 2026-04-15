// lib/screens/haptic_memory_game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../services/memory_game_engine.dart';
import '../models/memory_game_state.dart';
import '../models/game_item.dart';
import '../logics/haptic_memory_game_logic.dart';
import '../widgets/base_feature_screen.dart';

class HapticMemoryGameScreen extends StatefulWidget {
  const HapticMemoryGameScreen({super.key});

  @override
  State<HapticMemoryGameScreen> createState() => _HapticMemoryGameScreenState();
}

class _HapticMemoryGameScreenState extends State<HapticMemoryGameScreen> {
  late MemoryGameEngine _gameEngine;
  MemoryGameState _gameState = MemoryGameState();
  String? _currentPlayingPatternId;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final availableItems = HapticMemoryGameLogic.getAvailableItems();
    _gameEngine = MemoryGameEngine(availableItems: availableItems);
    setState(() {
      _gameState = _gameEngine.state;
    });
  }

  Future<void> _startGame() async {
    setState(() {
      _gameState = _gameEngine.startNewGame();
    });

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
      await _playHapticItem(item as HapticGameItem);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Now wait for player
    setState(() {
      _gameState = _gameEngine.startPlayerTurn();
    });
  }

  Future<void> _playHapticItem(HapticGameItem item) async {
    setState(() {
      _currentPlayingPatternId = item.id;
    });

    // Vibrate
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: item.vibrationPattern);
    }

    // wait for patter duration
    await Future.delayed(Duration(milliseconds: item.durationMs));

    setState(() {
      _currentPlayingPatternId = null;
    });
  }

  void _onPatternTapped(String patternId) {
    if (_gameState.status != GameStatus.waitingForInput) return;

    // Play the pattern
    final pattern = HapticMemoryGameLogic.getPatternById(patternId);
    if (pattern != null) {
      _playHapticItem(
        HapticGameItem(
          id: patternId,
          displayName: pattern.name,
          vibrationPattern: pattern.pattern,
        ),
      );
    }

    // Update game state
    setState(() {
      _gameState = _gameEngine.playerSelect(patternId);
    });

    // check result
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.sentiment_dissatisfied, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Game Over'),
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
              'PPLAY AGAIN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLevelComplete() async {
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 800));

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
        headerSubtitle: 'Haptic Memory Game 🔒',
        onBackPressed: () => Navigator.of(context).pop(),
        adUnitIdKey: 'ADMOB_BANNER_ID_HAPTIC_GAME',
        children: [
          const SizedBox(height: 20),

          // Game info header
          _buildGameInfo(),
          const SizedBox(height: 30),

          // Pattern grid
          if (_gameState.status == GameStatus.idle)
            _buildStartButton()
          else
            _buildPatternGrid(),

          const SizedBox(height: 30),

          // Status message
          _buildStatusMessage(),

          const SizedBox(height: 20),

          // Hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.indigo[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Feel the vibrations and repeat the pattern!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade100, Colors.purple.shade100],
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
        Icon(icon, color: Colors.indigo[700], size: 24),
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
          backgroundColor: Colors.indigo,
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

  Widget _buildPatternGrid() {
    final patterns = HapticMemoryGameLogic.getAvailableItems();
    final isDisabled = _gameState.status != GameStatus.waitingForInput;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final patternItem = patterns[index];
        final isPlaying = _currentPlayingPatternId == patternItem.id;

        return GestureDetector(
          onTap: isDisabled ? null : () => _onPatternTapped(patternItem.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPlaying
                    ? [Colors.indigo, Colors.purple]
                    : [Colors.indigo.shade300, Colors.purple.shade300],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isPlaying
                      ? Colors.indigo.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: isPlaying ? 20 : 8,
                  spreadRadius: isPlaying ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                patternItem.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
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
