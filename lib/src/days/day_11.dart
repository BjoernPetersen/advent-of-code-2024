import 'dart:math';

import 'package:aoc_core/aoc_core.dart';

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    return (await input.single)
        .split(' ')
        .map(int.parse)
        .map((n) => _processNumber(
              n: n,
              generations: 25,
              cache: Cache(),
            ))
        .sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    return (await input.single)
        .split(' ')
        .map(int.parse)
        .map((n) => _processNumber(
              n: n,
              generations: 75,
              cache: Cache(),
            ))
        .sum;
  }
}

final class Cache {
  final Map<int, int> _internal;

  Cache() : _internal = {};

  int put(int result, {required int n, required int generations}) {
    // Packing both numbers into one is faster than creating a tuple object
    // (obviously only works because generations will always be < 100)
    _internal[n * 100 + generations] = result;
    return result;
  }

  int? get({required int n, required int generations}) {
    return _internal[n * 100 + generations];
  }
}

int _processNumber({
  required final int n,
  required final int generations,
  required final Cache cache,
}) {
  final cached = cache.get(n: n, generations: generations);
  if (cached != null) {
    return cached;
  }

  var current = n;
  for (var generation = 0; generation < generations; ++generation) {
    final int digits;

    if (current == 0) {
      current = 1;
    } else if ((digits = (log(current + 1) / ln10).ceil()) % 2 == 0) {
      final ordersOfMagnitude = pow(10, digits ~/ 2).round();
      final leftDigits = current ~/ ordersOfMagnitude;
      final rightDigits = current - (leftDigits * ordersOfMagnitude);

      final remainingGenerations = generations - generation - 1;
      final leftCount = _processNumber(
        n: leftDigits,
        generations: remainingGenerations,
        cache: cache,
      );
      final rightCount = _processNumber(
        n: rightDigits,
        generations: remainingGenerations,
        cache: cache,
      );
      final result = leftCount + rightCount;
      return cache.put(result, n: n, generations: generations);
    } else {
      current *= 2024;
    }
  }

  return cache.put(1, generations: generations, n: n);
}
