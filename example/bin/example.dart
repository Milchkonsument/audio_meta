import 'package:audio_meta/audio_meta.dart';

void main(List<String> arguments) {
  final time = DateTime.now();

  for (var type in AudioType.values) {
    if (type == AudioType.unknown) continue;
    final timeSingle = DateTime.now();
    print(AudioMeta.fromPath('files/example.${type.name}'));
    print(
        'Elapsed: ${DateTime.now().difference(timeSingle).inMilliseconds} ms\n');
  }

  print('Total:\t${DateTime.now().difference(time).inMilliseconds} ms');
  print(
      'Avg:\t${DateTime.now().difference(time).inMilliseconds / (AudioType.values.length - 1)} ms');
}
