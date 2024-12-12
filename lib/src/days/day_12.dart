import 'package:aoc_core/aoc_core.dart';

int _calculateRegionPerimeter({
  required Grid<String> grid,
  required Set<Vector> visited,
  required Vector initialPosition,
}) {
  if (!visited.add(initialPosition)) {
    return 0;
  }

  var perimeter = 0;
  final char = grid[initialPosition];
  for (final direction in Vector.crossDirections) {
    final position = initialPosition + direction;
    if (visited.contains(position)) {
      continue;
    }

    if (!grid.contains(position) || grid[position] != char) {
      perimeter += 1;
      continue;
    }

    perimeter += _calculateRegionPerimeter(
      grid: grid,
      visited: visited,
      initialPosition: position,
    );
  }

  return perimeter;
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await Grid.fromStream(input, (_, char) => char);
    final globalVisited = <Vector>{};
    return grid.positions.map((pos) {
      if (globalVisited.contains(pos)) {
        return 0;
      }

      final visited = <Vector>{};
      final perimeter = _calculateRegionPerimeter(
        grid: grid,
        visited: visited,
        initialPosition: pos,
      );
      final area = visited.length;
      globalVisited.addAll(visited);
      return area * perimeter;
    }).sum;
  }
}

Iterable<Vector> _visitRegion({
  required Grid<String> grid,
  required Vector position,
  required Set<Vector> visited,
}) sync* {
  if (!visited.add(position)) {
    return;
  }

  yield position;

  final char = grid[position];
  for (final direction in Vector.crossDirections) {
    final neighbor = position + direction;
    if (!grid.contains(neighbor)) {
      continue;
    }

    if (grid[neighbor] == char) {
      yield* _visitRegion(
        grid: grid,
        position: neighbor,
        visited: visited,
      );
    }
  }
}

int _visitHorizontalSides({
  required Grid<String> grid,
  required Set<(Vector, Vector)> edges,
  required Vector position,
}) {
  var sides = 0;
  final char = grid[position];
  for (final edgeDirection in const [Vector.north, Vector.south]) {
    final acrossEdge = position + edgeDirection;
    if (grid.contains(acrossEdge) && grid[acrossEdge] == char) {
      // Not actually an edge.
      continue;
    }

    if (!edges.add((position, edgeDirection))) {
      // Already been here
      continue;
    }

    sides += 1;

    // No go left and right until there's no more edge
    for (final neighborDirection in const [Vector.west, Vector.east]) {
      var neighbor = position + neighborDirection;

      while (grid.contains(neighbor) &&
          grid[neighbor] == char &&
          (!grid.contains(neighbor + edgeDirection) ||
              grid[neighbor + edgeDirection] != char)) {
        edges.add((neighbor, edgeDirection));
        neighbor += neighborDirection;
      }
    }
  }

  return sides;
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final grid = await Grid.fromStream(input, (_, char) => char);
    final globalVisited = <Vector>{};
    return grid.positions.map((initialPosition) {
      if (globalVisited.contains(initialPosition)) {
        return 0;
      }

      final preSize = globalVisited.length;
      final edges = <(Vector, Vector)>{};
      var horizontalSides = 0;
      for (final position in _visitRegion(
        grid: grid,
        position: initialPosition,
        visited: {},
      )) {
        globalVisited.add(position);
        horizontalSides += _visitHorizontalSides(
          grid: grid,
          position: position,
          edges: edges,
        );
      }

      final area = globalVisited.length - preSize;

      // The amount of horizontal sides is equal to the amount of vertical sides
      return area * horizontalSides * 2;
    }).sum;
  }
}
