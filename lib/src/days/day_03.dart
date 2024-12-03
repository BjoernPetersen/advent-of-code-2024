import 'package:aoc_core/aoc_core.dart';

@immutable
final class PartOne extends IntPart {
  const PartOne();

    @override
    Future<int> calculate(Stream<String> input) async {
      final mulRegex = RegExp(r'mul\((\d{1,3}),(\d{1,3})\)');

      var result = 0;
      await for (final line in input) {
        for (final match in mulRegex.allMatches(line)) {
          result += int.parse(match.group(1)!) * int.parse(match.group(2)!);
        }
      }

      return result;
    }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
    Future<int> calculate(Stream<String> input) async {
      final mulRegex = RegExp(
        r"(?:mul\((?<l>\d{1,3}),(?<r>\d{1,3})\)|(?<enable>do\(\))|(?<disable>don't\(\)))",
      );

      var result = 0;
      var isEnabled = true;
      await for (final line in input) {
        for (final match in mulRegex.allMatches(line)) {
          if (match.namedGroup('disable') != null) {
            isEnabled = false;
          } else if (match.namedGroup('enable') != null) {
            isEnabled = true;
          } else if (isEnabled) {
            final left = match.namedGroup('l')!;
            final right = match.namedGroup('r')!;
            result += int.parse(left) * int.parse(right);
          }
        }
      }

      return result;
    }
}
