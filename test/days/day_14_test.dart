import 'package:aoc/day.dart';
import 'package:aoc/src/days/day_14.dart';
import 'package:test/test.dart';

import '../input_helper.dart';

void main() {
  final dayNum = 14;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as PartOne;

      for (final (example, expectedResult) in [
        ('instructions-1', 12),
      ]) {
        test('example $example passes', () {
          final reader = getExampleReader(dayNum, example);
          expect(
            part.calculate(
              reader.readLines(),
              roomSizeOverride: Bounds(width: 11, height: 7),
            ),
            completion(expectedResult),
          );
        });
      }

      test('input passes', () {
        final reader = getInputReader(dayNum);
        expect(part.calculate(reader.readLines()), completion(236628054));
      });
    });
    group(
      'part 2',
      () {
        late final IntPart part;

        setUpAll(() {
          part = day.partTwo as IntPart;
        });

        for (final (example, expectedResult) in [
          ('instructions-1', 0),
        ]) {
          test('example $example passes', () {
            final reader = getExampleReader(dayNum, example);
            expect(
              part.calculate(reader.readLines()),
              completion(expectedResult),
            );
          });
        }

        test('input passes', () {
          final reader = getInputReader(dayNum);
          expect(part.calculate(reader.readLines()), completion(0));
        });
      },
      skip: day.partTwo == null,
    );
  });
}
