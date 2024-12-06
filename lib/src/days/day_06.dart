import 'package:aoc/src/days/day_06_common.dart';
import 'package:aoc/src/days/day_06_solver.dart' deferred as solver;
import 'package:aoc_core/aoc_core.dart';

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
    final candidates = grid.squares
        .where((l) => l.isVisited)
        .whereNot((l) => l.isObstruction || l.position == start)
        .map((e) => e.position)
        .toList(growable: false);

    if (kIsWeb) {
      // Can't multitask in JS because it sucks
      return await _resolveSingleThreaded(fullInput, candidates);
    } else {
      return await _resolveMultiThreaded(fullInput, candidates);
    }
  }

  Future<int> _resolveSingleThreaded(
    List<String> fullInput,
    List<Vector> candidates,
  ) async {
    final (grid, start) = await readInput(Stream.fromIterable(fullInput));
    var count = 0;
    for (final (index, candidate) in candidates.indexed) {
      final square = grid[candidate];
      grid[square.position] = square.withObstruction();
      if (!walkGrid(grid, start)) {
        count += 1;
      }

      grid[square.position] = square;

      if (index % 200 == 0) {
        // isResponsive = true
        await Future.delayed(const Duration(milliseconds: 100));
        print('Computed $index/${candidates.length}');
      }
    }

    return count;
  }

  Future<int> _resolveMultiThreaded(
    List<String> fullInput,
    List<Vector> candidates,
  ) async {
    await solver.loadLibrary();
    final workerCount = availableProcessors;
    print('Using $workerCount threads to solve day 6');
    final workerPool = solver.SolverWorkerPool(
      concurrencySettings: solver.ConcurrencySettings(
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
