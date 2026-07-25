// lib/widgets/memory_game_widgets.dart

import 'package:flutter/material.dart';

// Reusable widgets for Memory Game:
// - GameStatsHeader: Clean Score & High Score top banner
// - LevelBadgeWidget: Bold floating Level badge above the game grid
// - StatusMessageBanner: Prominent turn status banner (Showing Sequence vs Your Turn)
// - StartGameScreen / GameOverDialog

/// Top Stats Header showing Score & Best High Score in high contrast cards
class GameStatsHeader extends StatelessWidget {
  final int score;
  final int highScore;
  final Color primaryColor;

  const GameStatsHeader({
    super.key,
    required this.score,
    required this.highScore,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'SCORE',
            value: '$score',
            icon: Icons.stars_rounded,
            color: Colors.orange.shade700,
            bgGradient: [
              Colors.orange.shade50,
              Colors.orange.shade100.withAlpha(120),
            ],
            borderColor: Colors.orange.shade200,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            label: 'BEST SCORE',
            value: '$highScore',
            icon: Icons.workspace_premium_rounded,
            color: Colors.amber.shade800,
            bgGradient: [
              Colors.amber.shade50,
              Colors.amber.shade100.withAlpha(120),
            ],
            borderColor: Colors.amber.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> bgGradient,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bgGradient),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withAlpha(40), blurRadius: 6)],
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Prominent Level Badge displayed distinctly right above the game board
class LevelBadgeWidget extends StatelessWidget {
  final int level;

  const LevelBadgeWidget({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.indigo.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withAlpha(100),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Text(
            'LEVEL $level',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Prominent Turn & Status Banner displayed prominently above the game board
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(120), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getIconForStatus(color), color: color, size: 24),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStatus(Color color) {
    if (color == Colors.green) return Icons.check_circle_rounded;
    if (color == Colors.red) return Icons.cancel_rounded;
    if (color == Colors.blue) return Icons.visibility_rounded;
    if (color == Colors.orange) return Icons.touch_app_rounded;
    return Icons.info_rounded;
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
      if (!mounted) return;
      setState(() => _currentCount = i);
      _scaleController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (!mounted) return;
    setState(() => _currentCount = 0);
    _scaleController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(170),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            _currentCount > 0 ? '$_currentCount' : 'GO!',
            style: TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: widget.primaryColor.withAlpha(200),
                  blurRadius: 30,
                ),
              ],
            ),
          ),
        ),
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
  final VoidCallback onExit;
  final Color primaryColor;

  const GameOverDialog({
    super.key,
    required this.level,
    required this.score,
    required this.highScore,
    required this.onPlayAgain,
    required this.onExit,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score == highScore && score > 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      elevation: 12,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isNewHighScore ? Colors.amber : Colors.red).withAlpha(
                  30,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNewHighScore
                    ? Icons.emoji_events_rounded
                    : Icons.sentiment_dissatisfied_rounded,
                color: isNewHighScore
                    ? Colors.amber.shade700
                    : Colors.red.shade600,
                size: 52,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isNewHighScore ? 'New High Score!' : 'Game Over!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),

            // Score Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50.withAlpha(150),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200, width: 1.5),
              ),
              child: Column(
                children: [
                  _buildRow('Level Reached', '$level'),
                  const Divider(height: 20),
                  _buildRow('Score', '$score'),
                  const Divider(height: 20),
                  _buildRow('Best Score', '$highScore'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Equal size control buttons: EXIT GAME and PLAY AGAIN (single line text alignment)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: onExit,
                      icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'EXIT GAME',
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: onPlayAgain,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'PLAY AGAIN',
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: primaryColor.withAlpha(140),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
