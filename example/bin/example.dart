import 'dart:io';
import 'dart:typed_data';

import 'package:audio_meta/audio_meta.dart';

void main(List<String> arguments) {
  final time = DateTime.now();
  final Directory dir = Directory('./files/');

  for (final f in dir.listSync()) {
    if (f is! File) continue;

    final timeSingle = DateTime.now();
    print('File: ${f.path}');
    print(AudioMeta(Uint8List.fromList(f.readAsBytesSync())));
    print(
        'Elapsed: ${DateTime.now().difference(timeSingle).inMilliseconds} ms\n');
  }

  print('Total:\t${DateTime.now().difference(time).inMilliseconds} ms');
  print(
      'Avg:\t${DateTime.now().difference(time).inMilliseconds / (AudioType.values.length - 1)} ms');
}
