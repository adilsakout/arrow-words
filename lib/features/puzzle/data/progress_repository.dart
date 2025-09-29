import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities.dart';

class ProgressRepository {
  ProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<GameState?> loadProgress(String puzzleId) async {
    final raw = _prefs.getString(_key(puzzleId));
    if (raw == null) {
      return null;
    }
    return GameState.decode(raw);
  }

  Future<void> saveProgress(String puzzleId, GameState state) async {
    await _prefs.setString(_key(puzzleId), state.encode());
  }

  Future<void> clearProgress(String puzzleId) async {
    await _prefs.remove(_key(puzzleId));
  }

  String _key(String puzzleId) => 'progress.$puzzleId';
}
