import 'dart:io';

import 'package:audio_meta/audio_meta.dart';

AudioMeta fromPathImpl(String path) {
  return AudioMeta.fromFile(File(path));
}

AudioMeta fromFileImpl(File file) {
  return AudioMeta.fromBytes(file.readAsBytesSync());
}

Future<AudioMeta> fromFileAsyncImpl(File file) async {
  return AudioMeta.fromBytes(await file.readAsBytes());
}

Future<AudioMeta> fromPathAsyncImpl(String path) async {
  return await AudioMeta.fromFileAsync(File(path));
}
