import 'package:aoc_core/aoc_core.dart';

Future<(Grid<int>, List<Vector>)> _buildGrid(Stream<String> input) async {
  final rows = <List<int>>[];
  final trailheads = <Vector>[];

  await for (final line in input) {
    final row = <int>[];
    for (final char in line.chars) {
      final height = int.tryParse(char);
      if (height == null) {
        row.add(-1);
        continue;
      }

      if (height == 0) {
        trailheads.add(Vector(x: row.length, y: rows.length));
      }
      row.add(height);
    }
    rows.add(row);
  }
  return (Grid(rows), trailheads);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  int _scoreTrailhead(
    Grid<int> grid,
    Vector trailhead, {
    required Set<Vector> reachedPeaks,
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
        if (reachedPeaks.add(position)) {
          score += 1;
        }
      } else {
        score += _scoreTrailhead(grid, position, reachedPeaks: reachedPeaks);
      }
    }

    return score;
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, trailheads) = await _buildGrid(input);
    return trailheads
        .map(
          (e) => _scoreTrailhead(grid, e, reachedPeaks: {}),
        )
        .sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  int _rateTrailhead(
    Grid<int> grid,
    Vector trailhead,
  ) {
    var rating = 0;
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
        rating += 1;
      } else {
        rating += _rateTrailhead(grid, position);
      }
    }

    return rating;
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, trailheads) = await _buildGrid(input);
    return trailheads.map((e) => _rateTrailhead(grid, e)).sum;
  }
}
