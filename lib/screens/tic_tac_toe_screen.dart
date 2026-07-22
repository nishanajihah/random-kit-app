// lib/screens/tic_tac_toe_screen.dart

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

  @override
  void initState() {
    super.initState();
    _game = TicTacToeLogic(mode: TicTacToeMode.singlePlayer);
  }

  void _onCellTapped(int index) async {
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

    // AI Turn in Single Player mode
    if (_game.mode == TicTacToeMode.singlePlayer && _game.currentPlayer == 'O') {
      setState(() {
        _isAiThinking = true;
      });

      await Future.delayed(const Duration(milliseconds: 400));

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
    }
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

    // If AI starts first in Single Player mode
    if (_game.mode == TicTacToeMode.singlePlayer && _game.currentPlayer == 'O') {
      _triggerAiMove();
    }
  }

  void _triggerAiMove() async {
    setState(() {
      _isAiThinking = true;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final aiIndex = _game.getAiMove();
    if (aiIndex != -1) {
      HapticFeedback.lightImpact();
      setState(() {
        _game.makeMove(aiIndex);
        _isAiThinking = false;
      });
    } else {
      setState(() {
        _isAiThinking = false;
      });
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
    return BaseFeatureScreen(
      adUnitIdKey: 'ADMOB_BANNER_ID_TIC_TAC_TOE',
      showHeader: true,
      headerTitle: 'Tic Tac Toe',
      headerSubtitle: 'Classic X & O game',
      onBackPressed: () => Navigator.pop(context),
      children: [
        // Mode Selector Toggle
        _buildModeSelector(),
        const SizedBox(height: 16),

        // Scoreboard
        _buildScoreboard(),
        const SizedBox(height: 20),

        // Status Indicator Banner
        _buildStatusBanner(),
        const SizedBox(height: 20),

        // 3x3 Game Board
        _buildGameBoard(),
        const SizedBox(height: 24),

        // Control Buttons
        _buildControlButtons(),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            title: 'vs AI',
            icon: Icons.smart_toy_outlined,
            isSelected: _game.mode == TicTacToeMode.singlePlayer,
            onTap: () => _switchMode(TicTacToeMode.singlePlayer),
          ),
          _buildModeButton(
            title: '2 Players',
            icon: Icons.people_outline,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withAlpha(76),
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
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(30),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('Player X', '${_game.xWins}', Colors.indigo),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          _buildScoreItem('Draws', '${_game.draws}', Colors.grey.shade700),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          _buildScoreItem(
            _game.mode == TicTacToeMode.singlePlayer ? 'AI (O)' : 'Player O',
            '${_game.oWins}',
            Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (_game.winner == 'X') {
      statusText = 'Player X Wins!';
      statusColor = Colors.indigo;
      statusIcon = Icons.emoji_events;
    } else if (_game.winner == 'O') {
      statusText = _game.mode == TicTacToeMode.singlePlayer
          ? 'AI Wins!'
          : 'Player O Wins!';
      statusColor = Colors.deepOrange;
      statusIcon = Icons.emoji_events;
    } else if (_game.winner == 'Draw') {
      statusText = "It's a Draw!";
      statusColor = Colors.grey.shade800;
      statusIcon = Icons.handshake;
    } else if (_isAiThinking) {
      statusText = 'AI is thinking...';
      statusColor = Colors.deepOrange;
      statusIcon = Icons.smart_toy;
    } else {
      statusText = "Player ${_game.currentPlayer}'s Turn";
      statusColor =
          _game.currentPlayer == 'X' ? Colors.indigo : Colors.deepOrange;
      statusIcon = _game.currentPlayer == 'X' ? Icons.close : Icons.circle_outlined;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(100), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 10),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      width: 300,
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.orange.withAlpha(40),
            blurRadius: 25,
            offset: const Offset(0, 4),
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
        itemBuilder: (context, index) => _buildGridCell(index),
      ),
    );
  }

  Widget _buildGridCell(int index) {
    final value = _game.board[index];
    final isWinningCell = _game.winningLine?.contains(index) ?? false;

    Color cellColor = Colors.orange.shade50.withAlpha(180);
    if (isWinningCell) {
      cellColor = value == 'X' ? Colors.indigo.shade100 : Colors.orange.shade200;
    }

    return GestureDetector(
      onTap: () => _onCellTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWinningCell
                ? (value == 'X' ? Colors.indigo : Colors.deepOrange)
                : Colors.orange.shade100,
            width: isWinningCell ? 3.0 : 1.5,
          ),
          boxShadow: isWinningCell
              ? [
                  BoxShadow(
                    color: (value == 'X' ? Colors.indigo : Colors.deepOrange)
                        .withAlpha(100),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: value.isEmpty
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : Icon(
                    value == 'X' ? Icons.close : Icons.circle_outlined,
                    key: ValueKey('$index-$value'),
                    size: 48,
                    color: value == 'X' ? Colors.indigo : Colors.deepOrange,
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
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: Text(_game.isGameOver ? 'Play Again' : 'Next Round'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Colors.orange.withAlpha(100),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _resetAll,
          tooltip: 'Reset Score',
          icon: Icon(Icons.restart_alt, color: Colors.orange.shade800),
          style: IconButton.styleFrom(
            backgroundColor: Colors.orange.shade50,
            padding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.orange.shade200),
            ),
          ),
        ),
      ],
    );
  }
}
