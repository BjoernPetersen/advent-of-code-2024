import 'package:aoc/src/input/input_reader.dart';
import 'package:aoc/src/input/remote_client.dart';
import 'package:aoc/src/input/util.dart';
import 'package:dotenv/dotenv.dart';

import 'bytes.dart' as bytes_reader;

final class _RemoteReader implements InputReader {
  final RemoteClient _client;
  final int day;
  final String suffix;

  _RemoteReader(
    DotEnv env,
    this.day, {
    required this.suffix,
  }) : _client = RemoteClient.fromEnv(env);

  @override
  Stream<String> readLines() async* {
    final encoded = _client.readBytes('${padDay(day)}$suffix.txt');
    final bytesReader = bytes_reader.createReader(encoded);
    yield* bytesReader.readLines();
  }
}

InputReader createReader(
  DotEnv env,
  int day, {
  required String suffix,
}) =>
    _RemoteReader(
      env,
      day,
      suffix: suffix,
    );
