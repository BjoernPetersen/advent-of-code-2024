import 'package:aoc_core/aoc_core.dart';

@immutable
final class Robot {
  static final _regex = RegExp(
    r'p=(?<x>\d+),(?<y>\d+) v=(?<vx>-?\d+),(?<vy>-?\d+)',
  );
  final Vector position;
  final Vector velocity;

  const Robot({
    required this.position,
    required this.velocity,
  });

  factory Robot.fromLine(String line) {
    final match = _regex.firstMatch(line);
    if (match == null) {
      throw FormatException('Unexpected format', line);
    }

    final position = Vector(
      x: int.parse(match.namedGroup('x')!),
      y: int.parse(match.namedGroup('y')!),
    );
    final velocity = Vector(
      x: int.parse(match.namedGroup('vx')!),
      y: int.parse(match.namedGroup('vy')!),
    );

    return Robot(position: position, velocity: velocity);
  }

  Robot move({
    required Bounds bounds,
    required int seconds,
  }) {
    final newPosition = position + (velocity * seconds);
    return Robot(
      position: newPosition % bounds,
      velocity: velocity,
    );
  }

  void countQuadrant(Bounds bounds, List<int> quadrantCounts) {
    final middle = bounds.middle;
    final direction = (middle - position);

    if (direction.x == 0 || direction.y == 0) {
      // We're on a middle line
      return;
    }

    if (direction.x > 0 && direction.y > 0) {
      quadrantCounts[0] += 1;
    } else if (direction.x < 0 && direction.y > 0) {
      quadrantCounts[1] += 1;
    } else if (direction.x > 0 && direction.y < 0) {
      quadrantCounts[2] += 1;
    } else if (direction.x < 0 && direction.y < 0) {
      quadrantCounts[3] += 1;
    } else {
      throw StateError('You made a mistake with the branch conditions');
    }
  }
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(
    Stream<String> input, {
    Bounds? roomSizeOverride,
  }) async {
    final roomSize = roomSizeOverride ?? Bounds(width: 101, height: 103);
    final quadrantCounts = List.filled(4, 0);

    await input
        .map(Robot.fromLine)
        .map((r) => r.move(bounds: roomSize, seconds: 100))
        .forEach((r) => r.countQuadrant(roomSize, quadrantCounts));

    return quadrantCounts.product;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(
    Stream<String> input, {
    Bounds? roomSizeOverride,
  }) async {
    final roomSize = roomSizeOverride ?? Bounds(width: 101, height: 103);

    final robots = await input.map(Robot.fromLine).toList();
    for (var seconds = 0;; seconds += 1) {
      final quadrantCounts = List.filled(4, 0);
      final positions = <Vector>{};
      bool hasUniquePositions = true;
      for (final robot in robots.map((r) => r.move(
            bounds: roomSize,
            seconds: seconds,
          ))) {
        if (!positions.add(robot.position)) {
          hasUniquePositions = false;
          break;
        }

        robot.countQuadrant(roomSize, quadrantCounts);
      }

      if (hasUniquePositions) {
        // Turns out that's the only condition we need. This puzzle sucked.
        final grid = Grid.generate(
          width: roomSize.width,
          height: roomSize.height,
          generator: (position) => positions.contains(position) ? '#' : ' ',
        );
        print(grid.toString());
        return seconds;
      }
    }
  }
}
