import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/settings_state.dart';
import '../../../core/settings/settings_provider.dart';
import '../../../core/utils/providers.dart';
import '../../puzzle/data/progress_repository.dart';
import '../../puzzle/data/puzzle_repository.dart';
import '../domain/entities.dart';
import '../domain/validators.dart';
import 'puzzle_state.dart';

class PuzzleController extends StateNotifier<PuzzleState> {
  PuzzleController({
    required this.puzzleId,
    required this.puzzleRepository,
    required this.progressRepository,
    required Ref ref,
  })  : _ref = ref,
        super(PuzzleState.initial) {
    _parser = const PuzzleParser();
    _init();
  }

  final String puzzleId;
  final PuzzleRepository puzzleRepository;
  final ProgressRepository progressRepository;
  final Ref _ref;
  late final PuzzleParser _parser;
  Timer? _timer;
  Map<String, Clue> _clueById = const {};

  void _init() {
    unawaited(_loadPuzzle());
    _ref.listen<SettingsState>(settingsControllerProvider, (previous, next) {
      _applySettings(next);
    });
  }

  Future<void> _loadPuzzle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final puzzle = await puzzleRepository.load(puzzleId);
      final saved = await progressRepository.loadProgress(puzzleId);
      final settings = _ref.read(settingsControllerProvider);
      final game = saved ??
          GameState.initial(
            puzzle: puzzle,
            hints: 5,
            autoCheck: settings.autoCheck,
            highlightErrors: settings.highlightErrors,
          );
      _clueById = {for (final clue in puzzle.clues) clue.id: clue};
      state = PuzzleState(
        puzzle: puzzle,
        game: game,
        isLoading: false,
        cellToClues: _buildCellLookup(puzzle),
      );
      _startTimer();
    } on PlatformException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Map<int, List<Clue>> _buildCellLookup(Puzzle puzzle) {
    final map = <int, List<Clue>>{};
    for (final clue in puzzle.clues) {
      for (final coord in clue.cells) {
        final index = puzzle.indexOf(coord);
        map.putIfAbsent(index, () => <Clue>[]).add(clue);
      }
    }
    return map;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final game = state.game;
      final puzzle = state.puzzle;
      if (!mounted || game == null || puzzle == null || game.completed) {
        return;
      }
      final updated = game.copyWith(elapsedSeconds: game.elapsedSeconds + 1);
      _updateGame(updated, persist: false);
    });
  }

  Clue? get _activeClue {
    final game = state.game;
    if (game == null) {
      return null;
    }
    return _clueById[game.activeClueId];
  }

  void _applySettings(SettingsState settings) {
    final game = state.game;
    if (game == null) {
      return;
    }
    if (game.autoCheck == settings.autoCheck && game.highlightErrors == settings.highlightErrors) {
      return;
    }
    final updated = game.copyWith(
      autoCheck: settings.autoCheck,
      highlightErrors: settings.highlightErrors,
    );
    _updateGame(updated, persist: false);
  }

  void onLetterInput(String letter) {
    final puzzle = state.puzzle;
    final game = state.game;
    final clue = _activeClue;
    if (puzzle == null || game == null || clue == null || clue.cells.isEmpty) {
      return;
    }
    final coord = clue.cells[game.activeCellIndex.clamp(0, clue.cells.length - 1)];
    if (game.pencilMode) {
      _togglePencilNote(puzzle.indexOf(coord), letter);
      return;
    }
    final letters = List<String>.from(game.boardLetters);
    final index = puzzle.indexOf(coord);
    letters[index] = letter.toUpperCase();

    var mistakes = game.mistakes;
    if (game.autoCheck && !checkLetter(puzzle, coord, letter)) {
      mistakes += 1;
    }

    var solved = Set<String>.from(game.solvedClueIds);
    if (isClueSolved(puzzle, clue, letters)) {
      solved.add(clue.id);
    } else {
      solved.remove(clue.id);
    }

    final isLastCell = game.activeCellIndex >= clue.cells.length - 1;
    String? nextClueId = game.activeClueId;
    var nextIndex = isLastCell ? 0 : game.activeCellIndex + 1;
    if (isLastCell) {
      final nextClue = _nextClue(clue.id);
      nextClueId = nextClue?.id ?? game.activeClueId;
    }

    final updated = game.copyWith(
      boardLetters: letters,
      mistakes: mistakes,
      solvedClueIds: solved,
      activeCellIndex: nextIndex,
      activeClueId: nextClueId,
    );
    _updateGame(updated);
  }

  void _togglePencilNote(int cellIndex, String letter) {
    final game = state.game;
    if (game == null) {
      return;
    }
    final map = Map<int, Set<String>>.from(game.pencilNotes);
    final normalized = letter.toUpperCase();
    final notes = map[cellIndex] == null ? <String>{} : Set<String>.from(map[cellIndex]!);
    if (notes.contains(normalized)) {
      notes.remove(normalized);
    } else {
      notes.add(normalized);
    }
    if (notes.isEmpty) {
      map.remove(cellIndex);
    } else {
      map[cellIndex] = notes;
    }
    _updateGame(game.copyWith(pencilNotes: map));
  }

  void clearCurrentCell() {
    final puzzle = state.puzzle;
    final game = state.game;
    final clue = _activeClue;
    if (puzzle == null || game == null || clue == null || clue.cells.isEmpty) {
      return;
    }
    final coord = clue.cells[game.activeCellIndex];
    final index = puzzle.indexOf(coord);
    final letters = List<String>.from(game.boardLetters);
    letters[index] = '';
    final solved = Set<String>.from(game.solvedClueIds)..remove(clue.id);
    _updateGame(game.copyWith(boardLetters: letters, solvedClueIds: solved));
  }

  void clearWord() {
    final puzzle = state.puzzle;
    final game = state.game;
    final clue = _activeClue;
    if (puzzle == null || game == null || clue == null) {
      return;
    }
    final letters = List<String>.from(game.boardLetters);
    for (final coord in clue.cells) {
      letters[puzzle.indexOf(coord)] = '';
    }
    final solved = Set<String>.from(game.solvedClueIds)..remove(clue.id);
    _updateGame(game.copyWith(boardLetters: letters, solvedClueIds: solved));
  }

  void moveFocus(int delta) {
    final game = state.game;
    final clue = _activeClue;
    if (game == null || clue == null || clue.cells.isEmpty) {
      return;
    }
    final nextIndex = (game.activeCellIndex + delta) % clue.cells.length;
    _updateGame(game.copyWith(activeCellIndex: nextIndex < 0 ? clue.cells.length + nextIndex : nextIndex), persist: false);
  }

  void jumpToClue(String clueId, {int cellIndex = 0}) {
    final game = state.game;
    if (game == null || !_clueById.containsKey(clueId)) {
      return;
    }
    final normalizedIndex = cellIndex.clamp(0, _clueById[clueId]!.cells.length - 1);
    _updateGame(game.copyWith(activeClueId: clueId, activeCellIndex: normalizedIndex), persist: false);
  }

  void setActiveCell(Coord coord) {
    final puzzle = state.puzzle;
    final game = state.game;
    if (puzzle == null || game == null) {
      return;
    }
    final index = puzzle.indexOf(coord);
    final clues = state.cellToClues[index];
    if (clues == null || clues.isEmpty) {
      return;
    }
    final currentClue = _activeClue;
    Clue target = clues.first;
    if (currentClue != null && clues.contains(currentClue)) {
      target = currentClue;
    }
    final cellIndex = target.cells.indexWhere((c) => c == coord);
    if (cellIndex >= 0) {
      jumpToClue(target.id, cellIndex: cellIndex);
    }
  }

  void togglePencilMode() {
    final game = state.game;
    if (game == null) {
      return;
    }
    _updateGame(game.copyWith(pencilMode: !game.pencilMode), persist: false);
  }

  void revealLetter() {
    final puzzle = state.puzzle;
    final game = state.game;
    final clue = _activeClue;
    if (puzzle == null || game == null || clue == null || game.hintsLeft <= 0) {
      return;
    }
    final coord = clue.cells[game.activeCellIndex];
    final solution = expectedLetter(puzzle, coord);
    if (solution == null || solution.isEmpty) {
      return;
    }
    final letters = List<String>.from(game.boardLetters);
    letters[puzzle.indexOf(coord)] = solution;
    final solved = Set<String>.from(game.solvedClueIds);
    if (isClueSolved(puzzle, clue, letters)) {
      solved.add(clue.id);
    }
    final updated = game.copyWith(
      boardLetters: letters,
      hintsLeft: game.hintsLeft - 1,
      solvedClueIds: solved,
    );
    _updateGame(updated);
  }

  void revealWord() {
    final puzzle = state.puzzle;
    final game = state.game;
    final clue = _activeClue;
    if (puzzle == null || game == null || clue == null || game.hintsLeft <= 0) {
      return;
    }
    final letters = List<String>.from(game.boardLetters);
    for (final coord in clue.cells) {
      final solution = expectedLetter(puzzle, coord) ?? '';
      letters[puzzle.indexOf(coord)] = solution;
    }
    final updated = game.copyWith(
      boardLetters: letters,
      hintsLeft: (game.hintsLeft - 1).clamp(0, 999),
      solvedClueIds: {...game.solvedClueIds, clue.id},
    );
    _updateGame(updated);
  }

  void checkWord() {
    final puzzle = state.puzzle;
    final game = state.game;
    final clue = _activeClue;
    if (puzzle == null || game == null || clue == null) {
      return;
    }
    final letters = clue.cells
        .map((coord) => game.boardLetters[puzzle.indexOf(coord)])
        .toList();
    if (!checkWord(puzzle, clue, letters)) {
      _updateGame(game.copyWith(mistakes: game.mistakes + 1));
    }
  }

  void nextClue() {
    final clue = _activeClue;
    final game = state.game;
    if (clue == null || game == null) {
      return;
    }
    final next = _nextClue(clue.id);
    if (next != null) {
      jumpToClue(next.id, cellIndex: 0);
    }
  }

  void previousClue() {
    final clue = _activeClue;
    final game = state.game;
    if (clue == null || game == null) {
      return;
    }
    final prev = _previousClue(clue.id);
    if (prev != null) {
      jumpToClue(prev.id, cellIndex: 0);
    }
  }

  Clue? _nextClue(String? id) {
    final puzzle = state.puzzle;
    if (puzzle == null || id == null || puzzle.clues.isEmpty) {
      return null;
    }
    final index = puzzle.clues.indexWhere((clue) => clue.id == id);
    if (index == -1) {
      return null;
    }
    final nextIndex = (index + 1) % puzzle.clues.length;
    return puzzle.clues[nextIndex];
  }

  Clue? _previousClue(String? id) {
    final puzzle = state.puzzle;
    if (puzzle == null || id == null || puzzle.clues.isEmpty) {
      return null;
    }
    final index = puzzle.clues.indexWhere((clue) => clue.id == id);
    if (index == -1) {
      return null;
    }
    final prevIndex = (index - 1) % puzzle.clues.length;
    return puzzle.clues[prevIndex < 0 ? puzzle.clues.length - 1 : prevIndex];
  }

  void _updateGame(GameState game, {bool persist = true}) {
    final puzzle = state.puzzle;
    if (puzzle == null) {
      return;
    }
    final solvedAll = puzzle.clues.isEmpty ||
        puzzle.clues.every((clue) => game.solvedClueIds.contains(clue.id));
    var showCelebration = state.showCelebration;
    var adjustedGame = game;
    if (solvedAll && !game.completed) {
      showCelebration = true;
      adjustedGame = game.copyWith(completed: true);
    }
    state = state.copyWith(
      game: adjustedGame,
      showCelebration: showCelebration,
    );
    if (persist) {
      unawaited(progressRepository.saveProgress(puzzleId, adjustedGame));
      final prefs = _ref.read(sharedPreferencesProvider);
      unawaited(prefs.setString('progress.last', puzzleId));
    }
  }

  void dismissCelebration() {
    state = state.copyWith(showCelebration: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
