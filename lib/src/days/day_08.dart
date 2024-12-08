import 'package:aoc_core/aoc_core.dart';

final class Field {
  final String? antenna;
  bool _hasAntinode;

  Field({required this.antenna}) : _hasAntinode = false;

  void addAntinode() {
    _hasAntinode = true;
  }

  bool get hasAntinode => _hasAntinode;
}

extension Pairs<T> on List<T> {
  Iterable<(T, T)> get pairings sync* {
    for (var leftIndex = 0; leftIndex < length - 1; ++leftIndex) {
      final left = this[leftIndex];
      for (var rightIndex = leftIndex + 1; rightIndex < length; ++rightIndex) {
        yield (left, this[rightIndex]);
      }
    }
  }
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, antennaPositions) = await _parseGrid(input);

    for (final positions in antennaPositions.values) {
      addAntinodes(grid, positions);
    }

    return grid.squares.where((f) => f.hasAntinode).count;
  }

  void addAntinodes(
    Grid<Field> grid,
    List<Vector> antennaPositions,
  ) {
    for (final (antennaA, antennaB) in antennaPositions.pairings) {
      final distance = antennaB - antennaA;
      for (final offset in [-distance, distance * 2]) {
        final antinode = antennaA + offset;
        if (grid.contains(antinode)) {
          grid[antinode].addAntinode();
        }
      }
    }
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, antennaPositions) = await _parseGrid(input);

    for (final positions in antennaPositions.values) {
      addAntinodes(grid, positions);
    }

    return grid.squares.where((f) => f.hasAntinode).count;
  }

  void addAntinodes(
    Grid<Field> grid,
    List<Vector> antennaPositions,
  ) {
    for (final (antennaA, antennaB) in antennaPositions.pairings) {
      final distance = antennaB - antennaA;

      for (final direction in [distance, -distance]) {
        Vector position = antennaA;
        while (grid.contains(position)) {
          grid[position].addAntinode();
          position += direction;
        }
      }
    }
  }
}

Future<(Grid<Field>, Map<String, List<Vector>>)> _parseGrid(
  Stream<String> input,
) async {
  final rows = <List<Field>>[];
  final antennaPositions = <String, List<Vector>>{};
  await for (final line in input) {
    final row = <Field>[];
    for (final char in line.chars) {
      if (char == '.') {
        row.add(Field(antenna: null));
      } else {
        final position = Vector(x: row.length, y: rows.length);
        antennaPositions.putIfAbsent(char, () => []).add(position);
        row.add(Field(antenna: char));
      }
    }
    rows.add(row);
  }

  return (Grid(rows), antennaPositions);
}
