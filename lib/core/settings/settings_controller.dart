import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._prefs) : super(SettingsState.initial()) {
    unawaited(_load());
  }

  final SharedPreferences _prefs;

  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';
  static const _autoCheckKey = 'settings.autoCheck';
  static const _highlightKey = 'settings.highlight';
  static const _timerKey = 'settings.timer';
  static const _soundKey = 'settings.sound';
  static const _hapticsKey = 'settings.haptics';

  Future<void> _load() async {
    final themeIndex = _prefs.getInt(_themeKey);
    final locale = _prefs.getString(_localeKey);
    final autoCheck = _prefs.getBool(_autoCheckKey);
    final highlight = _prefs.getBool(_highlightKey);
    final timer = _prefs.getBool(_timerKey);
    final sound = _prefs.getBool(_soundKey);
    final haptics = _prefs.getBool(_hapticsKey);
    state = state.copyWith(
      themePreference:
          themeIndex == null ? state.themePreference : ThemePreference.values[themeIndex],
      localeCode: locale ?? state.localeCode,
      autoCheck: autoCheck ?? state.autoCheck,
      highlightErrors: highlight ?? state.highlightErrors,
      showTimer: timer ?? state.showTimer,
      soundEffects: sound ?? state.soundEffects,
      haptics: haptics ?? state.haptics,
    );
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    state = state.copyWith(themePreference: preference);
    await _prefs.setInt(_themeKey, preference.index);
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await _prefs.setString(_localeKey, code);
  }

  Future<void> setAutoCheck(bool value) async {
    state = state.copyWith(autoCheck: value);
    await _prefs.setBool(_autoCheckKey, value);
  }

  Future<void> setHighlightErrors(bool value) async {
    state = state.copyWith(highlightErrors: value);
    await _prefs.setBool(_highlightKey, value);
  }

  Future<void> setShowTimer(bool value) async {
    state = state.copyWith(showTimer: value);
    await _prefs.setBool(_timerKey, value);
  }

  Future<void> setSoundEffects(bool value) async {
    state = state.copyWith(soundEffects: value);
    await _prefs.setBool(_soundKey, value);
  }

  Future<void> setHaptics(bool value) async {
    state = state.copyWith(haptics: value);
    await _prefs.setBool(_hapticsKey, value);
  }
}
