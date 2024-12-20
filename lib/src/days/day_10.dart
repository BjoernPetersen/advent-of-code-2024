import 'package:aoc_core/aoc_core.dart';

Future<(Grid<int>, List<Vector>)> _buildGrid(Stream<String> input) async {
  final trailheads = <Vector>[];
  final grid = await Grid.fromStream(input, (position, char) {
    final height = int.tryParse(char);
    if (height == null) {
      return -1;
    }

    if (height == 0) {
      trailheads.add(position);
    }

    return height;
  });

  return (grid, trailheads);
}

int _scoreTrailhead(
  Grid<int> grid,
  Vector trailhead, {
  Set<Vector>? reachedPeaks,
}) {
  var score = 0;
  final expectedHeight = grid[trailhead] + 1;
  for (final direction in Vector.crossDirections) {
    final position = trailhead + direction;
    if (!grid.contains(position)) {
      continue;
    }

    final nextHeight = grid[position];
    if (nextHeight != expectedHeight) {
      continue;
    }

    if (nextHeight == 9) {
      if (reachedPeaks == null || reachedPeaks.add(position)) {
        score += 1;
      }
    } else {
      score += _scoreTrailhead(grid, position, reachedPeaks: reachedPeaks);
    }
  }

  return score;
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, trailheads) = await _buildGrid(input);

    var sum = 0;
    for (final trailhead in trailheads) {
      sum += _scoreTrailhead(grid, trailhead, reachedPeaks: {});
    }
    return sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, trailheads) = await _buildGrid(input);
    return trailheads.map((e) => _scoreTrailhead(grid, e)).sum;
  }
}
