import 'package:aoc_core/aoc_core.dart';
import 'package:test/test.dart';

void main() {
  group('Invalid bounds', () {
    for (final invalidBound in [-1, 0]) {
      test('width=$invalidBound', () {
        expect(
          () => Bounds(width: invalidBound, height: 10),
          throwsArgumentError,
        );
      });

      test('height=$invalidBound', () {
        expect(
          () => Bounds(width: 10, height: invalidBound),
          throwsArgumentError,
        );
      });
    }
  });

  group('contains(Vector)', () {
    final bounds = Bounds(width: 5, height: 5);

    group('in bounds', () {
      for (final point in [
        Vector.zero,
        const Vector(x: 4),
        const Vector(x: 3, y: 3),
        const Vector(x: 4, y: 4),
        const Vector(y: 4),
      ]) {
        test(point.toString(), () {
          expect(bounds.contains(point), isTrue);
        });
      }
    });

    group('out of bounds', () {
      for (final point in [
        const Vector(x: -1),
        const Vector(x: 5),
        const Vector(y: 5),
        const Vector(y: -1),
        const Vector(x: 5, y: 5),
        const Vector(x: -1, y: -1),
      ]) {
        test(point.toString(), () {
          expect(bounds.contains(point), isFalse);
        });
      }
    });
  });

  test('corners are correct', () {
    final bounds = Bounds(width: 5, height: 5);
    expect(
      bounds.corners,
      unorderedEquals([
        Vector.zero,
        const Vector(x: 4, y: 4),
        const Vector(x: 4),
        const Vector(y: 4),
      ]),
    );
  });

  group('equality', () {
    final bounds = Bounds(width: 5, height: 5);
    final same = Bounds(width: 5, height: 5);
    final different = [
      Bounds(width: 4, height: 5),
      Bounds(width: 5, height: 4),
    ];

    test('!= $different', () {
      expect(bounds, isNot(equals(different)));
      expect(bounds.toString(), isNot(equals(different.toString())));
    });

    test('==$same', () {
      expect(bounds, equals(same));
      expect(bounds.hashCode, same.hashCode);
      expect(bounds.toString(), bounds.toString());
    });
  });
}
