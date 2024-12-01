import 'package:day_part/day_part.dart';
import 'package:meta/meta.dart';

Future<(List<int>, List<int>)> _build(Stream<String> input) async {
  final a = <int>[];
  final b = <int>[];

  await for (final line in input) {
    final parts = line.split(' ');
    a.add(int.parse(parts[0]));
    b.add(int.parse(parts.last));
  }

  a.sort();
  b.sort();

  return (a, b);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (a, b) = await _build(input);

    var sum = 0;
    for (final (index, i) in a.indexed) {
      final j = b[index];
      sum += (i - j).abs();
    }

    return sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (a, b) = await _build(input);

    var sum = 0;
    for (final i in a) {
      var count = 0;
      for (final j in b) {
        if (j == i) {
          count += 1;
        } else if (j > i) {
          break;
        }
      }
      sum += count * i;
    }

    return sum;
  }
}
