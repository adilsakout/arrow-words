import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities.dart';
import '../domain/validators.dart';
import 'local_puzzle_bundle.dart';

class PuzzleRepository {
  PuzzleRepository(this._prefs, {PuzzleParser? parser}) : _parser = parser ?? const PuzzleParser();

  final SharedPreferences _prefs;
  final PuzzleParser _parser;

  static const _importedIdsKey = 'puzzles.imported.ids';

  Future<List<PuzzleSummary>> listLocalAndBundled() async {
    final summaries = <PuzzleSummary>[];
    summaries.addAll(LocalPuzzleBundle.puzzles.map((e) => e.summary));
    final importedIds = _prefs.getStringList(_importedIdsKey) ?? <String>[];
    for (final id in importedIds) {
      final raw = _prefs.getString(_importedKey(id));
      if (raw == null) {
        continue;
      }
      final puzzle = _parser.parseFromString(raw);
      summaries.add(PuzzleSummary(
        id: puzzle.id,
        title: puzzle.title,
        author: puzzle.author,
        width: puzzle.width,
        height: puzzle.height,
        isImported: true,
      ));
    }
    return summaries;
  }

  Future<Puzzle> load(String id) async {
    final asset = LocalPuzzleBundle.find(id);
    if (asset != null) {
      final data = await rootBundle.loadString(asset.assetPath);
      return _parser.parseFromString(data);
    }
    final raw = _prefs.getString(_importedKey(id));
    if (raw != null) {
      return _parser.parseFromString(raw);
    }
    throw StateError('Puzzle $id not found');
  }

  Future<void> importFromJson(String json) async {
    final puzzle = _parser.parseFromString(json);
    final ids = _prefs.getStringList(_importedIdsKey) ?? <String>[];
    if (!ids.contains(puzzle.id)) {
      ids.add(puzzle.id);
      await _prefs.setStringList(_importedIdsKey, ids);
    }
    await _prefs.setString(_importedKey(puzzle.id), json);
  }

  String _importedKey(String id) => 'puzzles.imported.$id';
}
