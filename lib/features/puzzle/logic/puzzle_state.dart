import '../domain/entities.dart';

class PuzzleState {
  const PuzzleState({
    this.puzzle,
    this.game,
    this.isLoading = false,
    this.error,
    this.showCelebration = false,
    this.cellToClues = const {},
  });

  final Puzzle? puzzle;
  final GameState? game;
  final bool isLoading;
  final String? error;
  final bool showCelebration;
  final Map<int, List<Clue>> cellToClues;

  PuzzleState copyWith({
    Puzzle? puzzle,
    GameState? game,
    bool? isLoading,
    String? error,
    bool? showCelebration,
    Map<int, List<Clue>>? cellToClues,
  }) {
    return PuzzleState(
      puzzle: puzzle ?? this.puzzle,
      game: game ?? this.game,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      showCelebration: showCelebration ?? this.showCelebration,
      cellToClues: cellToClues ?? this.cellToClues,
    );
  }

  PuzzleState clearError() => copyWith(error: null);

  PuzzleState withCelebration(bool value) => copyWith(showCelebration: value);

  static const initial = PuzzleState(isLoading: true);
}
