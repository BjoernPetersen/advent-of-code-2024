import 'package:aoc_core/aoc_core.dart';

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
    final (bounds, antennaPositions) = await _parseInput(input);

    final antinodes = <Vector>{};
    for (final positions in antennaPositions.values) {
      addAntinodes(bounds, antinodes, positions);
    }

    return antinodes.length;
  }

  void addAntinodes(
    Bounds bounds,
    Set<Vector> antinodes,
    List<Vector> antennaPositions,
  ) {
    for (final (antennaA, antennaB) in antennaPositions.pairings) {
      final distance = antennaB - antennaA;
      for (final offset in [-distance, distance * 2]) {
        final antinode = antennaA + offset;
        if (bounds.contains(antinode)) {
          antinodes.add(antinode);
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
    final (bounds, antennaPositions) = await _parseInput(input);

    final antinodes = <Vector>{};
    for (final positions in antennaPositions.values) {
      addAntinodes(bounds, antinodes, positions);
    }

    return antinodes.length;
  }

  void addAntinodes(
    Bounds bounds,
    Set<Vector> antinodes,
    List<Vector> antennaPositions,
  ) {
    for (final (antennaA, antennaB) in antennaPositions.pairings) {
      final distance = antennaB - antennaA;

      for (final direction in [distance, -distance]) {
        Vector position = antennaA;
        while (bounds.contains(position)) {
          antinodes.add(position);
          position += direction;
        }
      }
    }
  }
}

Future<(Bounds, Map<String, List<Vector>>)> _parseInput(
  Stream<String> input,
) async {
  var width = 0;
  final antennaPositions = <String, List<Vector>>{};

  var y = 0;
  await for (final line in input) {
    width = line.length;

    for (final (x, char) in line.chars.indexed) {
      if (char != '.') {
        final position = Vector(x: x, y: y);
        antennaPositions.putIfAbsent(char, () => []).add(position);
      }
    }

    y += 1;
  }

  return (Bounds(width: width, height: y), antennaPositions);
}
