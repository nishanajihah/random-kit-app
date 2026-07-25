// lib/services/memory_game_engine.dart

import 'dart:math';
import '../models/memory_game_state.dart';
import '../models/game_item.dart';
import '../utils/app_logger.dart';

// Core memory game engine - handles all game logic
// Works with any type of GameItem (colors, haptic, sounds, etc)
class MemoryGameEngine {
  final List<GameItem> availableItems;
  final Random _random = Random();

  MemoryGameState _state = const MemoryGameState();

  MemoryGameEngine({required this.availableItems}) {
    assert(availableItems.isNotEmpty, 'At least one game item required');
  }

  // Get current game state
  MemoryGameState get state => _state;

  // Start a new game
  MemoryGameState startNewGame() {
    _state = MemoryGameState(
      status: GameStatus.idle,
      level: 1,
      score: 0,
      highScore: _state.highScore,
      message: 'Watch the sequence!',
      sequence: [],
      playerInput: [],
    );
    return _state;
  }

  // Restore state across grid size upgrades
  void restoreState({
    required int level,
    required int score,
    required int highScore,
    required List<String> sequence,
  }) {
    _state = MemoryGameState(
      status: GameStatus.idle,
      level: level,
      score: score,
      highScore: highScore,
      sequence: sequence,
      playerInput: [],
    );
  }

  // Generate a next sequence (preserves existing sequence and appends 1 new color item)
  MemoryGameState generateNextSequence({List<String>? previousSequence}) {
    final baseSequence = previousSequence ?? _state.sequence;
    final newItem = availableItems[_random.nextInt(availableItems.length)];
    final newSequence = [...baseSequence, newItem.id];

    AppLogger.debug(
      '🎯 Preserved & Appended sequence for level ${_state.level}: $newSequence',
    );

    _state = _state.copyWith(
      sequence: newSequence,
      playerInput: [],
      status: GameStatus.showingSequence,
      message: 'Level ${_state.level} - Watch carefully!',
    );

    return _state;
  }

  /// Get the sequence of items to play
  List<GameItem> getSequenceItems() {
    return _state.sequence
        .map((id) {
          try {
            return availableItems.firstWhere((item) => item.id == id);
          } catch (_) {
            return availableItems[_random.nextInt(availableItems.length)];
          }
        })
        .toList();
  }

  /// Set status to waiting for player input
  MemoryGameState startPlayerTurn() {
    _state = _state.copyWith(
      status: GameStatus.waitingForInput,
      message: 'Your turn! Repeat the sequence.',
    );
    return _state;
  }

  // Player makes a selection
  MemoryGameState playerSelect(String itemId) {
    final newInput = [..._state.playerInput, itemId];

    _state = _state.copyWith(playerInput: newInput);

    // Check if input is correct so far
    if (!_state.isInputCorrectSoFar) {
      return _handleWrongInput();
    }

    // Check if sequence is complete
    if (_state.hasCompletedSequence) {
      return _handleCorrectSequence();
    }

    // Still going, input correct so far
    return _state;
  }

  // Handle wrong input
  MemoryGameState _handleWrongInput() {
    AppLogger.info('Wrong input at level ${_state.level}. Game Over.');

    final newHighScore = _state.score > _state.highScore
        ? _state.score
        : _state.highScore;

    _state = _state.copyWith(
      status: GameStatus.wrong,
      message: 'Wrong! Game Over',
      highScore: newHighScore,
    );

    return _state;
  }

  // Handle correct sequence completion
  MemoryGameState _handleCorrectSequence() {
    final pointsEarned = _state.level * 10;
    final newScore = _state.score + pointsEarned;

    AppLogger.info('Level ${_state.level} complete! +$pointsEarned points');

    _state = _state.copyWith(
      status: GameStatus.correct,
      score: newScore,
      message: 'Correct! +$pointsEarned points',
    );
    return _state;
  }

  // Advance to next level (retains existing sequence and appends 1 new color item)
  MemoryGameState nextLevel() {
    final currentSeq = _state.sequence;
    _state = _state.copyWith(
      level: _state.level + 1,
      status: GameStatus.idle,
    );
    return generateNextSequence(previousSequence: currentSeq);
  }

  // Reset game completely
  MemoryGameState reset() {
    AppLogger.info('Resetting game.');
    final highScore = _state.highScore;
    _state = MemoryGameState(highScore: highScore);
    return _state;
  }

  // Get stats for display
  Map<String, dynamic> getStats() {
    return {
      'level': _state.level,
      'score': _state.score,
      'highScore': _state.highScore,
      'sequenceLength': _state.sequence.length,
      'accuracy': _state.sequence.isEmpty
          ? 0.0
          : (_state.playerInput.length / _state.sequence.length * 100),
    };
  }
}
