import 'package:aoc/input.dart';
import 'package:test/test.dart';

void main() {
  final inputReader = InputReader.forDay(1);
  test('Reads all lines', () async {
    final allLines = inputReader.readLines().toList();
    expect(allLines, completion(hasLength(1000)));
  });

  test('Lines are trimmed', () {
    expect(inputReader.readLines().first, completion(isNot(contains('\n'))));
  });
}
