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

/// [AudioMeta] is a lightweight class that extracts audio metadata from audio data.
///
/// Currently supported audio types: mp3, wav, ogg, flac, aac.
///
/// Use [AudioMeta.fromFile], [AudioMeta.fromPath], or [AudioMeta.fromBytes] to create an instance.
///
/// Example:
/// ```dart
/// final meta = AudioMeta.fromFile(File('audio.mp3'));
/// print(meta.type); // AudioType.mp3
/// print(meta.sampleRate); // 44100
/// print(meta.bitRate); // 128000
/// print(meta.duration); // Duration(seconds: 180)
/// ```
final class AudioMeta {
  AudioMeta._(Uint8List bytes) {
    type = _getType(bytes);
    sampleRate = _getSampleRate(bytes, type);
    bitRate = _getBitRate(bytes, type);
    duration = _getDuration(bytes, type);
  }

  /// Create an instance of [AudioMeta] from a [File].
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  ///
  /// Example:
  /// ```dart
  /// final meta = AudioMeta.fromFile(File('audio.mp3'));
  /// print(meta.type); // AudioType.mp3
  /// ```
  factory AudioMeta.fromFile(File file) =>
      AudioMeta.fromBytes(file.readAsBytesSync());

  /// Create an instance of [AudioMeta] from a file at the given [path].
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  ///
  /// Example:
  /// ```dart
  /// final meta = AudioMeta.fromPath('audio.mp3');
  /// print(meta.type); // AudioType.mp3
  /// ```
  factory AudioMeta.fromPath(String path) => AudioMeta.fromFile(File(path));

  /// Create an instance of [AudioMeta] from given [bytes].
  ///
  /// Example:
  /// ```dart
  /// final response = await http.get(Uri.parse('https://example.com/audio.mp3'));
  /// final bytes = response.bodyBytes;
  /// final meta = AudioMeta.fromBytes(bytes);
  /// print(meta.type); // AudioType.mp3
  /// ```
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
