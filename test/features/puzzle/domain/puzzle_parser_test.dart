import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_words/features/puzzle/domain/entities.dart';
import 'package:arrow_words/features/puzzle/domain/validators.dart';

void main() {
  final parser = PuzzleParser();

  Puzzle loadPuzzle(String path) {
    final file = File(path);
    final map = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return parser.parse(map);
  }

  group('PuzzleParser', () {
    test('computes clue spans for all arrow directions', () {
      final puzzle7 = loadPuzzle('assets/puzzles/demo_7x7.json');
      final puzzle9 = loadPuzzle('assets/puzzles/demo_9x9.json');
      final directions = {
        ...puzzle7.clues.map((c) => c.direction),
        ...puzzle9.clues.map((c) => c.direction),
      };
      expect(directions, equals(ArrowDirection.values.toSet()));
    });

    test('resolves expected clue lengths', () {
      final puzzle9 = loadPuzzle('assets/puzzles/demo_9x9.json');
      final wClue = puzzle9.clues.firstWhere((c) => c.direction == ArrowDirection.w);
      final neClue = puzzle9.clues.firstWhere((c) => c.direction == ArrowDirection.ne);
      expect(wClue.length, 7);
      expect(neClue.length, 4);
    });
  });
}
