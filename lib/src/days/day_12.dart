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
