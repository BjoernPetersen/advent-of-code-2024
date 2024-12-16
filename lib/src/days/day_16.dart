import 'dart:collection';

import 'package:aoc_core/aoc_core.dart';

typedef ReindeerState = (Vector, {Vector face});

Iterable<(ReindeerState state, {int cost})> _edges(
  final Grid<bool> maze, {
  required final ReindeerState state,
}) sync* {
  final (position, face: face) = state;
  final forward = position + face;
  if (!maze[forward]) {
    yield ((forward, face: face), cost: 1);
  }

  final otherDirections = [
    (face.rotate(clockwise: true), 1001),
    (face.rotate(clockwise: false), 1001),
    (-face, 2001),
  ];

  for (final (direction, cost) in otherDirections) {
    final newPosition = position + direction;
    if (!maze[newPosition]) {
      yield ((newPosition, face: direction), cost: cost);
    }
  }
}

(int, List<ReindeerState>) _findShortestPath(
  Grid<bool> maze, {
  required final Vector start,
  required final Vector face,
  required final Vector end,
}) {
  var currentState = (start, face: face);
  final costs = {currentState: 0};
  final predecessors = <ReindeerState, ReindeerState>{};
  final visited = {currentState};

  final unvisited = SplayTreeSet<(ReindeerState, {int cost})>((a, b) {
    final comparison = a.cost.compareTo(b.cost);
    if (comparison == 0 && a != b) {
      return 1;
    }
    return comparison;
  });

  var currentCost = 0;
  while (currentState.$1 != end) {
    for (final (neighborState, cost: edgeCost)
        in _edges(maze, state: currentState)) {
      if (visited.contains(neighborState)) {
        continue;
      }

      final neighborCost = currentCost + edgeCost;
      final previousCost = costs[neighborState];
      if (previousCost == null || neighborCost < previousCost) {
        if (previousCost != null) {
          unvisited.remove((neighborState, cost: previousCost));
        }

        costs[neighborState] = neighborCost;
        predecessors[neighborState] = currentState;
        unvisited.add((neighborState, cost: neighborCost));
      }
    }

    final next = unvisited.first;
    (currentState, cost: currentCost) = next;
    unvisited.remove(next);
  }

  final path = <ReindeerState>[];
  for (ReindeerState? predecessor = currentState;
      predecessor != null;
      predecessor = predecessors[predecessor]) {
    path.add(predecessor);
  }

  return (currentCost, path.reversed.toList(growable: false));
}

@immutable
final class PartOne extends IntPart {
  static const bool printPath = false;

  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (maze, start: start, end: end) = await _parseMaze(input);
    final (cost, path) = _findShortestPath(
      maze,
      start: start,
      face: Vector.east,
      end: end,
    );

    if (printPath) {
      final grid = Grid.generate(
        width: maze.width,
        height: maze.height,
        generator: (pos) {
          if (maze[pos]) {
            return '#';
          }

          final pathComponent = path.where((s) => s.$1 == pos).firstOrNull;
          if (pathComponent != null) {
            return switch (pathComponent.face) {
              Vector.north => '^',
              Vector.south => 'v',
              Vector.east => '>',
              Vector.west => '<',
              _ => throw ArgumentError(),
            };
          }

          return '.';
        },
      );

      print(grid);
    }

    return cost;
  }
}

Future<(Grid<bool> maze, {Vector start, Vector end})> _parseMaze(
  Stream<String> input,
) async {
  late final Vector start;
  late final Vector end;
  final maze = await Grid.fromStream(input, (position, char) {
    if (char == 'S') {
      start = position;
    }
    if (char == 'E') {
      end = position;
    }
    return char == '#';
  });

  return (maze, start: start, end: end);
}
