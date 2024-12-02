import 'dart:io';

import 'package:aoc/src/storage.dart';

Future<void> main() async {
  final client = StorageClient.fromEnv();

  final dir = Directory('inputs');
  if (!dir.existsSync()) {
    print('inputs dir does not exist');
    exit(1);
  }

  for (final entity in dir.listSync()) {
    if (entity is File) {
      final basename = entity.path.substring(entity.path.lastIndexOf('/') + 1);
      print('Writing ${entity.path} to cloud');
      await client.writeFile(basename, entity);
    }
  }
}
