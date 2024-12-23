import 'package:aoc_core/aoc_core.dart';

@immutable
final class PartOne extends IntPart {
  static const prune = 16777216;

  const PartOne();

  int _generateNumber(final int initial) {
    var secret = initial;
    for (var generation = 0; generation < 2000; generation += 1) {
      secret ^= secret << 6;
      secret %= prune;
      secret ^= secret >> 5;
      secret %= prune;
      secret ^= secret << 11;
      secret %= prune;
    }
    return secret;
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    return await input.map(int.parse).map(_generateNumber).sum;
  }
}
