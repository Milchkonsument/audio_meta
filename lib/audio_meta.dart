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

  /// Audio type (format) of the input bytes
  late final AudioType type;

  /// Audio sample rate in Hz
  late final int sampleRate;

  /// Audio bit rate in bps
  late final int bitRate;

  /// Audio duration
  late final Duration duration;

  /// Audio bit rate in kbps
  int get kBitRate => bitRate ~/ 1000;

  /// Audio duration in seconds
  double get durationInSeconds => duration.inMilliseconds / 1000;

  /// Audio sample rate in kHz
  double get sampleRateInKHz => sampleRate / 1000;

  @override
  String toString() =>
      'AudioMeta(${type.name}, ${sampleRateInKHz.toStringAsFixed(2)}kHz, ${kBitRate}kbps, ${durationInSeconds.toStringAsFixed(2)}s)';
}
