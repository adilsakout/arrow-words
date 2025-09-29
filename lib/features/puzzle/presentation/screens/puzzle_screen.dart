import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_localizations.dart';
import '../../../domain/entities.dart';
import '../../../logic/puzzle_controller.dart';
import '../../../logic/puzzle_provider.dart';
import '../../../logic/puzzle_state.dart';
import '../widgets/clue_panel.dart';
import '../widgets/keyboard_row.dart';
import '../widgets/puzzle_canvas.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key, required this.puzzleId});

  final String puzzleId;

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> with TickerProviderStateMixin {
  late final FocusNode _focusNode;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
    ref.listen<PuzzleState>(puzzleControllerProvider(widget.puzzleId), (previous, next) {
      if (next.showCelebration && !(previous?.showCelebration ?? false)) {
        _confettiController.play();
        _showCompletionDialog();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(puzzleControllerProvider(widget.puzzleId));
    final controller = ref.read(puzzleControllerProvider(widget.puzzleId).notifier);
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appString('appTitle'))),
        body: Center(child: Text(state.error!)),
      );
    }
    final puzzle = state.puzzle;
    final game = state.game;
    if (puzzle == null || game == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    Clue? activeClue;
    if (puzzle.clues.isNotEmpty) {
      activeClue = puzzle.clues.firstWhere(
        (clue) => clue.id == game.activeClueId,
        orElse: () => puzzle.clues.first,
      );
    }
    final timeText = _formatElapsed(game.elapsedSeconds);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(puzzle.title),
            Text(
              '${puzzle.author} • ${puzzle.width}×${puzzle.height}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${l10n.appString('timer')}: $timeText'),
                Text('${l10n.appString('mistakes')}: ${game.mistakes}'),
              ],
            ),
          ),
        ],
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (event) => _handleKey(event, controller),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 2.5,
                      boundaryMargin: const EdgeInsets.all(24),
                      child: Center(
                        child: PuzzleCanvas(
                          puzzle: puzzle,
                          game: game,
                          activeClue: activeClue,
                          onCellTap: controller.setActiveCell,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.05,
                      numberOfParticles: 20,
                      shouldLoop: false,
                    ),
                  ),
                ],
              ),
            ),
            CluePanel(
              clue: activeClue,
              game: game,
              puzzle: puzzle,
              onRevealLetter: controller.revealLetter,
              onRevealWord: controller.revealWord,
              onCheckWord: controller.checkWord,
              onNextClue: controller.nextClue,
              onPreviousClue: controller.previousClue,
            ),
            PuzzleKeyboard(
              onLetter: controller.onLetterInput,
              onBackspace: controller.clearCurrentCell,
              onClear: controller.clearWord,
              onTogglePencil: controller.togglePencilMode,
              isPencilMode: game.pencilMode,
            ),
          ],
        ),
      ),
    );
  }

  void _handleKey(RawKeyEvent event, PuzzleController controller) {
    if (event is! RawKeyDownEvent) {
      return;
    }
    final logicalKey = event.logicalKey;
    if (logicalKey == LogicalKeyboardKey.arrowRight) {
      controller.moveFocus(1);
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      controller.moveFocus(-1);
    } else if (logicalKey == LogicalKeyboardKey.arrowUp) {
      controller.previousClue();
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      controller.nextClue();
    } else if (logicalKey == LogicalKeyboardKey.tab) {
      if (event.isShiftPressed) {
        controller.previousClue();
      } else {
        controller.nextClue();
      }
    } else if (logicalKey == LogicalKeyboardKey.enter) {
      controller.nextClue();
    } else if (logicalKey == LogicalKeyboardKey.backspace) {
      controller.clearCurrentCell();
    } else if (logicalKey == LogicalKeyboardKey.space) {
      controller.togglePencilMode();
    } else {
      final character = event.character;
      if (character != null && character.isNotEmpty) {
        final letter = character.toUpperCase();
        if (letter.codeUnitAt(0) >= 65 && letter.codeUnitAt(0) <= 90) {
          controller.onLetterInput(letter);
        }
      }
    }
  }

  Future<void> _showCompletionDialog() async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(puzzleControllerProvider(widget.puzzleId).notifier);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appString('celebrationTitle')),
        content: Text(l10n.appString('celebrationMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.appString('resume')),
          ),
        ],
      ),
    );
    controller.dismissCelebration();
  }

  String _formatElapsed(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$secs';
    }
    return '$minutes:$secs';
  }
}
