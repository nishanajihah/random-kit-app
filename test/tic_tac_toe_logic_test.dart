// test/tic_tac_toe_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:random_kit_app/logics/tic_tac_toe_logic.dart';

void main() {
  group('TicTacToeLogic', () {
    late TicTacToeLogic game;

    setUp(() {
      game = TicTacToeLogic();
    });

    test('initial state has empty board and X starts', () {
      expect(game.board, List.filled(9, ''));
      expect(game.currentPlayer, 'X');
      expect(game.winner, isNull);
      expect(game.winningLine, isNull);
      expect(game.xWins, 0);
      expect(game.oWins, 0);
      expect(game.draws, 0);
    });

    test('making valid move updates board and switches player', () {
      final success = game.makeMove(0);
      expect(success, isTrue);
      expect(game.board[0], 'X');
      expect(game.currentPlayer, 'O');
    });

    test('cannot play on occupied spot', () {
      game.makeMove(0);
      final success = game.makeMove(0);
      expect(success, isFalse);
      expect(game.board[0], 'X');
      expect(game.currentPlayer, 'O');
    });

    test('detects horizontal win for X', () {
      // Row 1: 0, 1, 2
      game.makeMove(0); // X
      game.makeMove(3); // O
      game.makeMove(1); // X
      game.makeMove(4); // O
      game.makeMove(2); // X

      expect(game.winner, 'X');
      expect(game.winningLine, [0, 1, 2]);
      expect(game.xWins, 1);
      expect(game.isGameOver, isTrue);
    });

    test('detects diagonal win for O', () {
      // O plays diagonal: 2, 4, 6
      game.makeMove(0); // X
      game.makeMove(2); // O
      game.makeMove(1); // X
      game.makeMove(4); // O
      game.makeMove(3); // X
      game.makeMove(6); // O

      expect(game.winner, 'O');
      expect(game.winningLine, [2, 4, 6]);
      expect(game.oWins, 1);
      expect(game.isGameOver, isTrue);
    });

    test('detects draw when board is full without winner', () {
      // X O X
      // X X O
      // O X O
      game.makeMove(0); // X
      game.makeMove(1); // O
      game.makeMove(2); // X
      game.makeMove(5); // O
      game.makeMove(3); // X
      game.makeMove(6); // O
      game.makeMove(4); // X
      game.makeMove(8); // O
      game.makeMove(7); // X

      expect(game.winner, 'Draw');
      expect(game.winningLine, isNull);
      expect(game.draws, 1);
      expect(game.isGameOver, isTrue);
    });

    test('AI move generation chooses valid empty spot', () {
      game.makeMove(0); // X
      final aiMove = game.getAiMove();
      expect(aiMove, greaterThanOrEqualTo(0));
      expect(aiMove, lessThan(9));
      expect(game.board[aiMove], '');
    });

    test('AI blocks opponent winning move', () {
      // X has 0, 1 -> AI should pick 2 to block
      game.makeMove(0); // X
      game.makeMove(4); // O
      game.makeMove(1); // X
      final aiMove = game.getAiMove();
      expect(aiMove, 2);
    });

    test('resetBoard clears board but retains score', () {
      game.makeMove(0);
      game.makeMove(3);
      game.makeMove(1);
      game.makeMove(4);
      game.makeMove(2); // X wins

      expect(game.xWins, 1);

      game.resetBoard();
      expect(game.board, List.filled(9, ''));
      expect(game.winner, isNull);
      expect(game.xWins, 1);
    });

    test('resetScores resets board and all scores', () {
      game.makeMove(0);
      game.makeMove(3);
      game.makeMove(1);
      game.makeMove(4);
      game.makeMove(2); // X wins

      game.resetScores();
      expect(game.board, List.filled(9, ''));
      expect(game.xWins, 0);
      expect(game.oWins, 0);
      expect(game.draws, 0);
    });
  });
}
