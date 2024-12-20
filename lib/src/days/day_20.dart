import 'dart:collection';

import 'package:aoc_core/aoc_core.dart';

(int, List<Vector>) _findShortestPath(
  Grid<bool> grid, {
  required final Vector start,
  required final Vector end,
}) {
  var current = start;
  final costs = {current: 0};
  final predecessors = <Vector, Vector>{};
  final visited = {current};

  final unvisited = SplayTreeSet<(Vector, {int cost})>((a, b) {
    final comparison = a.cost.compareTo(b.cost);
    if (comparison == 0 && a != b) {
      return 1;
    }
    return comparison;
  });

  var currentCost = 0;
  while (current != end) {
    for (final neighbor in Vector.crossDirections
        .map((d) => current + d)
        .where((e) => grid.contains(e) && !grid[e])) {
      if (visited.contains(neighbor)) {
        continue;
      }

      final neighborCost = currentCost + 1;
      final previousCost = costs[neighbor];
      if (previousCost == null || neighborCost < previousCost) {
        if (previousCost != null) {
          unvisited.remove((neighbor, cost: previousCost));
        }

        costs[neighbor] = neighborCost;
        predecessors[neighbor] = current;
        unvisited.add((neighbor, cost: neighborCost));
      }
    }

    final next = unvisited.firstOrNull;
    if (next == null) {
      return (-1, const []);
    }
    (current, cost: currentCost) = next;
    unvisited.remove(next);
  }

  final path = [current];
  while (current != start) {
    current = predecessors[current]!;
    path.add(current);
  }

  return (currentCost, path);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(
    Stream<String> input, {
    int countThreshold = 100,
  }) async {
    late final Vector start;
    late final Vector end;
    final grid = await Grid.fromStream(input, (pos, char) {
      switch (char) {
        case '.':
          return false;
        case '#':
          return true;
        case 'S':
          start = pos;
          return false;
        case 'E':
          end = pos;
          return false;
        case _:
          throw ArgumentError.value(char, 'char', 'Unrecognized char on map');
      }
    });

    final (vanillaCost, vanillaPath) = _findShortestPath(
      grid,
      start: start,
      end: end,
    );
    print('Vanilla path costs $vanillaCost');
    final cheatScores = <Vector, int>{};

    for (final (index, pathField) in vanillaPath.reversed.indexed) {
      if (index % 500 == 0) {
        print('Checking path segment $index');
      }
      for (final neighbor in Vector.crossDirections.map((d) => pathField + d)) {
        if (cheatScores.containsKey(neighbor)) {
          continue;
        }

        bool isDeadEnd = true;
        for (final next in Vector.crossDirections.map((d) => neighbor + d)) {
          if (next == pathField) {
            continue;
          }

          if (grid.contains(next) && !grid[next]) {
            isDeadEnd = false;
          }
        }

        if (isDeadEnd) {
          cheatScores[neighbor] = 0;
          continue;
        }

        if (!grid[neighbor]) {
          continue;
        }

        grid[neighbor] = false;
        final (cheatCost, _) =
            _findShortestPath(grid, start: pathField, end: end);
        grid[neighbor] = true;

        final cheatScore = vanillaCost - (cheatCost + index);
        cheatScores[neighbor] = cheatScore;
      }
    }

    return cheatScores.values.where((s) => s >= countThreshold).count;
  }
}
