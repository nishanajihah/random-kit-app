// lib/widgets/memory_game_widgets.dart

import 'package:flutter/material.dart';

// Reusable widget for memory game
// - GameStatsHeader - Stats display
// - StartGameScreen - Pre-game screen
// - CountdownOverlay - 3-2-1 countdown
// - StatusMessageBanner - Status messages
// - GameOverDialog - End screen with high score

// Game stats header (Level, Score, High Score)
class GameStatsHeader extends StatelessWidget {
  final int level;
  final int score;
  final int highScore;
  final Color primaryColor;

  const GameStatsHeader({
    super.key,
    required this.level,
    required this.score,
    required this.highScore,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.2),
            primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Level', '$level', Icons.emoji_events, primaryColor),
          _buildStatItem('Score', '$score', Icons.stars, primaryColor),
          _buildStatItem(
            'High Score',
            '$highScore',
            Icons.workspace_premium,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.8), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// Start game screen (before game begins)
class StartGameScreen extends StatelessWidget {
  final VoidCallback onStart;
  final Color primaryColor;
  final String gameName;
  final String instructions;

  const StartGameScreen({
    super.key,
    required this.onStart,
    required this.primaryColor,
    required this.gameName,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.play_arrow, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            gameName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              instructions,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
            child: const Text(
              'START GAME',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Countdown overlay (3, 2, 1, GO!)
class CountdownOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final Color primaryColor;

  const CountdownOverlay({
    super.key,
    required this.onComplete,
    required this.primaryColor,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  int _currentCount = 3;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _startCountdown();
  }

  Future<void> _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      setState(() => _currentCount = i);
      _scaleController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    // Show "GO!"
    setState(() => _currentCount = 0);
    _scaleController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 600));

    widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            _currentCount > 0 ? '$_currentCount' : 'GO!',
            style: TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.bold,
              color: widget.primaryColor,
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Status message banner
class StatusMessageBanner extends StatelessWidget {
  final String message;
  final Color color;

  const StatusMessageBanner({
    super.key,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Game over dialog
class GameOverDialog extends StatelessWidget {
  final int level;
  final int score;
  final int highScore;
  final VoidCallback onPlayAgain;
  final Color primaryColor;

  const GameOverDialog({
    super.key,
    required this.level,
    required this.score,
    required this.highScore,
    required this.onPlayAgain,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score == highScore && score > 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(
            isNewHighScore ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: isNewHighScore ? Colors.amber : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(isNewHighScore ? 'New High Score!' : 'Game Over!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isNewHighScore) ...[
            const Icon(Icons.star, color: Colors.amber, size: 60),
            const SizedBox(height: 16),
          ],
          Text(
            'Level Reached: $level',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Score: $score', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'High Score: $highScore',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onPlayAgain,
          style: TextButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'PLAY AGAIN',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
