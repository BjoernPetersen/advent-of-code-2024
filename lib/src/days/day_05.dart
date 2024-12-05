import 'package:aoc_core/aoc_core.dart';

final class Order {
  final Map<int, List<int>> _relations;

  Order(this._relations);

  int compare(
    int a,
    int b, {
    bool checkReverse = true,
  }) {
    final relations = _relations[a];

    if (relations != null && relations.contains(b)) {
      return -1;
    }

    if (checkReverse) {
      return -compare(b, a, checkReverse: false);
    }

    return 0;
  }
}

Future<(Order, List<List<int>>)> _parseInput(Stream<String> input) async {
  final relations = <int, List<int>>{};
  final updates = <List<int>>[];

  var isOrder = true;
  await for (final line in input) {
    if (isOrder) {
      if (line.isEmpty) {
        isOrder = false;
        continue;
      }

      // A|B
      final pair = line.split('|').map(int.parse).toList(growable: false);
      final a = pair[0];
      final aRelations = relations.putIfAbsent(a, () => []);
      aRelations.add(pair[1]);
    } else {
      updates.add(line.split(',').map(int.parse).toList(growable: false));
    }
  }

  return (Order(relations), updates);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (order, updates) = await _parseInput(input);

    var sum = 0;
    for (final update in updates) {
      if (update.isSorted(order.compare)) {
        sum += update[update.length ~/ 2];
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
    final (order, updates) = await _parseInput(input);

    var sum = 0;
    for (final update in updates) {
      final sorted = update.sorted(order.compare);
      if (!sorted.equals(update)) {
        sum += sorted[sorted.length ~/ 2];
      }
    }

    return sum;
  }
}
