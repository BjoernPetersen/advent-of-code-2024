import 'package:aoc/src/input/input_reader.dart';

final class _StringsInputReader implements InputReader {
  final List<String> _lines;

  const _StringsInputReader(this._lines);

  @override
  Stream<String> readLines() => Stream.fromIterable(_lines);
}

InputReader createReader(List<String> lines) => _StringsInputReader(lines);
