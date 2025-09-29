import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class Coord {
  const Coord(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Coord && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);
}

enum CellType { clue, letter, block }

enum ArrowDirection { n, ne, e, se, s, sw, w, nw }

extension ArrowDirectionX on ArrowDirection {
  Coord get delta {
    switch (this) {
      case ArrowDirection.n:
        return const Coord(-1, 0);
      case ArrowDirection.ne:
        return const Coord(-1, 1);
      case ArrowDirection.e:
        return const Coord(0, 1);
      case ArrowDirection.se:
        return const Coord(1, 1);
      case ArrowDirection.s:
        return const Coord(1, 0);
      case ArrowDirection.sw:
        return const Coord(1, -1);
      case ArrowDirection.w:
        return const Coord(0, -1);
      case ArrowDirection.nw:
        return const Coord(-1, -1);
    }
  }

  String get arrowChar {
    switch (this) {
      case ArrowDirection.n:
        return '↑';
      case ArrowDirection.ne:
        return '↗';
      case ArrowDirection.e:
        return '→';
      case ArrowDirection.se:
        return '↘';
      case ArrowDirection.s:
        return '↓';
      case ArrowDirection.sw:
        return '↙';
      case ArrowDirection.w:
        return '←';
      case ArrowDirection.nw:
        return '↖';
    }
  }

  static ArrowDirection fromString(String value) {
    switch (value.toUpperCase()) {
      case 'N':
        return ArrowDirection.n;
      case 'NE':
        return ArrowDirection.ne;
      case 'E':
        return ArrowDirection.e;
      case 'SE':
        return ArrowDirection.se;
      case 'S':
        return ArrowDirection.s;
      case 'SW':
        return ArrowDirection.sw;
      case 'W':
        return ArrowDirection.w;
      case 'NW':
        return ArrowDirection.nw;
      default:
        throw ArgumentError('Unsupported direction $value');
    }
  }
}

@immutable
class ClueMeta {
  const ClueMeta({
    required this.direction,
    required this.text,
  });

  final ArrowDirection direction;
  final String text;

  Map<String, dynamic> toJson() => {
        'direction': describeEnum(direction).toUpperCase(),
        'text': text,
      };
}

@immutable
class Cell {
  const Cell({
    required this.type,
    this.solution,
    this.clue,
    this.isGiven = false,
  });

  final CellType type;
  final String? solution;
  final ClueMeta? clue;
  final bool isGiven;

  Map<String, dynamic> toJson() {
    switch (type) {
      case CellType.block:
        return {'type': 'BLOCK'};
      case CellType.letter:
        return {
          'type': 'LETTER',
          if (solution != null) 'solution': solution,
          if (isGiven) 'given': true,
        };
      case CellType.clue:
        return {
          'type': 'CLUE',
          'arrow': describeEnum(clue!.direction).toUpperCase(),
          'text': clue!.text,
        };
    }
  }
}

@immutable
class Clue {
  const Clue({
    required this.id,
    required this.arrowCell,
    required this.direction,
    required this.text,
    required this.cells,
  });

  final String id;
  final Coord arrowCell;
  final ArrowDirection direction;
  final String text;
  final List<Coord> cells;

  int get length => cells.length;
}

@immutable
class Puzzle {
  const Puzzle({
    required this.id,
    required this.title,
    required this.author,
    required this.width,
    required this.height,
    required this.cells,
    required this.clues,
  });

  final String id;
  final String title;
  final String author;
  final int width;
  final int height;
  final List<Cell> cells;
  final List<Clue> clues;

  int indexOf(Coord coord) => coord.row * width + coord.col;
}

@immutable
class PuzzleSummary {
  const PuzzleSummary({
    required this.id,
    required this.title,
    required this.author,
    required this.width,
    required this.height,
    this.isDaily = false,
    this.isImported = false,
  });

  final String id;
  final String title;
  final String author;
  final int width;
  final int height;
  final bool isDaily;
  final bool isImported;
}

class GameState {
  GameState({
    required this.puzzleId,
    required this.boardLetters,
    required this.pencilNotes,
    required this.hintsLeft,
    required this.mistakes,
    required this.elapsedSeconds,
    required this.autoCheck,
    required this.highlightErrors,
    required this.activeClueId,
    required this.activeCellIndex,
    required this.solvedClueIds,
    required this.pencilMode,
    required this.completed,
  });

  factory GameState.initial({
    required Puzzle puzzle,
    required int hints,
    bool autoCheck = false,
    bool highlightErrors = true,
  }) {
    return GameState(
      puzzleId: puzzle.id,
      boardLetters: List.filled(puzzle.cells.length, ''),
      pencilNotes: <int, Set<String>>{},
      hintsLeft: hints,
      mistakes: 0,
      elapsedSeconds: 0,
      autoCheck: autoCheck,
      highlightErrors: highlightErrors,
      activeClueId: puzzle.clues.isEmpty ? null : puzzle.clues.first.id,
      activeCellIndex: 0,
      solvedClueIds: <String>{},
      pencilMode: false,
      completed: false,
    );
  }

  final String puzzleId;
  final List<String> boardLetters;
  final Map<int, Set<String>> pencilNotes;
  final int hintsLeft;
  final int mistakes;
  final int elapsedSeconds;
  final bool autoCheck;
  final bool highlightErrors;
  final String? activeClueId;
  final int activeCellIndex;
  final Set<String> solvedClueIds;
  final bool pencilMode;
  final bool completed;

  GameState copyWith({
    List<String>? boardLetters,
    Map<int, Set<String>>? pencilNotes,
    int? hintsLeft,
    int? mistakes,
    int? elapsedSeconds,
    bool? autoCheck,
    bool? highlightErrors,
    String? activeClueId,
    int? activeCellIndex,
    Set<String>? solvedClueIds,
    bool? pencilMode,
    bool? completed,
  }) {
    return GameState(
      puzzleId: puzzleId,
      boardLetters: boardLetters ?? this.boardLetters,
      pencilNotes: pencilNotes ?? this.pencilNotes,
      hintsLeft: hintsLeft ?? this.hintsLeft,
      mistakes: mistakes ?? this.mistakes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      autoCheck: autoCheck ?? this.autoCheck,
      highlightErrors: highlightErrors ?? this.highlightErrors,
      activeClueId: activeClueId ?? this.activeClueId,
      activeCellIndex: activeCellIndex ?? this.activeCellIndex,
      solvedClueIds: solvedClueIds ?? this.solvedClueIds,
      pencilMode: pencilMode ?? this.pencilMode,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'puzzleId': puzzleId,
        'boardLetters': boardLetters,
        'pencilNotes': pencilNotes.map((key, value) => MapEntry('$key', value.toList())),
        'hintsLeft': hintsLeft,
        'mistakes': mistakes,
        'elapsedSeconds': elapsedSeconds,
        'autoCheck': autoCheck,
        'highlightErrors': highlightErrors,
        'activeClueId': activeClueId,
        'activeCellIndex': activeCellIndex,
        'solvedClueIds': solvedClueIds.toList(),
        'pencilMode': pencilMode,
        'completed': completed,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      puzzleId: json['puzzleId'] as String,
      boardLetters: (json['boardLetters'] as List<dynamic>).cast<String>(),
      pencilNotes: (json['pencilNotes'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(int.parse(key), (value as List<dynamic>).cast<String>().toSet()),
      ),
      hintsLeft: json['hintsLeft'] as int,
      mistakes: json['mistakes'] as int,
      elapsedSeconds: json['elapsedSeconds'] as int,
      autoCheck: json['autoCheck'] as bool,
      highlightErrors: json['highlightErrors'] as bool,
      activeClueId: json['activeClueId'] as String?,
      activeCellIndex: json['activeCellIndex'] as int,
      solvedClueIds: (json['solvedClueIds'] as List<dynamic>).cast<String>().toSet(),
      pencilMode: json['pencilMode'] as bool,
      completed: json['completed'] as bool,
    );
  }

  String encode() => jsonEncode(toJson());

  static GameState decode(String encoded) {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return GameState.fromJson(map);
  }
}
