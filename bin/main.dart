import 'dart:io';

import 'package:aoc/day.dart';
import 'package:aoc/input.dart';
import 'package:args/args.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser();

  parser.addOption(
    'day',
    abbr: 'd',
    mandatory: true,
    allowed: availableDays.map((e) => e.toString()),
  );
  parser.addOption(
    'part',
    abbr: 'p',
    allowed: ['1', '2'],
    help: 'Which part of the day to compute (default: both)',
  );
  parser.addOption(
    'input',
    abbr: 'i',
    help: 'The path to a custom input txt',
  );

  final argResult = parser.parse(args);
  final InputReader inputReader;
  final Day day;
  final int? part;
  try {
    final dayNum = int.parse(argResult['day']);
    day = getDay(dayNum);

    final partString = argResult['part'];
    part = partString == null ? null : int.parse(partString);

    final input = argResult['input'];
    final File file;
    if (input == null) {
      file = getDefaultPathForDay(dayNum);
    } else {
      file = File(input);
    }
    inputReader = createReaderForFile(file);
  } on ArgumentError catch (e) {
    print(e.message);
    print('\nUsage:\n${parser.usage}');
    exit(1);
  }

  final List<Future<String>> results = [];

  final startTime = DateTime.now();
  print('Started at $startTime');

  if (part == null || part == 1) {
    results.add(day.partOne.calculateString(inputReader.readLines()));
  }

  final partTwo = day.partTwo;
  if ((part == null && partTwo != null) || part == 2) {
    if (partTwo == null) {
      print('Part two of this day is not implemented.');
      exit(1);
    }

    results.add(partTwo.calculateString(inputReader.readLines()));
  }

  final List<String> values = await Future.wait(results);
  final stopTime = DateTime.now();
  print(
    'Executed ${results.length} part(s) in ${stopTime.difference(startTime)}',
  );
  print('Results: $values');
}
