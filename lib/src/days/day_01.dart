import 'package:aoc_core/aoc_core.dart';

Future<(List<int>, List<int>)> _readInput(Stream<String> input) async {
  final left = <int>[];
  final right = <int>[];

  await for (final line in input) {
    final parts = line.split('   ');

    assert(parts.length == 2);

    left.add(int.parse(parts[0]));
    right.add(int.parse(parts[1]));
  }

  return (left, right);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (left, right) = await _readInput(input);
    left.sort();
    right.sort();

    return left.mapIndexed((index, l) => (l - right[index]).abs()).sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (left, right) = await _readInput(input);

    final counts = <int, int>{};
    for (final b in right) {
      counts.update(
        b,
        (old) => old + 1,
        ifAbsent: () => 1,
      );
    }

    return left.map((a) => (counts[a] ?? 0) * a).sum;
  }
}
