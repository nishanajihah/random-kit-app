// lib/screens/tic_tac_toe_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logics/tic_tac_toe_logic.dart';
import '../widgets/base_feature_screen.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  late TicTacToeLogic _game;
  bool _isAiThinking = false;

  static const Color _brandOrange = Color(0xFFF4750A);

  @override
  void initState() {
    super.initState();
    _game = TicTacToeLogic(mode: TicTacToeMode.singlePlayer);
  }

  void _onCellTapped(int index) {
    if (_isAiThinking || _game.isGameOver || _game.board[index].isNotEmpty) {
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _game.makeMove(index);
    });

    if (_game.isGameOver) {
      HapticFeedback.heavyImpact();
      return;
    }

    if (_game.mode == TicTacToeMode.singlePlayer &&
        _game.currentPlayer == 'O') {
      _triggerAiMove();
    }
  }

  void _triggerAiMove() {
    setState(() {
      _isAiThinking = true;
    });

    Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      final aiIndex = _game.getAiMove();
      if (aiIndex != -1) {
        HapticFeedback.lightImpact();
        setState(() {
          _game.makeMove(aiIndex);
          _isAiThinking = false;
        });

        if (_game.isGameOver) {
          HapticFeedback.heavyImpact();
        }
      } else {
        setState(() {
          _isAiThinking = false;
        });
      }
    });
  }

  void _switchMode(TicTacToeMode newMode) {
    HapticFeedback.mediumImpact();
    setState(() {
      _game.setGameMode(newMode);
      _isAiThinking = false;
    });
  }

  void _resetRound() {
    HapticFeedback.mediumImpact();
    setState(() {
      _game.resetBoard(switchStartingPlayer: true);
      _isAiThinking = false;
    });

    if (_game.mode == TicTacToeMode.singlePlayer &&
        _game.currentPlayer == 'O') {
      _triggerAiMove();
    }
  }

  void _resetAll() {
    HapticFeedback.heavyImpact();
    setState(() {
      _game.resetScores();
      _isAiThinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseFeatureScreen(
        adUnitIdKey: 'ADMOB_BANNER_ID_TIC_TAC_TOE',
        showHeader: true,
        headerTitle: 'Tic Tac Toe',
        headerSubtitle: 'Classic X & O Game',
        onBackPressed: () => Navigator.pop(context),
        children: [
          const SizedBox(height: 6),

          // 1. Mode Selector Toggle (Brand Orange Theme)
          _buildModeSelector(),
          const SizedBox(height: 16),

          // 2. Scoreboard Cards (Prominent 3-Card Header)
          _buildScoreboard(),
          const SizedBox(height: 16),

          // 3. Status Indicator Banner (Large & High Contrast)
          _buildStatusBanner(),
          const SizedBox(height: 16),

          // 4. Responsive 3x3 Game Board
          _buildGameBoard(),
          const SizedBox(height: 16),

          // 5. Control Buttons (Enlarged Brand Orange Theme)
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _brandOrange.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            title: 'VS AI',
            icon: Icons.smart_toy_rounded,
            isSelected: _game.mode == TicTacToeMode.singlePlayer,
            onTap: () => _switchMode(TicTacToeMode.singlePlayer),
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            title: '2 PLAYERS',
            icon: Icons.people_alt_rounded,
            isSelected: _game.mode == TicTacToeMode.twoPlayer,
            onTap: () => _switchMode(TicTacToeMode.twoPlayer),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? _brandOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brandOrange.withAlpha(100),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.6,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            label: 'PLAYER X',
            score: '${_game.xWins}',
            color: Colors.blue.shade700,
            bgGradient: [Colors.blue.shade50, Colors.blue.shade100.withAlpha(120)],
            borderColor: Colors.blue.shade200,
            icon: Icons.close_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildScoreCard(
            label: 'DRAWS',
            score: '${_game.draws}',
            color: Colors.grey.shade700,
            bgGradient: [Colors.grey.shade100, Colors.grey.shade200.withAlpha(120)],
            borderColor: Colors.grey.shade300,
            icon: Icons.drag_handle_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildScoreCard(
            label: _game.mode == TicTacToeMode.singlePlayer ? 'AI (O)' : 'PLAYER O',
            score: '${_game.oWins}',
            color: _brandOrange,
            bgGradient: [Colors.orange.shade50, Colors.orange.shade100.withAlpha(120)],
            borderColor: Colors.orange.shade300,
            icon: Icons.panorama_fish_eye_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard({
    required String label,
    required String score,
    required Color color,
    required List<Color> bgGradient,
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bgGradient),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (_game.winner == 'X') {
      statusText = 'Player X Wins!';
      statusColor = Colors.blue.shade700;
      statusIcon = Icons.emoji_events_rounded;
    } else if (_game.winner == 'O') {
      statusText = _game.mode == TicTacToeMode.singlePlayer
          ? 'AI Wins!'
          : 'Player O Wins!';
      statusColor = _brandOrange;
      statusIcon = Icons.emoji_events_rounded;
    } else if (_game.winner == 'Draw') {
      statusText = "It's a Draw!";
      statusColor = Colors.grey.shade800;
      statusIcon = Icons.handshake_rounded;
    } else if (_isAiThinking) {
      statusText = 'AI is thinking...';
      statusColor = _brandOrange;
      statusIcon = Icons.smart_toy_rounded;
    } else {
      statusText = "Player ${_game.currentPlayer}'s Turn";
      statusColor = _game.currentPlayer == 'X'
          ? Colors.blue.shade700
          : _brandOrange;
      statusIcon = _game.currentPlayer == 'X'
          ? Icons.close_rounded
          : Icons.panorama_fish_eye_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(120), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: statusColor.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 10),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: statusColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = (constraints.maxWidth * 0.85).clamp(240.0, 280.0);

        return Container(
          width: boardSize,
          height: boardSize,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.orange.shade200, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: _brandOrange.withAlpha(40),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => _buildGridCell(index, boardSize),
          ),
        );
      },
    );
  }

  Widget _buildGridCell(int index, double boardSize) {
    final value = _game.board[index];
    final isWinningCell = _game.winningLine?.contains(index) ?? false;
    final iconSize = boardSize * 0.16;

    Color cellColor = Colors.orange.shade50.withAlpha(140);
    if (isWinningCell) {
      cellColor = value == 'X'
          ? Colors.blue.shade100
          : Colors.orange.shade200;
    }

    return GestureDetector(
      onTap: () => _onCellTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isWinningCell
                ? (value == 'X' ? Colors.blue.shade700 : _brandOrange)
                : Colors.orange.shade100,
            width: isWinningCell ? 3.5 : 1.8,
          ),
          boxShadow: isWinningCell
              ? [
                  BoxShadow(
                    color: (value == 'X' ? Colors.blue.shade700 : _brandOrange)
                        .withAlpha(120),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: value.isEmpty
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : Icon(
                    value == 'X' ? Icons.close_rounded : Icons.panorama_fish_eye_rounded,
                    key: ValueKey('$index-$value'),
                    size: iconSize,
                    color: value == 'X' ? Colors.blue.shade700 : _brandOrange,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _resetRound,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
          label: Text(
            _game.isGameOver ? 'PLAY AGAIN' : 'NEXT ROUND',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 6,
            shadowColor: _brandOrange.withAlpha(140),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.orange.shade200, width: 1.8),
            boxShadow: [
              BoxShadow(
                color: _brandOrange.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _resetAll,
            tooltip: 'Reset Score',
            icon: const Icon(Icons.restart_alt_rounded, color: _brandOrange, size: 28),
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}
