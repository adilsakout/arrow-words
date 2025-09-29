import 'package:flutter/material.dart';

import '../../../../core/i18n/app_localizations.dart';

class PuzzleKeyboard extends StatelessWidget {
  const PuzzleKeyboard({
    super.key,
    required this.onLetter,
    required this.onBackspace,
    required this.onClear,
    required this.onTogglePencil,
    required this.isPencilMode,
  });

  final ValueChanged<String> onLetter;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onTogglePencil;
  final bool isPencilMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final letters = List<String>.generate(26, (index) => String.fromCharCode(65 + index));
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: letters
                  .map(
                    (letter) => ElevatedButton(
                      onPressed: () => onLetter(letter),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(letter),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBackspace,
                    icon: const Icon(Icons.backspace),
                    label: Text(l10n.appString('backspace')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClear,
                    child: Text(l10n.appString('clear')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onTogglePencil,
                    icon: Icon(isPencilMode ? Icons.edit_off : Icons.edit),
                    label: Text(l10n.appString('pencilMode')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
