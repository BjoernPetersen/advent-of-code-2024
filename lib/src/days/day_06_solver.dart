import 'package:aoc_core/aoc_core.dart';
import 'package:squadron/squadron.dart';

import 'package:aoc/src/days/day_06_common.dart';
import 'day_06_solver.activator.g.dart';
export 'package:squadron/squadron.dart' show ConcurrencySettings;

part 'day_06_solver.worker.g.dart';

@immutable
final class VectorListMarshaller
    implements SquadronMarshaler<List<Vector>, List<int>> {
  const VectorListMarshaller();

  @override
  List<int> marshal(List<Vector> data) => [
        // Pack both values into a singe int
        for (final v in data) (v.x << 8) + v.y,
      ];

  @override
  List<Vector> unmarshal(List<int> data) => [
        for (final i in data)
          Vector(
            x: i >> 8,
            y: i & 0xFF,
          )
      ];
}

@SquadronService(baseUrl: '~/workers')
base class Solver {
  late final Grid<Square> grid;
  late final Vector startPosition;

  @SquadronMethod()
  Future<void> initialize(List<String> input) async {
    final (grid, startPosition) = await readInput(Stream.fromIterable(input));
    this.grid = grid;
    this.startPosition = startPosition;
  }

  @SquadronMethod()
  Future<int> solve(
    @VectorListMarshaller() List<Vector> addedObstructionPositions,
  ) async {
    final grid = this.grid;
    var count = 0;
    for (final addedObstructionPosition in addedObstructionPositions) {
      final square = grid[addedObstructionPosition];
      grid[addedObstructionPosition] = square.withObstruction();
      if (!walkGrid(grid, startPosition)) {
        count += 1;
      }
      grid[addedObstructionPosition] = square;
    }
    return count;
  }
}
