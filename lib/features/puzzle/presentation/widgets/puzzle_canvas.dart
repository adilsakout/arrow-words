import 'package:flutter/material.dart';

import '../../../domain/entities.dart';

class PuzzleCanvas extends StatelessWidget {
  const PuzzleCanvas({
    super.key,
    required this.puzzle,
    required this.game,
    required this.activeClue,
    required this.onCellTap,
    this.cellExtent = 64,
  });

  final Puzzle puzzle;
  final GameState game;
  final Clue? activeClue;
  final ValueChanged<Coord> onCellTap;
  final double cellExtent;

  @override
  Widget build(BuildContext context) {
    final size = Size(puzzle.width * cellExtent, puzzle.height * cellExtent);
    return GestureDetector(
      onTapUp: (details) {
        final row = (details.localPosition.dy / cellExtent).floor();
        final col = (details.localPosition.x / cellExtent).floor();
        if (row >= 0 && row < puzzle.height && col >= 0 && col < puzzle.width) {
          onCellTap(Coord(row, col));
        }
      },
      child: CustomPaint(
        size: size,
        painter: _PuzzlePainter(
          puzzle: puzzle,
          game: game,
          activeClue: activeClue,
          theme: Theme.of(context),
        ),
      ),
    );
  }
}

class _PuzzlePainter extends CustomPainter {
  _PuzzlePainter({
    required this.puzzle,
    required this.game,
    required this.activeClue,
    required this.theme,
  });

  final Puzzle puzzle;
  final GameState game;
  final Clue? activeClue;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / puzzle.width;
    final cellHeight = size.height / puzzle.height;
    final Paint gridPaint = Paint()
      ..color = theme.colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final Paint blockPaint = Paint()..color = theme.colorScheme.surfaceVariant;
    final Paint cluePaint = Paint()..color = theme.colorScheme.secondary.withOpacity(0.18);
    final Paint activeCluePaint = Paint()..color = theme.colorScheme.primary.withOpacity(0.18);
    final Paint activeCellPaint = Paint()..color = theme.colorScheme.primary.withOpacity(0.28);
    final radius = BorderRadius.circular(6);
    final highlightErrors = game.highlightErrors;
    final activeCell = activeClue != null && activeClue!.cells.isNotEmpty
        ? activeClue!.cells[game.activeCellIndex.clamp(0, activeClue!.cells.length - 1)]
        : null;

    for (var row = 0; row < puzzle.height; row++) {
      for (var col = 0; col < puzzle.width; col++) {
        final coord = Coord(row, col);
        final rect = Rect.fromLTWH(col * cellWidth, row * cellHeight, cellWidth, cellHeight);
        final rrect = radius.toRRect(rect.inflate(-1));
        final index = puzzle.indexOf(coord);
        final cell = puzzle.cells[index];

        if (cell.type == CellType.block) {
          canvas.drawRRect(rrect, blockPaint);
          continue;
        }

        if (activeClue != null && activeClue!.cells.contains(coord)) {
          canvas.drawRRect(rrect, activeCluePaint);
        } else if (cell.type == CellType.clue) {
          canvas.drawRRect(rrect, cluePaint);
        } else {
          canvas.drawRRect(rrect, Paint()..color = theme.colorScheme.surface);
        }

        if (activeCell != null && coord == activeCell) {
          canvas.drawRRect(rrect, activeCellPaint);
        }

        canvas.drawRRect(rrect, gridPaint);

        if (cell.type == CellType.clue) {
          _drawClueCell(canvas, rect, cell);
        } else if (cell.type == CellType.letter) {
          final letter = game.boardLetters[index];
          if (letter.isNotEmpty) {
            final correct = cell.solution == null || cell.solution!.isEmpty
                ? true
                : letter.toUpperCase() == cell.solution;
            final textPainter = TextPainter(
              text: TextSpan(
                text: letter,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: cell.isGiven ? FontWeight.bold : FontWeight.w600,
                  color: !correct && highlightErrors ? theme.colorScheme.error : theme.colorScheme.onSurface,
                ),
              ),
              textDirection: TextDirection.ltr,
            )..layout();
            textPainter.paint(
              canvas,
              Offset(
                rect.left + (cellWidth - textPainter.width) / 2,
                rect.top + (cellHeight - textPainter.height) / 2,
              ),
            );
          }

          final notes = game.pencilNotes[index];
          if (notes != null && notes.isNotEmpty) {
            final noteText = notes.join(' ');
            final notePainter = TextPainter(
              text: TextSpan(
                text: noteText,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.hintColor),
              ),
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: cellWidth - 4);
            notePainter.paint(canvas, Offset(rect.left + 4, rect.top + 4));
          }
        }
      }
    }
  }

  void _drawClueCell(Canvas canvas, Rect rect, Cell cell) {
    if (cell.clue == null) {
      return;
    }
    final arrowPainter = TextPainter(
      text: TextSpan(
        text: cell.clue!.direction.arrowChar,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    arrowPainter.paint(canvas, Offset(rect.left + 4, rect.top + 4));

    final textPainter = TextPainter(
      text: TextSpan(
        text: cell.clue!.text,
        style: const TextStyle(fontSize: 11, height: 1.2),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 8);
    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top + (rect.height - textPainter.height) / 2 + 6,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _PuzzlePainter oldDelegate) {
    return oldDelegate.game != game || oldDelegate.activeClue?.id != activeClue?.id;
  }
}
