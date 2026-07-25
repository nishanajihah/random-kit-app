// lib/screens/visual_memory_game_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/memory_game_engine.dart';
import '../services/high_score_service.dart';
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
    _loadStoredHighScore();
  }

  Future<void> _loadStoredHighScore() async {
    final storedHigh = await HighScoreService.getColorMemoryHighScore();
    _initializeGameForLevel(1);
    setState(() {
      _gameState = _gameEngine.state.copyWith(highScore: storedHigh);
    });
  }

  void _initializeGameForLevel(int level) {
    final currentHigh = _gameState.highScore;
    final availableItems = VisualMemoryGameLogic.getAvailableItemsForLevel(level);
    _gameEngine = MemoryGameEngine(availableItems: availableItems);
    _gameEngine.restoreState(
      level: level,
      score: level == 1 ? 0 : _gameState.score,
      highScore: currentHigh,
      sequence: level == 1 ? [] : _gameState.sequence,
    );
    setState(() {
      _gameState = _gameEngine.state;
    });
  }

  Future<void> _startGame() async {
    final currentHigh = await HighScoreService.getColorMemoryHighScore();
    setState(() {
      _gameStarted = true;
      _initializeGameForLevel(1);
      _gameState = _gameEngine.startNewGame().copyWith(highScore: currentHigh);
      _showCountdown = true;
    });

    await Future.delayed(const Duration(milliseconds: 3800));

    if (!mounted || !_gameStarted) return;
    setState(() {
      _showCountdown = false;
    });

    await _showNextSequence();
  }

  Future<void> _showNextSequence() async {
    if (!mounted || !_gameStarted) return;
    setState(() {
      _gameState = _gameEngine.generateNextSequence();
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final items = _gameEngine.getSequenceItems();
    for (final item in items) {
      if (!mounted || !_gameStarted) return;
      await _playColorItem(item as ColorGameItem);
      await Future.delayed(const Duration(milliseconds: 350));
    }

    if (!mounted || !_gameStarted) return;
    setState(() {
      _gameState = _gameEngine.startPlayerTurn();
    });
  }

  Future<void> _playColorItem(ColorGameItem item) async {
    if (!mounted) return;
    setState(() {
      _currentHighlightedColorId = item.id;
    });

    HapticFeedback.selectionClick();

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _currentHighlightedColorId = null;
    });
  }

  void _onColorTapped(String colorId) {
    if (_gameState.status != GameStatus.waitingForInput) return;

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

    setState(() {
      _gameState = _gameEngine.playerSelect(colorId);
    });

    if (_gameState.status == GameStatus.wrong) {
      _handleGameOver();
    } else if (_gameState.status == GameStatus.correct) {
      _handleLevelComplete();
    }
  }

  Future<void> _handleGameOver() async {
    HapticFeedback.heavyImpact();

    // Persist new high score if achieved
    final savedHigh = await HighScoreService.saveColorMemoryHighScore(_gameState.score);
    if (mounted) {
      setState(() {
        _gameState = _gameState.copyWith(
          highScore: savedHigh > _gameState.highScore ? savedHigh : _gameState.highScore,
        );
      });
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameOverDialog(
        level: _gameState.level,
        score: _gameState.score,
        highScore: _gameState.highScore,
        primaryColor: Colors.orange,
        onPlayAgain: () {
          Navigator.of(ctx).pop();
          _startGame();
        },
        onExit: () {
          Navigator.of(ctx).pop();
          setState(() {
            _gameStarted = false;
            _currentHighlightedColorId = null;
          });
        },
      ),
    );
  }

  Future<void> _handleLevelComplete() async {
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      _showCountdown = true;
    });

    await Future.delayed(const Duration(milliseconds: 3800));

    if (!mounted) return;

    final currentSeq = _gameState.sequence;
    final currentScore = _gameState.score;
    final currentHighScore = _gameState.highScore;
    final nextLevelNum = _gameState.level + 1;

    final availableItems = VisualMemoryGameLogic.getAvailableItemsForLevel(
      nextLevelNum,
    );
    _gameEngine = MemoryGameEngine(availableItems: availableItems);
    _gameEngine.restoreState(
      level: nextLevelNum,
      score: currentScore,
      highScore: currentHighScore,
      sequence: currentSeq,
    );

    setState(() {
      _showCountdown = false;
      _gameState = _gameEngine.generateNextSequence();
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
            adUnitIdKey: 'ADMOB_BANNER_ID_MEMORY',
            children: [
              const SizedBox(height: 12),

              // SECTION 1: Top Stats Banner (SCORE & BEST SCORE)
              GameStatsHeader(
                score: _gameState.score,
                highScore: _gameState.highScore,
                primaryColor: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Main Game Stack (Grid, Level Badge, Status Banner & Start Overlay)
              Stack(
                children: [
                  Column(
                    children: [
                      // SECTION 2: Dedicated Turn & Status Banner
                      SizedBox(
                        height: 56,
                        child: Center(
                          child: StatusMessageBanner(
                            message: _gameState.message ?? 'Ready to Play',
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // SECTION 3: Floating Level Badge + Color Grid
                      Center(child: LevelBadgeWidget(level: _gameState.level)),
                      const SizedBox(height: 14),

                      _buildColorGrid(),
                      const SizedBox(height: 18),

                      // SECTION 4: Always-present Progress Section (MEMORIZE ORDER)
                      SizedBox(
                        height: 56,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity:
                              _gameState.status == GameStatus.waitingForInput
                              ? 1.0
                              : 0.0,
                          child: _buildProgressIndicator(),
                        ),
                      ),
                    ],
                  ),

                  // Glassmorphism blurred Start Game overlay with Orange Theme
                  if (!_gameStarted)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            color: Colors.white.withAlpha(180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Orange Theme Memory Logo Badge (tappable to start game)
                                  GestureDetector(
                                    onTap: _startGame,
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFF4750A),
                                            Color(0xFFE65100),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFF4750A).withAlpha(140),
                                            blurRadius: 28,
                                            spreadRadius: 4,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.psychology_rounded,
                                        size: 58,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Color Memory',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Watch the sequence of glowing colors, then tap them in the exact same order! Starts with 4 colors and expands to 9 colors.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[850],
                                      height: 1.6,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Orange Theme START GAME Button
                                  ElevatedButton.icon(
                                    onPressed: _startGame,
                                    icon: const Icon(
                                      Icons.play_circle_filled_rounded,
                                      size: 28,
                                    ),
                                    label: const Text(
                                      'START GAME',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF4750A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 46,
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 12,
                                      shadowColor: const Color(0xFFF4750A).withAlpha(160),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (_showCountdown)
            CountdownOverlay(
              onComplete: () {
                if (mounted) {
                  setState(() {
                    _showCountdown = false;
                  });
                }
              },
              primaryColor: const Color(0xFFF4750A),
            ),
        ],
      ),
    );
  }

  Widget _buildColorGrid() {
    final colors = VisualMemoryGameLogic.getAvailableItemsForLevel(
      _gameState.level,
    );
    final isDisabled = _gameState.status != GameStatus.waitingForInput;
    final count = colors.length;
    final crossAxisCount = count <= 4 ? 2 : 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Grid sizing adjusted to ensure 2 rows (6 items) & 3 rows (9 items) fit inside 310px
        final gridWidth = count <= 4
            ? (constraints.maxWidth * 0.90).clamp(270.0, 300.0)
            : (count <= 6
                ? (constraints.maxWidth * 0.90).clamp(280.0, 300.0)
                : (constraints.maxWidth * 0.92).clamp(280.0, 295.0));

        final itemWidth =
            (gridWidth - (10 * (crossAxisCount - 1))) / crossAxisCount;

        return SizedBox(
          height: 310,
          width: gridWidth,
          child: Center(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              clipBehavior: Clip.none,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0, // Perfect square boxes
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final colorItem = colors[index];
                final isHighlighted = _currentHighlightedColorId == colorItem.id;
                final baseColor = Color(colorItem.colorValue);

                return GestureDetector(
                  onTap: isDisabled ? null : () => _onColorTapped(colorItem.id),
                  child: AnimatedScale(
                    scale: isHighlighted ? 1.06 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            isHighlighted
                                ? Colors.white
                                : baseColor.withAlpha(240),
                            baseColor,
                          ],
                          radius: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              isHighlighted
                                  ? Colors.white
                                  : Colors.white.withAlpha(120),
                          width: isHighlighted ? 4 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isHighlighted
                                    ? baseColor.withAlpha(200)
                                    : baseColor.withAlpha(80),
                            blurRadius: isHighlighted ? 24 : 10,
                            spreadRadius: isHighlighted ? 5 : 1,
                            offset:
                                isHighlighted
                                    ? const Offset(0, 0)
                                    : const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: itemWidth * 0.26,
                          height: itemWidth * 0.26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isHighlighted
                                    ? baseColor
                                    : Colors.white.withAlpha(60),
                            boxShadow:
                                isHighlighted
                                    ? [
                                      BoxShadow(
                                        color: Colors.white.withAlpha(200),
                                        blurRadius: 10,
                                      ),
                                    ]
                                    : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MEMORIZE ORDER',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFF4750A),
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF4750A).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF4750A).withAlpha(100),
                  width: 1.5,
                ),
              ),
              child: Text(
                '${_gameState.playerInput.length}/${_gameState.sequence.length}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF4750A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: _gameState.progress,
            minHeight: 14, // Thicker bar line
            backgroundColor: const Color(0xFFF4750A).withAlpha(35),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF4750A)),
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
        return const Color(0xFFF4750A);
      default:
        return Colors.grey;
    }
  }
}
