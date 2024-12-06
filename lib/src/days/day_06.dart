import 'dart:io';

import 'package:aoc/src/days/solver_day_6.dart';
import 'package:aoc_core/aoc_core.dart';
import 'package:squadron/squadron.dart';

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (grid, start) = await readInput(input);
    _walkGrid(grid, start);
    return grid.squares.where((l) => l.isVisited).count;
  }

  void _walkGrid(Grid<Square> grid, Vector start) {
    var position = start;
    var direction = Vector.north;
    while (grid.contains(position)) {
      grid.update(position, (l) => l.visit());

      Vector nextPosition;
      while (grid.contains(nextPosition = position + direction) &&
          grid[nextPosition].isObstruction) {
        direction = direction.rotate(clockwise: true);
      }

      position = nextPosition;
    }
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final fullInput = await input.toList();
    final (grid, start) = await readInput(Stream.fromIterable(fullInput));

    // normal walk to identity candidates
    walkGrid(grid, start, markVisitedSquares: true);

    final workerCount = Platform.numberOfProcessors;
    print('Using $workerCount threads to solve day 6');
    final workerPool = SolverWorkerPool(
      concurrencySettings: ConcurrencySettings(
        minWorkers: workerCount,
        maxWorkers: workerCount,
        // This is per worker
        maxParallel: 1,
      ),
    );

    workerPool.registerWorkerPoolListener((worker, removed) {
      if (!removed) {
        worker.initialize(fullInput);
      }
    });

    try {
      final tasks = <Future<int>>[];
      final candidates = grid.squares
          .where((l) => l.isVisited)
          .whereNot((l) => l.isObstruction || l.position == start)
          .map((e) => e.position)
          .toList(growable: false);

      for (final slice
          in candidates.slices((candidates.length / workerCount).ceil())) {
        tasks.add(workerPool.solve(slice));
      }

      return (await Future.wait(tasks)).sum;
    } finally {
      workerPool.release();
    }
  }
}
