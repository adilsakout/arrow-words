import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/providers.dart';
import '../data/progress_repository.dart';
import '../data/puzzle_repository.dart';
import 'puzzle_controller.dart';
import 'puzzle_state.dart';

final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PuzzleRepository(prefs);
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressRepository(prefs);
});

final puzzleControllerProvider =
    StateNotifierProviderFamily<PuzzleController, PuzzleState, String>((ref, puzzleId) {
  final puzzleRepository = ref.watch(puzzleRepositoryProvider);
  final progressRepository = ref.watch(progressRepositoryProvider);
  final controller = PuzzleController(
    puzzleId: puzzleId,
    puzzleRepository: puzzleRepository,
    progressRepository: progressRepository,
    ref: ref,
  );
  return controller;
});
