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

  group('Puzzle validation', () {
    test('intersections keep letters consistent', () {
      final puzzle = loadPuzzle('assets/puzzles/demo_7x7.json');
      final meerkat = puzzle.clues.firstWhere((c) => c.text.contains('Dusty'));
      final augur = puzzle.clues.firstWhere((c) => c.text.contains('Augur'));
      final coord = meerkat.cells[2];
      expect(augur.cells.contains(coord), isTrue);
      final letter = expectedLetter(puzzle, coord);
      expect(letter, equals('E'));
    });

    test('isClueSolved verifies filled board', () {
      final puzzle = loadPuzzle('assets/puzzles/demo_9x9.json');
      final clue = puzzle.clues.firstWhere((c) => c.direction == ArrowDirection.ne);
      final letters = List<String>.filled(puzzle.cells.length, '');
      for (final coord in clue.cells) {
        final index = puzzle.indexOf(coord);
        letters[index] = expectedLetter(puzzle, coord) ?? '';
      }
      final solved = isClueSolved(puzzle, clue, letters);
      expect(solved, isTrue);
    });
  });
}
