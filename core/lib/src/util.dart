import 'dart:math';

import 'package:meta/meta.dart';

extension CharIterable on String {
  Iterable<String> get chars sync* {
    for (var i = 0; i < length; i += 1) {
      yield this[i];
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

  T operator [](Vector pos) => _grid[pos.y][pos.x];

  void operator []=(Vector pos, T value) => _grid[pos.y][pos.x] = value;

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

  @override
  String toString() {
    return rows.map((row) => row.map((e) => e.toString()).join()).join('\n');
  }
}
