import 'dart:convert';
import 'dart:io';

import 'package:arrow_words/features/puzzle/domain/entities.dart';
import 'package:arrow_words/features/puzzle/domain/validators.dart';
import 'package:arrow_words/features/puzzle/presentation/widgets/puzzle_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadAppFonts();
  });

  Future<PuzzleCanvas> buildCanvas() async {
    final map = jsonDecode(File('assets/puzzles/demo_7x7.json').readAsStringSync()) as Map<String, dynamic>;
    final puzzle = const PuzzleParser().parse(map);
    final game = GameState.initial(puzzle: puzzle, hints: 5);
    return PuzzleCanvas(
      puzzle: puzzle,
      game: game,
      activeClue: puzzle.clues.isNotEmpty ? puzzle.clues.first : null,
      onCellTap: (_) {},
    );
  }

  testGoldens('renders light grid', (tester) async {
    final canvas = await buildCanvas();
    final builder = GoldenBuilder.column()
      ..addScenario('light', MaterialApp(home: Scaffold(body: canvas)));
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'puzzle_light', skip: true);
  });

  testGoldens('renders dark grid', (tester) async {
    final canvas = await buildCanvas();
    final builder = GoldenBuilder.column()
      ..addScenario(
        'dark',
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: Scaffold(body: canvas),
        ),
      );
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'puzzle_dark', skip: true);
  });
}
