import 'dart:convert';

import 'package:aoc/src/input/input_reader.dart';

final class _BytesReader implements InputReader {
  final Stream<List<int>> _bytes;

  _BytesReader(this._bytes);

  @override
  Stream<String> readLines() async* {
    final encoded = _bytes;
    final decoder = Utf8Decoder();
    final decoded = decoder.bind(encoded);
    final buffer = StringBuffer();
    await for (var string in decoded) {
      int newlineIndex = 0;
      while ((newlineIndex = string.indexOf('\n')) > -1) {
        buffer.write(string.substring(0, newlineIndex));
        yield buffer.toString();
        buffer.clear();
        string = string.substring(newlineIndex + 1);
      }

      buffer.write(string);
    }
  }
}

InputReader createReader(Stream<List<int>> bytes) => _BytesReader(bytes);
