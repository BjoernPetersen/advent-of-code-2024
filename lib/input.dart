import 'dart:convert';
import 'dart:io';

import 'package:aoc/src/storage.dart';

abstract interface class InputReader {
  Stream<String> readLines();

  factory InputReader.forFile(File file) {
    return _FileReader(file);
  }

  factory InputReader.forDay(int day) {
    return _RemoteReader(day);
  }
}

final class _FileReader implements InputReader {
  final File path;

  _FileReader(this.path);

  @override
  Stream<String> readLines() async* {
    if (!path.existsSync()) {
      throw FileSystemException('Input file not found', path.path);
    }

    for (final line in path.readAsLinesSync()) {
      yield line;
    }
  }
}

final class _RemoteReader implements InputReader {
  final StorageClient _client;
  final int day;

  _RemoteReader(this.day) : _client = StorageClient.fromEnv();

  @override
  Stream<String> readLines() async* {
    final encoded = _client.readBytes('${_padDay(day)}.txt');
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

String _padDay(int day) {
  return day.toString().padLeft(2, '0');
}

File getDefaultPathForDay(int day) {
  final filename = '${_padDay(day)}.txt';
  return File('inputs/$filename');
}
