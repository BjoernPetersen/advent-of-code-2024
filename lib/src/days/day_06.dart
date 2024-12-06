import 'package:aoc_core/aoc_core.dart';

final class Location {
  final Vector position;
  final bool isObstruction;
  bool isVisited = false;

  Location({
    required this.position,
    required this.isObstruction,
  });
}

Future<(Grid<Location>, Vector)> _readInput(Stream<String> input) async {
  final rows = <List<Location>>[];
  late final Vector startingPoint;
  await for (final line in input) {
    final row = <Location>[];
    for (final (x, char) in line.chars.indexed) {
      final position = Vector(x: x, y: rows.length);
      row.add(Location(
        position: position,
        isObstruction: char == '#',
      ));

      if (char == '^') {
        startingPoint = position;
      }
    }

    rows.add(row);
  }

  return (Grid(rows), startingPoint);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, start) = await _readInput(input);
    _walkGrid(grid, start);
    return grid.squares.where((l) => l.isVisited).count;
  }

  void _walkGrid(Grid<Location> grid, Vector start) {
    var position = start;
    var direction = Vector.north;
    while (grid.contains(position)) {
      final location = grid[position];
      location.isVisited = true;

      Vector nextPosition;
      while (grid.contains(nextPosition = position + direction) &&
          grid[nextPosition].isObstruction) {
        direction = direction.rotate(clockwise: true);
      }

      position = nextPosition;
    }
  }
}
