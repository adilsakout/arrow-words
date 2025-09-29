import 'package:flutter/material.dart';

import '../../../../core/i18n/app_localizations.dart';
import '../../../domain/entities.dart';

class CluePanel extends StatelessWidget {
  const CluePanel({
    super.key,
    required this.clue,
    required this.game,
    required this.puzzle,
    required this.onRevealLetter,
    required this.onRevealWord,
    required this.onCheckWord,
    required this.onNextClue,
    required this.onPreviousClue,
  });

  final Clue? clue;
  final GameState game;
  final Puzzle puzzle;
  final VoidCallback onRevealLetter;
  final VoidCallback onRevealWord;
  final VoidCallback onCheckWord;
  final VoidCallback onNextClue;
  final VoidCallback onPreviousClue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final solvedLetters = clue == null
        ? 0
        : clue!.cells.where((coord) {
            final index = puzzle.indexOf(coord);
            return game.boardLetters[index].isNotEmpty;
          }).length;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousClue,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clue?.text ?? '--',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${clue?.direction.arrowChar ?? ''} · ${solvedLetters}/${clue?.length ?? 0}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNextClue,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: game.hintsLeft > 0 ? onRevealLetter : null,
                  child: Text(l10n.appString('revealLetter')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: game.hintsLeft > 0 ? onRevealWord : null,
                  child: Text(l10n.appString('revealWord')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onCheckWord,
                  child: Text(l10n.appString('checkWord')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l10n.appString('hintRemaining', params: {'count': game.hintsLeft.toString()}),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
