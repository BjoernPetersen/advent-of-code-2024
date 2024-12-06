import 'package:aoc_core/aoc_core.dart';

@immutable
final class Square {
  final Vector position;
  final bool isObstruction;
  final bool isVisited;

  Square._({
    required this.position,
    required this.isObstruction,
    required this.isVisited,
  });

  factory Square({
    required Vector position,
    required bool isObstruction,
  }) {
    return Square._(
      position: position,
      isObstruction: isObstruction,
      isVisited: false,
    );
  }

  Square withObstruction() {
    if (isVisited) {
      throw StateError('Was already visited');
    }
    return Square(
      position: position,
      isObstruction: true,
    );
  }

  Square visit() {
    if (isObstruction) {
      throw StateError("Can't be visited");
    }
    return Square._(
      position: position,
      isObstruction: isObstruction,
      isVisited: true,
    );
  }
}

Future<(Grid<Square>, Vector)> readInput(Stream<String> input) async {
  final rows = <List<Square>>[];
  late final Vector startingPoint;
  await for (final line in input) {
    final row = <Square>[];
    for (final (x, char) in line.chars.indexed) {
      final position = Vector(x: x, y: rows.length);
      row.add(Square(
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

bool walkGrid(
  Grid<Square> grid,
  Vector start, {
  bool markVisitedSquares = false,
}) {
  var position = start;
  var direction = Vector.north;
  final seen = <(Vector, Vector)>{};
  while (grid.contains(position)) {
    if (!seen.add((position, direction))) {
      // loop detected
      return false;
    }

    if (markVisitedSquares) {
      grid.update(position, (s) => s.visit());
    }

    Vector nextPosition;
    while (grid.contains(nextPosition = position + direction) &&
        grid[nextPosition].isObstruction) {
      direction = direction.rotate(clockwise: true);
    }

    position = nextPosition;
  }

  return true;
}
