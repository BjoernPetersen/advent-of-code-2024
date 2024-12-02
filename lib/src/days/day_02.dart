import 'package:aoc_core/aoc_core.dart';

Iterable<int> _parseReport(String line) {
  return RegExp(r'\d+').allMatches(line).map((e) => int.parse(e.group(0)!));
}

final class PartOne extends IntPart {
  const PartOne();

  bool _isSafe(Iterable<int> report) {
    var expectedSign = 0;
    for (final (a, b) in report.zipWithNext()) {
      final diff = a - b;

      final absDiff = diff.abs();
      if (absDiff == 0 || absDiff > 3) {
        return false;
      }

      if (expectedSign == 0) {
        expectedSign = diff.sign;
      } else if (diff.sign != expectedSign) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<int> calculate(Stream<String> input) {
    return input.map(_parseReport).where(_isSafe).count;
  }
}
