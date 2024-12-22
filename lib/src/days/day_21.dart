import 'package:aoc_core/aoc_core.dart';

final class Keypad<T> {
  final Map<T, Vector> _keys;
  final Vector _blank;
  Vector _pointer;
  final Keypad<Vector>? controlledBy;
  final Map<(Vector, T), (Vector, List<Vector>)> cache;

  Keypad(
    this._keys, {
    required T confirmKey,
    required this.controlledBy,
    required Vector blank,
  })  : _pointer = _keys[confirmKey]!,
        _blank = blank,
        cache = {};

  static Keypad<Vector> directional({required Keypad<Vector>? controlledBy}) {
    return Keypad(
      {
        Vector.zero: Vector(x: 2, y: 0),
        Vector.north: Vector(x: 1, y: 0),
        Vector.west: Vector(x: 0, y: 1),
        Vector.south: Vector(x: 1, y: 1),
        Vector.east: Vector(x: 2, y: 1),
      },
      confirmKey: Vector.zero,
      controlledBy: controlledBy,
      blank: Vector(x: 0, y: 0),
    );
  }

  static Keypad<String> numerical({required Keypad<Vector> controlledBy}) {
    return Keypad(
      {
        '7': Vector(x: 0, y: 0),
        '8': Vector(x: 1, y: 0),
        '9': Vector(x: 2, y: 0),
        '4': Vector(x: 0, y: 1),
        '5': Vector(x: 1, y: 1),
        '6': Vector(x: 2, y: 1),
        '1': Vector(x: 0, y: 2),
        '2': Vector(x: 1, y: 2),
        '3': Vector(x: 2, y: 2),
        '0': Vector(x: 1, y: 3),
        'A': Vector(x: 2, y: 3),
      },
      confirmKey: 'A',
      controlledBy: controlledBy,
      blank: Vector(x: 0, y: 3),
    );
  }

  Iterable<Vector> pressKey(T key) sync* {
    final (newPoint, ownMoves) = cache.putIfAbsent(
      (_pointer, key),
      () {
        final moves= moveToKey(key).toList(growable: false);
        return (_pointer, moves);
      },
    );
    _pointer=newPoint;
    final controller = controlledBy;
    if (controller == null) {
      yield* ownMoves;
      yield Vector.zero;
    } else {
      for (final stroke in ownMoves) {
        yield* controller.pressKey(stroke);
      }
      yield* controller.pressKey(Vector.zero);
    }
  }

  Iterable<Vector> moveToKey(T key) sync* {
    final destination = _keys[key]!;
    final diff = destination - _pointer;
    Vector corner;
    if (diff.x < 0 || diff.y == 0) {
      // Prefer going left
      corner = Vector(x: _pointer.x + diff.x, y: _pointer.y);
    } else {
      corner = Vector(x: _pointer.x, y: _pointer.y + diff.y);
    }

    if (corner == _blank || corner == _pointer) {
      if (corner.x == _pointer.x) {
        corner = Vector(x: _pointer.x + diff.x, y: _pointer.y);
      } else {
        corner = Vector(x: _pointer.x, y: _pointer.y + diff.y);
      }
    }

    final sign = (corner - _pointer).sign;
    while (_pointer != corner) {
      yield sign;
      _pointer += sign;
    }

    if (_pointer != destination) {
      yield* moveToKey(key);
    }
  }
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    var sum = 0;

    await for (final line in input) {
      final directional = <Keypad<Vector>>[];
      directional.add(Keypad.directional(controlledBy: directional.lastOrNull));
      directional.add(Keypad.directional(controlledBy: directional.lastOrNull));
      final numerical = Keypad.numerical(controlledBy: directional.last);

      final moves = <Vector>[];
      for (final number in line.chars) {
        moves.addAll(numerical.pressKey(number));
      }
      print('Moves for $line: ${moves.map(moveToString).join()}');
      final fullNum = int.parse(line.substring(0, line.length - 1));
      sum += fullNum * moves.length;
    }

    return sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    var sum = 0;

    await for (final line in input) {
      final directional = <Keypad<Vector>>[];
      for (var index = 0; index < 25; index += 1) {
        directional.add(Keypad.directional(
          controlledBy: directional.lastOrNull,
        ));
      }
      final numerical = Keypad.numerical(controlledBy: directional.last);

      var moves = 0;
      for (final number in line.chars) {
        moves += numerical.pressKey(number).count;
      }
      final fullNum = int.parse(line.substring(0, line.length - 1));
      sum += fullNum * moves;
    }

    return sum;
  }
}

String moveToString(Vector move) {
  return switch (move) {
    Vector.west => '<',
    Vector.east => '>',
    Vector.south => 'v',
    Vector.north => '^',
    Vector.zero => 'A',
    _ => throw ArgumentError(),
  };
}
