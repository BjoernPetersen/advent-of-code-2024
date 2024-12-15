import 'package:aoc_core/aoc_core.dart';

@immutable
sealed class Entity {
  Entity._();
}

@immutable
final class Wall implements Entity {
  const Wall();
}

@immutable
final class Box implements Entity {
  const Box();
}

@immutable
class BoxLeft implements Entity {
  const BoxLeft();
}

@immutable
class BoxRight implements Entity {
  const BoxRight();
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

        if(isWide) {
          if(entity is Box) {
            row.add(const BoxLeft());
            row.add(const BoxRight());
          } else {
            row.add(entity);
            row.add(entity);
          }
        }else {
        row.add(entity);}
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

@immutable
final class PartOne extends IntPart {
  const PartOne();

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
          case Box():
            throw StateError('Logically impossible!');
        }
    }
  }

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
