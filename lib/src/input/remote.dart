import 'dart:convert';

import 'package:aoc/src/input/input_reader.dart';
import 'package:aoc/src/input/remote_client.dart';
import 'package:aoc/src/input/util.dart';
import 'package:dotenv/dotenv.dart';

final class _RemoteReader implements InputReader {
  final RemoteClient _client;
  final int day;

  _RemoteReader(DotEnv env, this.day) : _client = RemoteClient.fromEnv(env);

  @override
  Stream<String> readLines() async* {
    final encoded = _client.readBytes('${padDay(day)}.txt');
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

InputReader createReader(DotEnv env, int day) => _RemoteReader(env, day);
