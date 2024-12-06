import 'package:aoc_core/aoc_core.dart';
import 'package:squadron/squadron.dart';

import 'solver_day_6.activator.g.dart';

part 'solver_day_6.worker.g.dart';

@immutable
final class VectorMarshaller implements SquadronMarshaler<Vector, List<int>> {
  const VectorMarshaller();

  @override
  List<int> marshal(Vector data) => [data.x, data.y];

  @override
  Vector unmarshal(List<int> data) => Vector(x: data[0], y: data[1]);
}

@SquadronService(baseUrl: '~/workers')
base class Solver {
  late final Grid<Location> grid;
  late final Vector startPosition;

  @SquadronMethod()
  Future<void> initialize(List<String> input) async {
    final (grid, startPosition) = await readInput(Stream.fromIterable(input));
    this.grid = grid;
    this.startPosition = startPosition;
  }

  @SquadronMethod()
  Future<bool> solve(
    @VectorMarshaller() Vector addedObstructionPosition,
  ) async {
    final grid = this.grid.clone();
    grid.update(addedObstructionPosition, (l) => l.withObstruction());
    return !walkGrid(grid, startPosition);
  }
}

@immutable
final class Location {
  final Vector position;
  final bool isObstruction;
  final bool isVisited;

  Location._({
    required this.position,
    required this.isObstruction,
    required this.isVisited,
  });

  factory Location({
    required Vector position,
    required bool isObstruction,
  }) {
    return Location._(
      position: position,
      isObstruction: isObstruction,
      isVisited: false,
    );
  }

  Location withObstruction() {
    if (isVisited) {
      throw StateError('Was already visited');
    }
    return Location(
      position: position,
      isObstruction: true,
    );
  }

  Location visit() {
    if (isObstruction) {
      throw StateError("Can't be visited");
    }
    return Location._(
      position: position,
      isObstruction: isObstruction,
      isVisited: true,
    );
  }
}

Future<(Grid<Location>, Vector)> readInput(Stream<String> input) async {
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

bool walkGrid(Grid<Location> grid, Vector start) {
  var position = start;
  var direction = Vector.north;
  final seen = <(Vector, Vector)>{};
  while (grid.contains(position)) {
    if (!seen.add((position, direction))) {
      // loop detected
      return false;
    }

    grid.update(position, (l) => l.visit());

    Vector nextPosition;
    while (grid.contains(nextPosition = position + direction) &&
        grid[nextPosition].isObstruction) {
      direction = direction.rotate(clockwise: true);
    }

    position = nextPosition;
  }

  return true;
}
