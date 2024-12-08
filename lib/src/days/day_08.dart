import 'package:aoc_core/aoc_core.dart';

final class Field {
  final String? antenna;
  final List<String> _antinodes;

  Field({required this.antenna}) : _antinodes = [];

  void addAntinode(String frequency) {
    if (!_antinodes.contains(frequency)) {
      _antinodes.add(frequency);
    }
  }

  bool get hasAntinode => _antinodes.isNotEmpty;
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

    for (final entry in antennaPositions.entries) {
      addAntinodes(grid, entry.key, entry.value);
    }

    return grid.squares.where((f) => f.hasAntinode).count;
  }

  void addAntinodes(
    Grid<Field> grid,
    String frequency,
    List<Vector> antennaPositions,
  ) {
    for (final (antennaA, antennaB) in antennaPositions.pairings) {
      final antinodes = [
        antennaA - (antennaB - antennaA),
        antennaB - (antennaA - antennaB),
      ];
      for (final antinode in antinodes) {
        if (grid.contains(antinode)) {
          grid[antinode].addAntinode(frequency);
        }
      }
    }
  }
}

Future<(Grid<Field>, Map<String, List<Vector>>)> _parseGrid(
    Stream<String> input) async {
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
