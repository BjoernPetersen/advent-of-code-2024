import 'package:aoc_core/aoc_core.dart';

@immutable
final class PartOne extends StringPart {
  const PartOne();

  @override
  Future<String> calculate(Stream<String> input) async {
    final (registers: registers, program: program) = await _parseInput(input);
    final outputs = <int>[];
    void sendOutput(int output) => outputs.add(output);
    var instructionPointer = 0;

    while (instructionPointer < program.length) {
      final instruction = program[instructionPointer];
      final operand = program[instructionPointer + 1];
      instructionPointer = _performInstruction(
        instructionPointer: instructionPointer,
        instruction: instruction,
        operand: operand,
        registers: registers,
        sendOutput: sendOutput,
      );
    }
    return outputs.join(',');
  }
}

int _resolveCombo(List<int> registers, int operand) {
  if (operand < 4) {
    return operand;
  }
  return registers[operand - 4];
}

const A = 0;
const B = 1;
const C = 2;

int _performInstruction({
  required int instructionPointer,
  required int instruction,
  required int operand,
  required List<int> registers,
  required void Function(int output) sendOutput,
}) {
  switch (instruction) {
    case 0:
      // adv
      registers[A] >>= _resolveCombo(registers, operand);
    case 1:
      // bxl
      registers[B] ^= operand;
    case 2:
      // bst
      registers[B] = _resolveCombo(registers, operand) & 7;
    case 3:
      // jnz
      if (registers[A] == 0) {
        break;
      }
      return operand;
    case 4:
      // bxc
      registers[B] ^= registers[C];
    case 5:
      // out
      sendOutput(_resolveCombo(registers, operand) & 7);
    case 6:
      // bdv
      registers[B] = registers[A] >> _resolveCombo(registers, operand);
    case 7:
      // cdv
      registers[C] = registers[A] >> _resolveCombo(registers, operand);
  }

  return instructionPointer + 2;
}

Future<({List<int> registers, List<int> program})> _parseInput(
  Stream<String> input,
) async {
  final registers = <int>[];

  await for (final line in input) {
    if (line.isEmpty) {
      continue;
    }

    final content = line.split(': ')[1];
    if (registers.length < 3) {
      registers.add(int.parse(content));
      continue;
    }

    return (
      program: content.split(',').map(int.parse).toList(growable: false),
      registers: registers,
    );
  }

  throw ArgumentError('Invalid input');
}
