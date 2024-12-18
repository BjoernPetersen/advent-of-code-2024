import 'dart:collection';

import 'package:aoc_core/aoc_core.dart';

Vector _parsePosition(String line) {
  final parts = line.split(',');
  return Vector(
    x: int.parse(parts[0]),
    y: int.parse(parts[1]),
  );
}

(int, List<Vector>) _findShortestPath(
  Grid<bool> memory, {
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
        .where((e) => memory.contains(e) && !memory[e])) {
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
    int memorySize = 71,
    int byteCount = 1024,
  }) async {
    final memory = Grid.generate(
      width: memorySize,
      height: memorySize,
      generator: (pos) => false,
    );
    await for (final bytePosition
        in input.map(_parsePosition).take(byteCount)) {
      memory[bytePosition] = true;
    }

    final (steps, _) = _findShortestPath(
      memory,
      start: Vector.zero,
      end: memory.bounds.bottomRight,
    );

    return steps;
  }
}

@immutable
final class PartTwo extends StringPart {
  const PartTwo();

  @override
  Future<String> calculate(
    Stream<String> input, {
    int memorySize = 71,
  }) async {
    final bytePositions = await input.map(_parsePosition).toList();

    var left = 0;
    var right = bytePositions.length - 1;
    while (left + 1 != right) {
      var current = left + ((right - left) ~/ 2);
      final memory = Grid.generate(
        width: memorySize,
        height: memorySize,
        generator: (pos) => false,
      );
      for (final bytePosition in bytePositions.take(current + 1)) {
        memory[bytePosition] = true;
      }

      final (steps, _) = _findShortestPath(
        memory,
        start: Vector.zero,
        end: memory.bounds.bottomRight,
      );

      if (steps == -1) {
        right = current;
      } else {
        left = current;
      }
    }

    final firstFail = bytePositions[right];
    return '${firstFail.x},${firstFail.y}';
  }
}
