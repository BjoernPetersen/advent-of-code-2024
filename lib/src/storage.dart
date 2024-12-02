import 'dart:io';
import 'dart:typed_data';

import 'package:dotenv/dotenv.dart';
import 'package:minio/minio.dart';

final class StorageClient {
  final Minio _minio;
  final String _bucket;
  final String _objectPrefix = '2024';

  StorageClient._({
    required String endpoint,
    required String accessKey,
    required String secretKey,
    required String bucket,
  })  : _minio = Minio(
          endPoint: endpoint,
          accessKey: accessKey,
          secretKey: secretKey,
        ),
        _bucket = bucket;

  static String _readEnv(DotEnv env, String key) {
    final value = env[key];
    if (value == null) {
      throw Exception('$key env not configured');
    }
    return value;
  }

  factory StorageClient.fromEnv() {
    final env = DotEnv(includePlatformEnvironment: true);
    env.load();

    final endpoint = _readEnv(env, 'S3_ENDPOINT');
    final accessKey = _readEnv(env, 'S3_ACCESS_KEY_ID');
    final secretKey = _readEnv(env, 'S3_SECRET_ACCESS_KEY');
    final bucketName = _readEnv(env, 'S3_BUCKET_NAME');

    final endpointHost = Uri.parse(endpoint).host;

    return StorageClient._(
      endpoint: endpointHost,
      accessKey: accessKey,
      secretKey: secretKey,
      bucket: bucketName,
    );
  }

  String _resolveObject(String objectName) {
    return '$_objectPrefix/$objectName';
  }

  Future<void> writeFile(String objectName, File file) async {
    await writeBytes(objectName, file.readAsUint8Stream());
  }

  Future<void> writeBytes(String objectName, Stream<Uint8List> bytes) async {
    await _minio.putObject(_bucket, _resolveObject(objectName), bytes);
  }

  Stream<List<int>> readBytes(String objectName) async* {
    final stream = await _minio.getObject(_bucket, _resolveObject(objectName));
    yield* stream;
  }
}

extension on File {
  Stream<Uint8List> readAsUint8Stream() async* {
    final buffer = Uint8List(4096);
    final handle = await open();
    try {
      var readBytes = await handle.readInto(buffer);
      while (readBytes > 0) {
        yield buffer.sublist(0, readBytes).asUnmodifiableView();
        readBytes = await handle.readInto(buffer);
      }
    } finally {
      await handle.close();
    }
  }
}
