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
