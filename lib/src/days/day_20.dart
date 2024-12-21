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

Iterable<Vector> _findCheatEnds(
  Grid<bool> grid, {
  required Set<Vector> path,
  required int maxDistance,
  required Vector start,
}) sync* {
  for (var x = 0; x <= maxDistance; x += 1) {
    for (var y = 0; y <= (maxDistance - x); y += 1) {
      final baseDiff = Vector(x: x, y: y);
      if (baseDiff == Vector.zero) {
        continue;
      }
      final diffs = [
        baseDiff,
        baseDiff.rotate(clockwise: true),
        -baseDiff,
        baseDiff.rotate(clockwise: false),
      ];
      for (final diff in diffs) {
        final neighbor = start + diff;
        if (path.contains(neighbor)) {
          yield neighbor;
        }
      }
    }
  }
}

Future<(Grid<bool>, {Vector start, Vector end})> _parseInput(
  Stream<String> input,
) async {
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

  return (grid, start: start, end: end);
}

Map<(Vector, Vector), int> _findCheats(
  Grid<bool> grid, {
  required Vector start,
  required Vector end,
  required List<Vector> vanillaPath,
  int maxDistance = 2,
}) {
  final cheatScores = <(Vector, Vector), int>{};
  final uniquePath = vanillaPath.toSet();

  for (final (index, pathField) in vanillaPath.indexed) {
    for (final otherPath in _findCheatEnds(
      grid,
      start: pathField,
      maxDistance: maxDistance,
      path: uniquePath,
    )) {
      if (cheatScores.containsKey((pathField, otherPath)) ||
          cheatScores.containsKey((otherPath, pathField))) {
        continue;
      }

      final Vector distance = otherPath - pathField;
      final cheatCost = distance.manhattanNorm();
      final previousCost = _findPathDistance(
        vanillaPath,
        start: index,
        minDistance: cheatCost,
        otherPath,
      );
      final cheatScore = previousCost - cheatCost;
      cheatScores[(pathField, otherPath)] = cheatScore;
    }
  }
  return cheatScores;
}

int _findPathDistance(
  List<Vector> path,
  Vector other, {
  required int start,
  required int minDistance,
}) {
  late final int otherIndex;
  for (var dist = minDistance; true; dist += 1) {
    final right = start + dist;
    if (right < path.length && path[right] == other) {
      otherIndex = right;
      break;
    }
    final left = start - dist;
    if (left >= 0 && path[left] == other) {
      otherIndex = left;
      break;
    }

    if (dist > path.length) {
      throw StateError('Could not find path distance');
    }
  }
  return (start - otherIndex).abs();
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(
    Stream<String> input, {
    int countThreshold = 100,
  }) async {
    final (grid, start: start, end: end) = await _parseInput(input);
    final (_, vanillaPath) = _findShortestPath(
      grid,
      start: start,
      end: end,
    );
    final cheatScores = _findCheats(
      grid,
      start: start,
      end: end,
      vanillaPath: vanillaPath.reversed.toList(growable: false),
    );
    return cheatScores.values.where((s) => s >= countThreshold).count;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(
    Stream<String> input, {
    int countThreshold = 100,
  }) async {
    final (grid, start: start, end: end) = await _parseInput(input);
    final (_, vanillaPath) = _findShortestPath(
      grid,
      start: start,
      end: end,
    );
    final cheatScores = _findCheats(
      grid,
      start: start,
      end: end,
      vanillaPath: vanillaPath,
      maxDistance: 20,
    );
    return cheatScores.values.where((s) => s >= countThreshold).count;
  }
}
