import '../domain/entities.dart';

class PuzzleAsset {
  const PuzzleAsset({
    required this.id,
    required this.assetPath,
    required this.summary,
  });

  final String id;
  final String assetPath;
  final PuzzleSummary summary;
}

class LocalPuzzleBundle {
  static final List<PuzzleAsset> _puzzles = [
    PuzzleAsset(
      id: 'demo_7x7',
      assetPath: 'assets/puzzles/demo_7x7.json',
      summary: const PuzzleSummary(
        id: 'demo_7x7',
        title: 'Savanna Snap',
        author: 'PuzzleLab',
        width: 7,
        height: 7,
      ),
    ),
    PuzzleAsset(
      id: 'demo_9x9',
      assetPath: 'assets/puzzles/demo_9x9.json',
      summary: const PuzzleSummary(
        id: 'demo_9x9',
        title: 'Sky Trails',
        author: 'PuzzleLab',
        width: 9,
        height: 9,
        isDaily: true,
      ),
    ),
  ];

  static List<PuzzleAsset> get puzzles => List.unmodifiable(_puzzles);

  static PuzzleAsset? find(String id) {
    for (final puzzle in _puzzles) {
      if (puzzle.id == id) {
        return puzzle;
      }
    }
    return null;
  }
}
