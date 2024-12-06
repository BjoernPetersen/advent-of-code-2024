import 'package:aoc_core/aoc_core.dart';
import 'package:squadron/squadron.dart';

import 'solver_day_6.activator.g.dart';

part 'solver_day_6.worker.g.dart';

@immutable
final class VectorListMarshaller
    implements SquadronMarshaler<List<Vector>, List<int>> {
  const VectorListMarshaller();

  @override
  List<int> marshal(List<Vector> data) => [
        // Pack both values into a singe int
        for (final v in data) (v.x << 8) + v.y,
      ];

  @override
  List<Vector> unmarshal(List<int> data) => [
        for (final i in data)
          Vector(
            x: i >> 8,
            y: i & 0xFF,
          )
      ];
}

@SquadronService(baseUrl: '~/workers')
base class Solver {
  late final Grid<Square> grid;
  late final Vector startPosition;

  @SquadronMethod()
  Future<void> initialize(List<String> input) async {
    final (grid, startPosition) = await readInput(Stream.fromIterable(input));
    this.grid = grid;
    this.startPosition = startPosition;
  }

  @SquadronMethod()
  Future<int> solve(
    @VectorListMarshaller() List<Vector> addedObstructionPositions,
  ) async {
    final grid = this.grid;
    var count = 0;
    for (final addedObstructionPosition in addedObstructionPositions) {
      final square = grid[addedObstructionPosition];
      grid[addedObstructionPosition] = square.withObstruction();
      if (!walkGrid(grid, startPosition)) {
        count += 1;
      }
      grid[addedObstructionPosition] = square;
    }
    return count;
  }
}

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
