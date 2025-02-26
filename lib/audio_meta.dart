import 'dart:io';
import 'dart:typed_data';

part 'enums.dart';
part 'constants.dart';
part 'conversion.dart';
part 'extensions.dart';
part 'extractions/get_type.dart';
part 'extractions/get_sample_rate.dart';
part 'extractions/get_bit_rate.dart';
part 'extractions/get_duration.dart';

final class AudioMeta {
  AudioMeta._(Uint8List bytes) {
    type = _getType(bytes);
    sampleRate = _getSampleRate(bytes, type);
    bitRate = _getBitRate(bytes, type);
    duration = _getDuration(bytes, type);
  }

  factory AudioMeta.fromFile(File file) =>
      AudioMeta.fromBytes(file.readAsBytesSync());
  factory AudioMeta.fromPath(String path) => AudioMeta.fromFile(File(path));
  factory AudioMeta.fromBytes(Uint8List bytes) => AudioMeta._(bytes);

  late final AudioType type;
  late final int sampleRate;
  late final int bitRate;
  late final Duration duration;

  @override
  String toString() =>
      'AudioMeta(${type.name}, ${sampleRate}Hz, ${bitRate}kbps, ${duration.inSeconds}s)';
}
