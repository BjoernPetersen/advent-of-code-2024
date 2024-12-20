import 'package:aoc_core/aoc_core.dart';

Future<({List<String> towels, List<String> designs})> _parseInput(
  Stream<String> input,
) async {
  var isDesign = false;
  late final List<String> towels;
  final designs = <String>[];
  await for (final line in input) {
    if (line.isEmpty) {
      isDesign = true;
      continue;
    }

    if (!isDesign) {
      towels = line.split(', ');
      continue;
    }

    designs.add(line);
  }

  return (towels: towels, designs: designs);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (towels: towels, designs: designs) = await _parseInput(input);
    return designs
        .where((design) => calcNumberOfCombos(design, towels, {}) > 0)
        .count;
  }
}

int calcNumberOfCombos(
  String design,
  Iterable<String> towels,
  Map<String, int> cache,
) {
  if (design.isEmpty) {
    return 1;
  }

  final int? cached;
  if ((cached = cache[design]) != null) {
    return cached!;
  }

  var count = 0;
  for (final towel in towels) {
    if (design.startsWith(towel)) {
      final rest = calcNumberOfCombos(
        design.substring(towel.length),
        towels,
        cache,
      );
      count += rest;
    }
  }

  cache[design] = count;
  return count;
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final (towels: towels, designs: designs) = await _parseInput(input);
    return designs.map((design) => calcNumberOfCombos(design, towels, {})).sum;
  }
}
