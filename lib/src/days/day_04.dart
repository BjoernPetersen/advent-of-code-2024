import 'package:aoc_core/aoc_core.dart';

Future<Grid<String>> _buildGrid(Stream<String> input) async {
  final rows = <List<String>>[];
  await for (final line in input) {
    rows.add(line.chars.toList(growable: false));
  }
  return Grid(rows);
}

extension Diagnoals<T> on Grid<T> {
  Iterable<Vector> _line({
    required Vector start,
    required Vector direction,
  }) sync* {
    var current = start;
    while (contains(current)) {
      yield current;
      current += direction;
    }
  }

  Iterable<Iterable<T>> get diagonals sync* {
    final List<(Vector, Vector)> startPoints;
    if (width >= height) {
      // search along the top and bottom
      startPoints = [
        (Vector.zero, Vector(x: 1, y: 0)),
        (Vector(x: width - 1, y: height - 1), Vector(x: -1, y: 0)),
      ];
    } else {
      // search along left and right
      startPoints = [
        (Vector(x: 0, y: height - 1), Vector(x: 0, y: -1)),
        (Vector(x: width - 1, y: 0), Vector(x: 0, y: 1)),
      ];
    }

    for (final (startPoint, startDirection) in startPoints) {
      final inwards = startDirection.rotate(clockwise: true);
      for (final start in _line(start: startPoint, direction: startDirection)) {
        if (width == height &&
            (start == Vector.zero || start == Vector(x: width - 1))) {
          // In case of a square, we don't want to count these twice
          continue;
        }

        for (final diagonalDirection in [
          inwards - startDirection,
          inwards + startDirection
        ]) {
          yield _line(
            start: start,
            direction: diagonalDirection,
          ).map((p) => this[p]);
        }
      }
    }
  }
}

@immutable
final class PartOne extends IntPart {
  static const searched = 'XMAS';
  static const reverseSearched = 'SAMX';

  const PartOne();

  int countMatches(Iterable<String> line) {
    var sum = 0;
    // naive string search let's gooo
    final list = line.toList(growable: false);
    for (var index = 0; index < list.length - 3; ++index) {
      final candidate = list.sublist(index, index + 4).join();
      if (candidate == searched || candidate == reverseSearched) {
        sum += 1;
      }
    }

    return sum;
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await _buildGrid(input);
    final matches = [
      for (final row in grid.rows) countMatches(row),
      for (final column in grid.columns) countMatches(column),
      for (final diagonal in grid.diagonals) countMatches(diagonal),
    ];
    return matches.sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  bool _isMas(
    Grid<String> grid, {
    required Vector aPoint,
    required Vector direction,
  }) {
    final letters = {grid[aPoint + direction], grid[aPoint - direction]};
    return const DeepCollectionEquality().equals(letters, const {'M', 'S'});
  }

  bool _isXmas(Grid<String> grid, Vector aPoint) {
    final direction = Vector(x: 1, y: 1);
    return _isMas(grid, aPoint: aPoint, direction: direction) &&
        _isMas(grid, aPoint: aPoint, direction: direction.rotate());
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await _buildGrid(input);
    var sum = 0;
    for (var y = 1; y < grid.height - 1; ++y) {
      for (var x = 1; x < grid.width - 1; ++x) {
        final point = Vector(x: x, y: y);
        if (grid[point] == 'A') {
          if (_isXmas(grid, point)) {
            sum += 1;
          }
        }
      }
    }
    return sum;
  }
}
