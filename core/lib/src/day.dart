import 'package:meta/meta.dart';

@immutable
sealed class Part<T> {
  const Part();

  Future<T> calculate(Stream<String> input);
}

@immutable
abstract base class IntPart extends Part<int> {
  const IntPart();
}

@immutable
abstract base class StringPart extends Part<String> {
  const StringPart();
}

@immutable
final class Day<A extends Part, B extends Part> {
  final A partOne;
  final B? partTwo;

  const Day(
    this.partOne, [
    this.partTwo,
  ]);
}

extension StringResult on Part {
  Future<String> calculateString(Stream<String> input) async {
    final String result;
    switch (this) {
      case StringPart():
        final typed = this as StringPart;
        result = await typed.calculate(input);
      case IntPart():
        final typed = this as IntPart;
        final intValue = await typed.calculate(input);
        result = intValue.toString();
    }
    return result;
  }
}
