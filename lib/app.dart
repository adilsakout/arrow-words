import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/i18n/app_localizations.dart';
import 'core/settings/settings_provider.dart';
import 'core/settings/settings_state.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

class ArrowWordsApp extends ConsumerWidget {
  const ArrowWordsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = _resolveTheme(settings);
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Arrow Words',
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: theme.mode,
      routerConfig: router,
      locale: Locale(settings.localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  _ResolvedTheme _resolveTheme(SettingsState settings) {
    if (settings.themePreference == ThemePreference.highContrast) {
      return _ResolvedTheme(
        light: AppTheme.highContrast(),
        dark: AppTheme.dark(),
        mode: ThemeMode.light,
      );
    }
    return _ResolvedTheme(
      light: AppTheme.light(),
      dark: AppTheme.dark(),
      mode: settings.themeMode,
    );
  }
}

class _ResolvedTheme {
  const _ResolvedTheme({
    required this.light,
    required this.dark,
    required this.mode,
  });

  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;
}
