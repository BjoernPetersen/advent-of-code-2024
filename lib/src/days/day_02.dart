import 'package:aoc_core/aoc_core.dart';

Iterable<int> _parseReport(String line) {
  return RegExp(r'\d+').allMatches(line).map((e) => int.parse(e.group(0)!));
}

final class PartOne extends IntPart {
  const PartOne();

  bool _isSafe(Iterable<int> report) {
    var dampenerAvailable = false;
    var preDampenerA = -1;

    var expectedSign = 0;
    for (final (a, b) in report.zipWithNext()) {
      final int diff;
      if (preDampenerA < 0) {
        diff = a - b;
      } else {
        dampenerAvailable = false;
        diff = preDampenerA - b;
      }

      final absDiff = diff.abs();
      if (absDiff == 0 || absDiff > 3) {
        if (dampenerAvailable) {
          preDampenerA = a;
          continue;
        }
        return false;
      }

      if (expectedSign == 0) {
        expectedSign = diff.sign;
      } else if (diff.sign != expectedSign) {
        if (dampenerAvailable) {
          preDampenerA = a;
          continue;
        }
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

final class PartTwo extends IntPart {
  const PartTwo();

  bool _isSafe(
    List<int> report, {
    bool isReversed = false,
  }) {
    var dampenerAvailable = true;
    var preDampenerA = -1;

    var expectedSign = 0;
    for (final (a, b) in report.zipWithNext()) {
      final int diff;
      if (preDampenerA < 0) {
        diff = b - a;
      } else {
        dampenerAvailable = false;
        diff = b - preDampenerA;
        preDampenerA = -1;
      }

      final absDiff = diff.abs();
      if (absDiff == 0 || absDiff > 3) {
        if (dampenerAvailable) {
          preDampenerA = a;
          continue;
        } else if (!isReversed) {
          return _isSafe(
            report.reversed.toList(growable: false),
            isReversed: true,
          );
        }

        return false;
      }

      if (expectedSign == 0) {
        expectedSign = diff.sign;
      } else if (diff.sign != expectedSign) {
        if (dampenerAvailable) {
          preDampenerA = a;
          continue;
        } else if (!isReversed) {
          return _isSafe(
            report.reversed.toList(growable: false),
            isReversed: true,
          );
        }

        return false;
      }
    }

    return true;
  }

  @override
  Future<int> calculate(Stream<String> input) {
    return input
        .map(_parseReport)
        .map((e) => e.toList(growable: false))
        .where(_isSafe)
        .count;
  }
}
