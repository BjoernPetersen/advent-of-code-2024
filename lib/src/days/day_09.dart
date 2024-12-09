import 'package:aoc_core/aoc_core.dart';

int intSum(int a, int b) {
  var sum = 0;
  for (var i = a; i <= b; ++i) {
    sum += i;
  }
  return sum;
}

Future<List<int>> _parseInput(Stream<String> input) async {
  final line = await input.single;
  return List.generate(
    line.length,
    (i) => int.parse(line[i]),
    growable: false,
  );
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final diskMap = await _parseInput(input);

    var sum = 0;
    var rightCursor =
        diskMap.length % 2 == 0 ? diskMap.length : diskMap.length + 1;
    var rightFileId = 0;
    var rightCursorRemaining = 0;
    var position = 0;

    for (var leftCursor = 0; leftCursor < rightCursor; ++leftCursor) {
      final leftNum = diskMap[leftCursor];
      final isFree = leftCursor % 2 == 1;

      if (isFree) {
        for (var posOffset = 0; posOffset < leftNum; ++posOffset) {
          if (rightCursorRemaining == 0) {
            // Skip free storage
            rightCursor -= 2;
            rightCursorRemaining = diskMap[rightCursor];
            rightFileId = rightCursor ~/ 2;
          }

          sum += (position + posOffset) * rightFileId;
          rightCursorRemaining -= 1;
        }
      } else {
        final fileId = leftCursor ~/ 2;
        sum += fileId * intSum(position, position + leftNum - 1);
      }

      position += leftNum;
    }

    while (rightCursorRemaining > 0) {
      sum += position * rightFileId;
      position += 1;
      rightCursorRemaining -= 1;
    }

    return sum;
  }
}

@immutable
final class PartTwo extends IntPart {
  const PartTwo();

  @override
  Future<int> calculate(Stream<String> input) async {
    final diskMap = await _parseInput(input);

    final cursorIdHasMoved = List.filled(diskMap.length, false);

    final rightCursorStart =
        diskMap.length % 2 == 0 ? diskMap.length - 2 : diskMap.length - 1;

    var sum = 0;
    var position = 0;

    for (var leftCursor = 0; leftCursor < diskMap.length; ++leftCursor) {
      final leftLength = diskMap[leftCursor];
      final isFree = leftCursor % 2 == 1;

      if (isFree) {
        var posOffset = 0;
        for (var rightCursor = rightCursorStart;
            rightCursor > leftCursor && posOffset < leftLength;
            rightCursor -= 2) {
          if (cursorIdHasMoved[rightCursor]) {
            continue;
          }

          final rightFileId = rightCursor ~/ 2;
          final rightLength = diskMap[rightCursor];
          if (rightLength > leftLength - posOffset) {
            continue;
          }

          final actualPosition = position + posOffset;

          cursorIdHasMoved[rightCursor] = true;
          sum += rightFileId *
              intSum(actualPosition, actualPosition + rightLength - 1);
          posOffset += rightLength;
        }
      } else if (!cursorIdHasMoved[leftCursor]) {
        final fileId = leftCursor ~/ 2;
        sum += fileId * intSum(position, position + leftLength - 1);
      }

      position += leftLength;
    }

    return sum;
  }
}
