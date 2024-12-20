import 'package:aoc/day.dart';
import 'package:test/test.dart';

import '../input_helper.dart';
import 'package:aoc/src/days/day_20.dart';

void main() {
  final dayNum = 20;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as PartOne;

      for (final (example, expectedResult) in [
        ('instructions-1', 10),
      ]) {
        test('example $example passes', () {
          final reader = getExampleReader(dayNum, example);
          expect(
            part.calculate(reader.readLines(), countThreshold: 10),
            completion(expectedResult),
          );
        });
      }

      test('input passes', () {
        final reader = getInputReader(dayNum);
        expect(part.calculate(reader.readLines()), completion(1415));
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
          ('instructions-1', 285),
        ]) {
          test('example $example passes', () {
            final reader = getExampleReader(dayNum, example);
            expect(
              part.calculate(reader.readLines(), countThreshold: 50),
              completion(expectedResult),
            );
          });
        }

        test('input passes', () {
          final reader = getInputReader(dayNum);
          expect(part.calculate(reader.readLines()), completion(1022577));
        });
      },
      skip: day.partTwo == null,
    );
  });
}
