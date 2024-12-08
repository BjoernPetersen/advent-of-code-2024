import 'dart:io';

import 'package:aoc/src/input/input_reader.dart';
import 'package:aoc/src/input/local.dart' as local;
import 'package:aoc/src/input/bytes.dart' as bytes_reader;
import 'package:aoc/src/input/remote.dart' as remote;
import 'package:aoc/src/input/strings.dart' as strings;
import 'package:aoc/src/input/util.dart';
import 'package:dotenv/dotenv.dart';

export 'package:aoc/src/input/input_reader.dart';

InputReader createReaderForFile(File path) => local.createReader(path);

InputReader createReaderForDay(int day, {String suffix = ''}) {
  final env = DotEnv(
    includePlatformEnvironment: true,
    quiet: true,
  )..load();

  if (env['USE_LOCAL_STORAGE'] == 'true') {
    print('Using local storage due to override');
    return createReaderForFile(getDefaultPathForDay(
      day,
      suffix: suffix,
    ));
  }

  return remote.createReader(env, day, suffix: suffix);
}

InputReader createRawBytesReader(Stream<List<int>> bytes) {
  return bytes_reader.createReader(bytes);
}

File getDefaultPathForDay(int day, {String suffix = ''}) {
  final filename = '${padDay(day)}$suffix.txt';
  return File('inputs/$filename');
}

InputReader createStringsReader(
  List<String> lines,
) =>
    strings.createReader(lines);
