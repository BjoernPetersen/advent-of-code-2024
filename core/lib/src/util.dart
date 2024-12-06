import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';

extension CharIterable on String {
  Iterable<String> get chars sync* {
    for (var i = 0; i < length; i += 1) {
      yield this[i];
    }
  }
}

extension StreamUtils<T> on Stream<T> {
  Future<int> get count => fold(0, (previous, _) => previous + 1);
}

extension IterableUtils<T> on Iterable<T> {
  int get count => fold(0, (previous, _) => previous + 1);

  Iterable<R> combined<U, R>(
    Iterable<U> other,
    R Function(T, U) combine,
  ) sync* {
    final otherIterator = other.iterator;
    for (final element in this) {
      if (!otherIterator.moveNext()) {
        throw ArgumentError('other iterable was shorter');
      }

      yield combine(element, otherIterator.current);
    }

    if (otherIterator.moveNext()) {
      throw ArgumentError('other iterable was longer');
    }
  }

  Iterable<(T, T)> zipWithNext() sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return;
    }
    var last = iterator.current;

    while (iterator.moveNext()) {
      yield (last, iterator.current);
      last = iterator.current;
    }
  }
}

@immutable
class Vector {
  static const Vector zero = Vector();
  static const Vector north = Vector(y: -1);
  static const Vector east = Vector(x: 1);
  static const Vector south = Vector(y: 1);
  static const Vector west = Vector(x: -1);
  static const Iterable<Vector> starDirections = [
    Vector(x: 1),
    Vector(x: 1, y: 1),
    Vector(y: 1),
    Vector(x: -1, y: 1),
    Vector(x: -1),
    Vector(x: -1, y: -1),
    Vector(y: -1),
    Vector(x: 1, y: -1),
  ];

  final int x;
  final int y;

  const Vector({
    this.x = 0,
    this.y = 0,
  });

  bool get isHorizontal {
    if (x != 0 && y != 0) {
      throw StateError('Vector is diagonal');
    }

    return x != 0;
  }

  bool get isVertical => !isHorizontal;

  Vector operator +(Vector other) {
    return Vector(
      x: x + other.x,
      y: y + other.y,
    );
  }

  Vector operator -(Vector other) {
    return Vector(
      x: x - other.x,
      y: y - other.y,
    );
  }

  Vector operator *(int scalar) {
    return Vector(
      x: x * scalar,
      y: y * scalar,
    );
  }

  Vector rotate({bool clockwise = true}) {
    return clockwise ? Vector(x: -y, y: x) : Vector(x: y, y: -x);
  }

  Vector operator -() {
    return Vector(x: -x, y: -y);
  }

  Vector abs() {
    return Vector(
      x: x.abs(),
      y: y.abs(),
    );
  }

  int manhattanNorm() {
    final abs = this.abs();
    return abs.x + abs.y;
  }

  double norm(int p) {
    final sum = pow(x.abs(), p) + pow(y.abs(), p);

    if (p == 2) {
      // Special case for Euclidean norm in hopes that sqrt is faster than pow(n, 1/2)
      return sqrt(sum);
    }

    return pow(sum, 1 / p) as double;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vector &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() {
    return '($x, $y)';
  }
}

class Grid<T> {
  final List<List<T>> _grid;
  final int width;

  int get height => _grid.length;

  Grid(this._grid) : width = _grid[0].length;

  Grid.generate({
    required this.width,
    required int height,
    required T Function(Vector position) generator,
  }) : _grid = List.generate(
          height,
          (y) => List.generate(
            width,
            (x) => generator(Vector(x: x, y: y)),
            growable: false,
          ),
          growable: false,
        );

  Grid<T> clone() {
    return Grid(
      rows.map((e) => e.toList(growable: false)).toList(growable: false),
    );
  }

  T operator [](Vector pos) => _grid[pos.y][pos.x];

  void operator []=(Vector pos, T value) => _grid[pos.y][pos.x] = value;

  T update(Vector pos, T Function(T) compute) {
    final value = compute(this[pos]);
    this[pos] = value;
    return value;
  }

  bool contains(Vector pos) {
    return pos.x >= 0 && pos.y >= 0 && pos.x < width && pos.y < height;
  }

  Iterable<List<T>> get rows sync* {
    for (final row in _grid) {
      yield row;
    }
  }

  Iterable<Iterable<T>> get columns sync* {
    for (var x = 0; x < width; x += 1) {
      yield Iterable.generate(height, (y) => _grid[y][x]);
    }
  }

  Iterable<Vector> get positions sync* {
    for (var y = 0; y < height; ++y) {
      for (var x = 0; x < width; ++x) {
        yield Vector(x: x, y: y);
      }
    }
  }

  Iterable<T> get squares sync* {
    for (final position in positions) {
      yield this[position];
    }
  }

  @override
  String toString() {
    return rows.map((row) => row.map((e) => e.toString()).join()).join('\n');
  }
}

const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

int get availableProcessors {
  if (kIsWeb) {
    throw StateError("Can't multithread on web");
  }
  return Platform.numberOfProcessors;
}
