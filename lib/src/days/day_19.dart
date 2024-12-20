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

  RegExp _compilePattern(Map<int, List<String>> buckets, int maxIndex) {
    final patterns = <String>[];
    for (var index = 0; index < maxIndex; index += 1) {
      final bucket = buckets[index];
      if (bucket != null) {
        patterns.addAll(bucket);
      }
    }
    return RegExp('^(?:${patterns.join("|")})+\$');
  }

  @override
  Future<int> calculate(Stream<String> input) async {
    final (towels: towels, designs: designs) = await _parseInput(input);

    final towelBuckets = towels.groupListsBy((t) => t.length);
    for (final bucketIndex
        in towelBuckets.keys.sorted((a, b) => b.compareTo(a))) {
      final bucket = towelBuckets[bucketIndex]!;
      final smallerPattern = _compilePattern(towelBuckets, bucketIndex);
      for (var patternIndex = bucket.length - 1;
          patternIndex >= 0;
          patternIndex -= 1) {
        if (smallerPattern.hasMatch(bucket[patternIndex])) {
          bucket.removeAt(patternIndex);
        }
      }
    }

    final dedupedTowels = towelBuckets.values.flattenedToList;

    final pattern = RegExp('^(?:${dedupedTowels.join("|")})+?\$');
    print(pattern.pattern);
    return designs.where(pattern.hasMatch).count;
  }
}

int calcNumberOfCombos(
  String design,
  Set<String> towels,
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
    return designs
        .map((design) => calcNumberOfCombos(design, towels.toSet(), {}))
        .sum;
  }
}
