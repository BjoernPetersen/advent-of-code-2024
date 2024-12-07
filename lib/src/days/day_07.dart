import 'package:aoc_core/aoc_core.dart';

typedef Operator = int Function(int, int);

(int, List<int>) _parseInputLine(String line) {
  final [testValue, rest] = line.split(': ');
  final operands = rest.split(' ').map(int.parse).toList(growable: false);
  return (int.parse(testValue), operands);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    var sum = 0;
    final operators = [
      (int a, int b) => a * b,
      (int a, int b) => a + b,
    ];
    await for (final line in input) {
      final (testValue, operands) = _parseInputLine(line);
      if (_isSolvable(
        testValue: testValue,
        operands: operands,
        availableOperators: operators,
      )) {
        sum += testValue;
      }
    }
    return sum;
  }

  bool _isSolvable({
    required List<Operator> availableOperators,
    required int testValue,
    required List<int> operands,
    int nextIndex = 0,
    int currentValue = 0,
  }) {
    if (nextIndex == 0) {
      return _isSolvable(
        availableOperators: availableOperators,
        testValue: testValue,
        operands: operands,
        currentValue: operands[0],
        nextIndex: 1,
      );
    }

    for (final operator in availableOperators) {
      final newValue = operator(currentValue, operands[nextIndex]);
      if (newValue > testValue) {
        continue;
      }

      if (nextIndex == operands.length - 1) {
        if (newValue == testValue) {
          return true;
        } else {
          continue;
        }
      }

      final result = _isSolvable(
        availableOperators: availableOperators,
        testValue: testValue,
        operands: operands,
        nextIndex: nextIndex + 1,
        currentValue: newValue,
      );

      if (result) {
        return true;
      }
    }

    return false;
  }
}
