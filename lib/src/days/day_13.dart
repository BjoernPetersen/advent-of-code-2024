import 'package:aoc_core/aoc_core.dart';

@immutable
final class Machine {
  final Vector aEffect;
  final Vector bEffect;
  final Vector prize;

  const Machine({
    required this.aEffect,
    required this.bEffect,
    required this.prize,
  });

  Machine correctUnitConversionError() {
    const offset = 10000000000000;
    return Machine(
      aEffect: aEffect,
      bEffect: bEffect,
      prize: prize + const Vector(x: offset, y: offset),
    );
  }

  @override
  String toString() {
    return 'A: $aEffect\nB: $bEffect\nPrize: $prize';
  }
}

final effectRegex = RegExp(r': X\+(?<x>\d+), Y\+(?<y>\d+)');
final prizeRegex = RegExp(r': X=(?<x>\d+), Y=(?<y>\d+)');

Vector _parseVector(String line, RegExp regex) {
  final match = regex.firstMatch(line);
  if (match == null) {
    throw ArgumentError.value(line, 'line', 'Does not have expected format');
  }

  return Vector(
    x: int.parse(match.namedGroup('x')!),
    y: int.parse(match.namedGroup('y')!),
  );
}

Stream<Machine> _parseMachines(Stream<String> lines) async* {
  var aEffect = Vector.zero;
  var bEffect = Vector.zero;

  var counter = 0;
  await for (final line in lines) {
    switch (counter++) {
      case 0:
        aEffect = _parseVector(line, effectRegex);
      case 1:
        bEffect = _parseVector(line, effectRegex);
      case 2:
        yield Machine(
          aEffect: aEffect,
          bEffect: bEffect,
          prize: _parseVector(line, prizeRegex),
        );
      case 3:
        // Empty line
        counter = 0;
    }
  }
}

int _calculateB(Machine machine) {
  final a = machine.aEffect;
  final b = machine.bEffect;
  final p = machine.prize;
  final dividend = (a.x * p.y - p.x * a.y);
  final divisor = (a.x * b.y - b.x * a.y);

  if (dividend % divisor != 0) {
    return -1;
  }

  return dividend ~/ divisor;
}

int _calculateA(Machine machine, int b) {
  final dividend = machine.prize.x - (b * machine.bEffect.x);
  if (dividend % machine.aEffect.x != 0) {
    return -1;
  }

  return dividend ~/ machine.aEffect.x;
}

int _calculateCost(Machine machine) {
  final b = _calculateB(machine);
  if (b < 0) {
    // Not possible
    return 0;
  }

  final a = _calculateA(machine, b);
  if (a < 0) {
    // Not possible
    return 0;
  }

  return a * 3 + b;
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    return await _parseMachines(input).map(_calculateCost).sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    return await _parseMachines(input)
        .map((m) => m.correctUnitConversionError())
        .map(_calculateCost)
        .sum;
  }
}
