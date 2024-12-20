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
