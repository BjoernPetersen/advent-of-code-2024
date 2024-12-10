import 'package:aoc_core/aoc_core.dart';

@immutable
final class PartOne extends IntPart {
  const PartOne();

  int _countXmas(Grid<String> grid, Vector xPosition) {
    var sum = 0;
    for (final direction in Vector.starDirections) {
      final word = StringBuffer();
      for (var scalar = 1; scalar <= 3; ++scalar) {
        final position = xPosition + (direction * scalar);
        if (!grid.contains(position)) {
          // Could even continue outer loop here, but meh
          break;
        }
        word.write(grid[position]);
      }

      if (word.toString() == 'MAS') {
        sum += 1;
      }
    }
    return sum;
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await Grid.fromStream(input, (_, c) => c);
    var sum = 0;
    for (final position in grid.positions) {
      if (grid[position] == 'X') {
        sum += _countXmas(grid, position);
      }
    }
    return sum;
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
    final grid = await Grid.fromStream(input, (_, c) => c);
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
