import 'dart:convert';

import 'entities.dart';

class PuzzleParser {
  const PuzzleParser();

  Puzzle parseFromString(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return parse(map);
  }

  Puzzle parse(Map<String, dynamic> map) {
    final width = map['width'] as int;
    final height = map['height'] as int;
    final cellsJson = map['cells'] as List<dynamic>;
    if (cellsJson.length != width * height) {
      throw FormatException('Cell count mismatch: expected ${width * height}, got ${cellsJson.length}');
    }
    final cells = <Cell>[];
    for (final cellJson in cellsJson) {
      final typed = cellJson as Map<String, dynamic>;
      final type = (typed['type'] as String).toUpperCase();
      switch (type) {
        case 'CLUE':
          final arrow = ArrowDirectionX.fromString(typed['arrow'] as String);
          final text = typed['text'] as String;
          cells.add(Cell(
            type: CellType.clue,
            clue: ClueMeta(direction: arrow, text: text),
          ));
          break;
        case 'LETTER':
          final solution = (typed['solution'] as String?)?.toUpperCase();
          final isGiven = typed['given'] == true;
          cells.add(Cell(
            type: CellType.letter,
            solution: solution,
            isGiven: isGiven,
          ));
          break;
        case 'BLOCK':
          cells.add(const Cell(type: CellType.block));
          break;
        default:
          throw FormatException('Unknown cell type $type');
      }
    }

    final clues = _buildClues(cells, width, height);
    return Puzzle(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      width: width,
      height: height,
      cells: cells,
      clues: clues,
    );
  }

  List<Clue> _buildClues(List<Cell> cells, int width, int height) {
    final clues = <Clue>[];
    for (var index = 0; index < cells.length; index++) {
      final cell = cells[index];
      if (cell.type != CellType.clue) {
        continue;
      }
      final row = index ~/ width;
      final col = index % width;
      final arrow = cell.clue!.direction;
      final positions = _collectCells(cells, width, height, row, col, arrow);
      final id = 'clue_${row}_$col';
      clues.add(Clue(
        id: id,
        arrowCell: Coord(row, col),
        direction: arrow,
        text: cell.clue!.text,
        cells: positions,
      ));
    }
    return clues;
  }

  List<Coord> _collectCells(
    List<Cell> cells,
    int width,
    int height,
    int row,
    int col,
    ArrowDirection direction,
  ) {
    final coords = <Coord>[];
    var currentRow = row + direction.delta.row;
    var currentCol = col + direction.delta.col;
    while (currentRow >= 0 && currentRow < height && currentCol >= 0 && currentCol < width) {
      final currentIndex = currentRow * width + currentCol;
      final cell = cells[currentIndex];
      if (cell.type == CellType.block || cell.type == CellType.clue) {
        break;
      }
      coords.add(Coord(currentRow, currentCol));
      currentRow += direction.delta.row;
      currentCol += direction.delta.col;
    }
    return coords;
  }
}

String? expectedLetter(Puzzle puzzle, Coord coord) {
  final index = puzzle.indexOf(coord);
  final cell = puzzle.cells[index];
  if (cell.type != CellType.letter) {
    return null;
  }
  return cell.solution;
}

bool checkLetter(Puzzle puzzle, Coord coord, String candidate) {
  final solution = expectedLetter(puzzle, coord);
  if (solution == null || solution.isEmpty) {
    return true;
  }
  return solution == candidate.toUpperCase();
}

bool checkWord(Puzzle puzzle, Clue clue, List<String> letters) {
  if (letters.length != clue.length) {
    return false;
  }
  for (var i = 0; i < clue.cells.length; i++) {
    final solution = expectedLetter(puzzle, clue.cells[i]) ?? '';
    if (solution.isEmpty) {
      continue;
    }
    if (letters[i].toUpperCase() != solution) {
      return false;
    }
  }
  return true;
}

bool isClueSolved(Puzzle puzzle, Clue clue, List<String> boardLetters) {
  final letters = <String>[];
  for (final coord in clue.cells) {
    final index = puzzle.indexOf(coord);
    letters.add(boardLetters[index]);
  }
  return checkWord(puzzle, clue, letters);
}
