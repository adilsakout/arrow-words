import 'dart:convert';
import 'dart:io';

import 'package:arrow_words/core/i18n/app_localizations.dart';
import 'package:arrow_words/core/settings/settings_provider.dart';
import 'package:arrow_words/features/puzzle/data/progress_repository.dart';
import 'package:arrow_words/features/puzzle/data/puzzle_repository.dart';
import 'package:arrow_words/features/puzzle/domain/entities.dart';
import 'package:arrow_words/features/puzzle/domain/validators.dart';
import 'package:arrow_words/features/puzzle/logic/puzzle_provider.dart';
import 'package:arrow_words/features/puzzle/presentation/screens/puzzle_screen.dart';
import 'package:arrow_words/features/puzzle/presentation/widgets/puzzle_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Puzzle _loadPuzzle(String path) {
  final file = File(path);
  final map = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return const PuzzleParser().parse(map);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Puzzle screen responds to taps and reveals', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final puzzle = _loadPuzzle('assets/puzzles/demo_7x7.json');
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      puzzleRepositoryProvider.overrideWithValue(_InlinePuzzleRepository(prefs, puzzle)),
      progressRepositoryProvider.overrideWithValue(ProgressRepository(prefs)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PuzzleScreen(puzzleId: puzzle.id),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final canvasFinder = find.byType(PuzzleCanvas);
    expect(canvasFinder, findsOneWidget);

    final renderBox = tester.firstRenderObject<RenderBox>(canvasFinder);
    final cellSize = renderBox.size.width / puzzle.width;
    final tapOffset = renderBox.localToGlobal(Offset(cellSize * 1.5, cellSize * 0.5));
    await tester.tapAt(tapOffset);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.pump();

    await tester.tap(find.text('Reveal Letter'));
    await tester.pumpAndSettle();

    final state = container.read(puzzleControllerProvider(puzzle.id));
    expect(state.game?.hintsLeft, lessThan(5));
    final firstCellIndex = puzzle.indexOf(const Coord(0, 1));
    expect(state.game?.boardLetters[firstCellIndex], isNotEmpty);
  });
}

class _InlinePuzzleRepository extends PuzzleRepository {
  _InlinePuzzleRepository(SharedPreferences prefs, this.puzzle) : super(prefs);

  final Puzzle puzzle;

  @override
  Future<List<PuzzleSummary>> listLocalAndBundled() async => [
        PuzzleSummary(
          id: puzzle.id,
          title: puzzle.title,
          author: puzzle.author,
          width: puzzle.width,
          height: puzzle.height,
        ),
      ];

  @override
  Future<Puzzle> load(String id) async => puzzle;

  @override
  Future<void> importFromJson(String json) async {}
}
