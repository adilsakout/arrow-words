import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/providers.dart';
import 'settings_controller.dart';
import 'settings_state.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});
