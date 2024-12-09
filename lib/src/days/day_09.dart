import 'package:aoc_core/aoc_core.dart';

int naturalNumberSum(int n) {
  return (n * (n + 1)) ~/ 2;
}

int intSum(int a, int b) {
  return naturalNumberSum(b) - naturalNumberSum(a - 1);
}

@immutable
final class PartOne extends IntPart {
  const PartOne();

  @override
  Future<int> calculate(Stream<String> input) async {
    final line = await input.single;

    var sum = 0;
    var rightCursor = line.length % 2 == 0 ? line.length : line.length + 1;
    var rightFileId = 0;
    var rightCursorRemaining = 0;
    var position = 0;

    for (var leftCursor = 0; leftCursor < rightCursor; ++leftCursor) {
      final leftNum = int.parse(line[leftCursor]);
      final isFree = leftCursor % 2 == 1;

      if (isFree) {
        for (var posOffset = 0; posOffset < leftNum; ++posOffset) {
          if (rightCursorRemaining == 0) {
            // Skip free storage
            rightCursor -= 2;
            rightCursorRemaining = int.parse(line[rightCursor]);
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
    final line = await input.single;

    final movedFiles = <int>{};
    final rightCursorStart =
        line.length % 2 == 0 ? line.length - 2 : line.length - 1;

    var sum = 0;
    var position = 0;

    for (var leftCursor = 0; leftCursor < line.length; ++leftCursor) {
      final leftLength = int.parse(line[leftCursor]);
      final isFree = leftCursor % 2 == 1;

      if (isFree) {
        var posOffset = 0;
        for (var rightCursor = rightCursorStart;
            rightCursor > leftCursor && posOffset < leftLength;
            rightCursor -= 2) {
          final rightFileId = rightCursor ~/ 2;
          if (movedFiles.contains(rightFileId)) {
            continue;
          }

          final rightLength = int.parse(line[rightCursor]);
          if (rightLength > leftLength - posOffset) {
            continue;
          }

          final actualPosition = position + posOffset;

          movedFiles.add(rightFileId);
          sum += rightFileId *
              intSum(actualPosition, actualPosition + rightLength - 1);
          posOffset += rightLength;
        }
      } else {
        final fileId = leftCursor ~/ 2;
        if (!movedFiles.contains(fileId)) {
          sum += fileId * intSum(position, position + leftLength - 1);
        }
      }

      position += leftLength;
    }

    return sum;
  }
}
