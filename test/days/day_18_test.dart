import 'package:aoc/day.dart';
import 'package:test/test.dart';

import '../input_helper.dart';
import 'package:aoc/src/days/day_18.dart';

void main() {
  final dayNum = 18;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as PartOne;

      for (final (example, expectedResult) in [
        ('instructions-1', 22),
      ]) {
        test('example $example passes', () {
          final reader = getExampleReader(dayNum, example);
          expect(
            part.calculate(reader.readLines(), memorySize: 7, byteCount: 12),
            completion(expectedResult),
          );
        });
      }

      test('input passes', () {
        final reader = getInputReader(dayNum);
        expect(part.calculate(reader.readLines()), completion(304));
      });
    });
    group(
      'part 2',
      () {
        late final PartTwo part;

        setUpAll(() {
          part = day.partTwo as PartTwo;
        });

        for (final (example, expectedResult) in [
          ('instructions-1', '6,1'),
        ]) {
          test('example $example passes', () {
            final reader = getExampleReader(dayNum, example);
            expect(
              part.calculate(reader.readLines(), memorySize: 7),
              completion(expectedResult),
            );
          });
        }

        test('input passes', () {
          final reader = getInputReader(dayNum);
          expect(part.calculate(reader.readLines()), completion('50,28'));
        });
      },
      skip: day.partTwo == null,
    );
  });
}
