import 'dart:io';

import 'package:aoc/src/input/remote_client.dart';
import 'package:dotenv/dotenv.dart';

Future<void> main(List<String> args) async {
  final client = RemoteClient.fromEnv(
    DotEnv(includePlatformEnvironment: true)..load(),
  );
  final dir = Directory('inputs');

  if (args.firstOrNull == 'download') {
    await _download(client, dir);
  } else {
    await _upload(client, dir);
  }
}

Future<void> _download(RemoteClient client, Directory dir) async {
  if (!dir.existsSync()) {
    dir.createSync();
  }

  final tasks = await client.listObjects().map<Future<void>>(
    (objectName) async {
      final file = File('${dir.path}/$objectName');
      print('Writing to ${file.path}');
      final handle = await file.open(mode: FileMode.writeOnly);
      try {
        await for (final bytes in client.readBytes(objectName)) {
          await handle.writeFrom(bytes);
        }
      } finally {
        await handle.close();
      }
    },
  ).toList();
  await Future.wait(tasks);
}

Future<void> _upload(RemoteClient client, Directory dir) async {
  if (!dir.existsSync()) {
    print('inputs dir does not exist');
    exit(1);
  }

  final tasks = <Future<void>>[];
  for (final entity in dir.listSync()) {
    if (entity is File) {
      final basename = entity.path.substring(entity.path.lastIndexOf('/') + 1);
      print('Writing ${entity.path} to cloud');
      tasks.add(client.writeFile(basename, entity));
    }
  }
  await Future.wait(tasks);
}
