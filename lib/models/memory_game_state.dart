// lib/models/memory_game_state.dart

// Represents the current state of a memory game session
enum GameStatus {
  idle, // Game not started
  showingSequence, // AI Showing the sequence
  waitingForInput, // Waiting for player to repeat
  correct, // Player got it right
  wrong, // Player made a mistake
  gameOver, // Game ended
}

class MemoryGameState {
  final GameStatus status;
  final int level;
  final int score;
  final int highScore;
  final List<String> sequence; //List of item IDs
  final List<String> playerInput; //Player current attempt
  final String? message; // Optional message to display

  const MemoryGameState({
    this.status = GameStatus.idle,
    this.level = 1,
    this.score = 0,
    this.highScore = 0,
    this.sequence = const [],
    this.playerInput = const [],
    this.message,
  });

  // Create a copy with modified fields
  MemoryGameState copyWith({
    GameStatus? status,
    int? level,
    int? score,
    int? highScore,
    List<String>? sequence,
    List<String>? playerInput,
    String? message,
  }) {
    return MemoryGameState(
      status: status ?? this.status,
      level: level ?? this.level,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      sequence: sequence ?? this.sequence,
      playerInput: playerInput ?? this.playerInput,
      message: message ?? this.message,
    );
  }

  // Check if player current input matches the sequence so far
  bool get isInputCorrectSoFar {
    if (playerInput.isEmpty) return true;
    for (int i = 0; i < playerInput.length; i++) {
      if (playerInput[i] != sequence[i]) {
        return false;
      }
    }
    return true;
  }

  // Check if player has completed the sequence
  bool get hasCompletedSequence {
    return playerInput.length == sequence.length && isInputCorrectSoFar;
  }

  // Get current progress (0.0 to 1.0)
  double get progress {
    if (sequence.isEmpty) return 0.0;
    return playerInput.length / sequence.length;
  }

  @override
  String toString() {
    return 'GameState(status: $status, level: $level, score: $score, '
        'sequence: ${sequence.length}, input: ${playerInput.length})';
  }
}
