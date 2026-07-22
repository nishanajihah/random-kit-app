// lib/logics/tic_tac_toe_logic.dart

import 'dart:math';

enum TicTacToeMode { singlePlayer, twoPlayer }

class TicTacToeLogic {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  TicTacToeMode mode = TicTacToeMode.singlePlayer;
  
  String? winner; // 'X', 'O', 'Draw', or null
  List<int>? winningLine; // Index of cells [e.g., 0, 1, 2] forming winning line
  
  int xWins = 0;
  int oWins = 0;
  int draws = 0;

  static const List<List<int>> winPatterns = [
    [0, 1, 2], // Row 1
    [3, 4, 5], // Row 2
    [6, 7, 8], // Row 3
    [0, 3, 6], // Column 1
    [1, 4, 7], // Column 2
    [2, 5, 8], // Column 3
    [0, 4, 8], // Diagonal top-left to bottom-right
    [2, 4, 6], // Diagonal top-right to bottom-left
  ];

  TicTacToeLogic({this.mode = TicTacToeMode.singlePlayer});

  bool makeMove(int index) {
    if (index < 0 || index >= 9 || board[index].isNotEmpty || isGameOver) {
      return false;
    }

    board[index] = currentPlayer;
    _checkGameState();

    if (!isGameOver) {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }

    return true;
  }

  bool get isGameOver => winner != null;

  void _checkGameState() {
    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];

      if (a.isNotEmpty && a == b && a == c) {
        winner = a;
        winningLine = pattern;
        if (a == 'X') {
          xWins++;
        } else {
          oWins++;
        }
        return;
      }
    }

    if (!board.contains('')) {
      winner = 'Draw';
      winningLine = null;
      draws++;
    }
  }

  /// Calculates the best move for AI ('O') in Single Player mode
  int getAiMove() {
    if (isGameOver) return -1;

    // 1. Check if AI can win in next move
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = 'O';
        if (_checkWinnerSimulated() == 'O') {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }

    // 2. Check if Opponent ('X') can win in next move and block them
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = 'X';
        if (_checkWinnerSimulated() == 'X') {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
    }

    // 3. Take center if available
    if (board[4].isEmpty) {
      return 4;
    }

    // 4. Take available corners
    final corners = [0, 2, 6, 8]..shuffle();
    for (final corner in corners) {
      if (board[corner].isEmpty) {
        return corner;
      }
    }

    // 5. Take any available empty spot randomly
    final available = <int>[];
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) available.add(i);
    }

    if (available.isNotEmpty) {
      final random = Random();
      return available[random.nextInt(available.length)];
    }

    return -1;
  }

  String? _checkWinnerSimulated() {
    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];
      if (a.isNotEmpty && a == b && a == c) {
        return a;
      }
    }
    return null;
  }

  void resetBoard({bool switchStartingPlayer = false}) {
    board = List.filled(9, '');
    winner = null;
    winningLine = null;
    if (switchStartingPlayer) {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    } else {
      currentPlayer = 'X';
    }
  }

  void resetScores() {
    xWins = 0;
    oWins = 0;
    draws = 0;
    resetBoard();
  }

  void setGameMode(TicTacToeMode newMode) {
    mode = newMode;
    resetScores();
  }
}
