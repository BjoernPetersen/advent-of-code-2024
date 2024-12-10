import 'package:aoc/day.dart';
import 'package:test/test.dart';

import '../input_helper.dart';

void main() {
  final dayNum = 10;
  final day = getDay(dayNum);

  group('day $dayNum', () {
    group('part 1', () {
      final part = day.partOne as IntPart;

      for (final (example, expectedResult) in [
        ('instructions-1', 1),
        ('instructions-2', 36),
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
        expect(part.calculate(reader.readLines()), completion(816));
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
          ('instructions-2', 81),
          ('instructions-3', 3),
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
          expect(part.calculate(reader.readLines()), completion(1960));
        });
      },
      skip: day.partTwo == null,
    );
  });
}
