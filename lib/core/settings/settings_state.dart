import 'package:flutter/material.dart';

enum ThemePreference { system, light, dark, highContrast }

class SettingsState {
  const SettingsState({
    required this.themePreference,
    required this.localeCode,
    required this.autoCheck,
    required this.highlightErrors,
    required this.showTimer,
    required this.soundEffects,
    required this.haptics,
  });

  factory SettingsState.initial() => const SettingsState(
        themePreference: ThemePreference.system,
        localeCode: 'en',
        autoCheck: false,
        highlightErrors: true,
        showTimer: true,
        soundEffects: true,
        haptics: true,
      );

  final ThemePreference themePreference;
  final String localeCode;
  final bool autoCheck;
  final bool highlightErrors;
  final bool showTimer;
  final bool soundEffects;
  final bool haptics;

  ThemeMode get themeMode {
    switch (themePreference) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.highContrast:
        return ThemeMode.light;
    }
  }

  SettingsState copyWith({
    ThemePreference? themePreference,
    String? localeCode,
    bool? autoCheck,
    bool? highlightErrors,
    bool? showTimer,
    bool? soundEffects,
    bool? haptics,
  }) {
    return SettingsState(
      themePreference: themePreference ?? this.themePreference,
      localeCode: localeCode ?? this.localeCode,
      autoCheck: autoCheck ?? this.autoCheck,
      highlightErrors: highlightErrors ?? this.highlightErrors,
      showTimer: showTimer ?? this.showTimer,
      soundEffects: soundEffects ?? this.soundEffects,
      haptics: haptics ?? this.haptics,
    );
  }
}
