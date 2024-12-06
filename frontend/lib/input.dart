import 'package:aoc/input.dart';
import 'package:mutex/mutex.dart';

final class CachedInputReader implements InputReader {
  List<String>? _data;
  final Mutex _mutex;
  final InputReader _delegate;

  CachedInputReader(this._delegate)
      : _mutex = Mutex(),
        _data = null;

  @override
  Stream<String> readLines() async* {
    await _mutex.protect(() async {
      _data ??= await _delegate.readLines().toList();
    });
    yield* Stream.fromIterable(_data!);
  }
}
