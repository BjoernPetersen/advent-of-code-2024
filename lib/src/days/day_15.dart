import 'package:aoc_core/aoc_core.dart';

@immutable
sealed class Entity {
  Entity._();
}

@immutable
final class Wall implements Entity {
  const Wall();

  @override
  String toString() => '#';
}

@immutable
final class Box implements Entity {
  const Box();

  @override
  String toString() => 'O';
}

@immutable
class BoxLeft implements Entity {
  const BoxLeft();

  @override
  String toString() => '[';
}

@immutable
class BoxRight implements Entity {
  const BoxRight();

  @override
  String toString() => ']';
}

Future<(Grid<Entity?> grid, Vector robotLocation, List<Vector> robotMoves)>
    _parseInput(Stream<String> input, {bool isWide = false}) async {
  final rows = <List<Entity?>>[];
  late final Vector robotLocation;
  final moves = <Vector>[];
  var isParsingGrid = true;
  await for (final line in input) {
    if (line.isEmpty) {
      isParsingGrid = false;
      continue;
    }

    if (isParsingGrid) {
      final row = <Entity?>[];
      for (final char in line.chars) {
        if (char == '@') {
          robotLocation = Vector(x: row.length, y: rows.length);
        }
        final entity = switch (char) {
          '#' => const Wall(),
          'O' => const Box(),
          _ => null,
        };

        if (isWide) {
          if (entity is Box) {
            row.add(const BoxLeft());
            row.add(const BoxRight());
          } else {
            row.add(entity);
            row.add(entity);
          }
        } else {
          row.add(entity);
        }
      }
      rows.add(row);
    } else {
      for (final char in line.chars) {
        moves.add(_parseMove(char));
      }
    }
  }

  final grid = Grid(rows);
  return (grid, robotLocation, moves);
}

Vector _parseMove(String char) {
  return switch (char) {
    '>' => Vector.east,
    '<' => Vector.west,
    '^' => Vector.north,
    'v' => Vector.south,
    _ => throw ArgumentError.value(char, 'char', 'Unknown move'),
  };
}

typedef WideBox = (Vector, Vector);

void _collectAffectedBoxes(
  Grid<Entity?> grid, {
  required WideBox box,
  required Vector move,
  required List<WideBox> result,
}) {
  final (boxLeft, boxRight) = box;
  if (move.isHorizontal) {
    var current = boxLeft;
    while (grid[current] is BoxLeft) {
      result.add((current, current + Vector.east));
      current += move * 2;
    }
  } else {
    result.add(box);
    final leftNext = boxLeft + move;
    final rightNext = boxRight + move;
    switch (grid[leftNext]) {
      case BoxLeft():
        _collectAffectedBoxes(
          grid,
          box: (leftNext, rightNext),
          move: move,
          result: result,
        );
        return;
      case BoxRight():
        _collectAffectedBoxes(
          grid,
          box: (leftNext + Vector.west, leftNext),
          move: move,
          result: result,
        );
      default:
        break;
    }

    if (grid[rightNext] is BoxLeft) {
      _collectAffectedBoxes(
        grid,
        box: (rightNext, rightNext + Vector.east),
        move: move,
        result: result,
      );
    }
  }
}

bool _canMove(Grid<Entity?> grid, WideBox box, Vector move) {
  final (boxLeft, boxRight) = box;
  return grid[boxLeft + move] is! Wall && grid[boxRight + move] is! Wall;
}

bool _moveWideBoxes(
  Grid<Entity?> grid, {
  required WideBox initialBox,
  required Vector move,
}) {
  final affected = <WideBox>[];
  _collectAffectedBoxes(
    grid,
    box: initialBox,
    move: move,
    result: affected,
  );
  affected.sort((a, b) => switch (move) {
        Vector.west => a.$1.x.compareTo(b.$1.x),
        Vector.east => -a.$1.x.compareTo(b.$1.x),
        Vector.north => a.$1.y.compareTo(b.$1.y),
        Vector.south => -a.$1.y.compareTo(b.$1.y),
        _ => throw ArgumentError('Invalid move'),
      });

  if (!affected.every((box) => _canMove(grid, box, move))) {
    return false;
  }

  for (final (boxLeft, boxRight) in affected) {
    grid[boxLeft] = null;
    grid[boxRight] = null;
    grid[boxLeft + move] = const BoxLeft();
    grid[boxRight + move] = const BoxRight();
  }
  return true;
}

Vector _moveRobot(
  final Grid<Entity?> grid, {
  required final Vector move,
  required final Vector robotLocation,
}) {
  final newLocation = robotLocation + move;
  final displaced = grid[newLocation];
  switch (displaced) {
    case null:
      return newLocation;
    case Wall():
      return robotLocation;
    case BoxLeft():
      final box = (newLocation, newLocation + Vector.east);
      if (_moveWideBoxes(grid, initialBox: box, move: move)) {
        return newLocation;
      } else {
        return robotLocation;
      }
    case BoxRight():
      final box = (newLocation + Vector.west, newLocation);
      if (_moveWideBoxes(grid, initialBox: box, move: move)) {
        return newLocation;
      } else {
        return robotLocation;
      }
    case Box():
      var newBoxLocation = newLocation + move;
      while (grid[newBoxLocation] is Box) {
        newBoxLocation += move;
      }
      switch (grid[newBoxLocation]) {
        case null:
          grid[newBoxLocation] = displaced;
          grid[newLocation] = null;
          return newLocation;
        case Wall():
          return robotLocation;
        case BoxLeft():
        case BoxRight():
        case Box():
          throw StateError('Impossible!');
      }
  }
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, initialLocation, robotMoves) = await _parseInput(input);

    var currentLocation = initialLocation;
    for (final move in robotMoves) {
      currentLocation =
          _moveRobot(grid, move: move, robotLocation: currentLocation);
    }

    var sum = 0;
    for (final position in grid.positions) {
      if (grid[position] is Box) {
        sum += position.x + 100 * position.y;
      }
    }
    return sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, initialLocation, robotMoves) = await _parseInput(
      input,
      isWide: true,
    );

    var currentLocation = initialLocation;
    for (final move in robotMoves) {
      currentLocation =
          _moveRobot(grid, move: move, robotLocation: currentLocation);
    }

    var sum = 0;
    for (final position in grid.positions) {
      if (grid[position] is BoxLeft) {
        sum += position.x + 100 * position.y;
      }
    }
    return sum;
  }
}
