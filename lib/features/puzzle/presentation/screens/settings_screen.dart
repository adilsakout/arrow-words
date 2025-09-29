import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/settings/settings_controller.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/settings/settings_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appString('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _ThemeSection(settings: settings, controller: controller, l10n: l10n),
          const SizedBox(height: 24),
          _LanguageSection(settings: settings, controller: controller, l10n: l10n),
          const SizedBox(height: 24),
          _ToggleTile(
            title: l10n.appString('autoCheck'),
            value: settings.autoCheck,
            onChanged: controller.setAutoCheck,
          ),
          _ToggleTile(
            title: l10n.appString('highlightErrors'),
            value: settings.highlightErrors,
            onChanged: controller.setHighlightErrors,
          ),
          _ToggleTile(
            title: l10n.appString('showTimer'),
            value: settings.showTimer,
            onChanged: controller.setShowTimer,
          ),
          _ToggleTile(
            title: l10n.appString('soundEffects'),
            value: settings.soundEffects,
            onChanged: controller.setSoundEffects,
          ),
          _ToggleTile(
            title: l10n.appString('haptics'),
            value: settings.haptics,
            onChanged: controller.setHaptics,
          ),
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection({
    required this.settings,
    required this.controller,
    required this.l10n,
  });

  final SettingsState settings;
  final SettingsController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appString('theme'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ThemePreference.values.map((preference) {
            final isSelected = settings.themePreference == preference;
            return ChoiceChip(
              label: Text(_themeLabel(preference)),
              selected: isSelected,
              onSelected: (_) => controller.setThemePreference(preference),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _themeLabel(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.system:
        return l10n.appString('systemTheme');
      case ThemePreference.light:
        return l10n.appString('lightTheme');
      case ThemePreference.dark:
        return l10n.appString('darkTheme');
      case ThemePreference.highContrast:
        return l10n.appString('highContrastTheme');
    }
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection({
    required this.settings,
    required this.controller,
    required this.l10n,
  });

  final SettingsState settings;
  final SettingsController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appString('language'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: settings.localeCode,
          items: AppLocalizations.supportedLocales
              .map((locale) => DropdownMenuItem(
                    value: locale.languageCode,
                    child: Text(locale.languageCode.toUpperCase()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.setLocale(value);
            }
          },
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
