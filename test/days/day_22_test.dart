import 'package:aoc/day.dart';
import 'package:test/test.dart';

import '../input_helper.dart';

void main() {
  final dayNum = 22;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as IntPart;

      for (final (example, expectedResult) in [
        ('instructions-1', 37327623),
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
        expect(part.calculate(reader.readLines()), completion(15613157363));
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
