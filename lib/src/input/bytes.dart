import 'dart:convert';

import 'package:aoc/src/input/input_reader.dart';

final class _BytesReader implements InputReader {
  final Stream<List<int>> _bytes;

  _BytesReader(this._bytes);

  @override
  Stream<String> readLines() {
    return LineSplitter().bind(Utf8Decoder().bind(_bytes));
  }
}

InputReader createReader(Stream<List<int>> bytes) => _BytesReader(bytes);
