import 'dart:io';

import 'package:aoc/src/input/input_reader.dart';

final class _LocalReader implements InputReader {
  final File path;

  _LocalReader(this.path);

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

InputReader createReader(File path) => _LocalReader(path);
