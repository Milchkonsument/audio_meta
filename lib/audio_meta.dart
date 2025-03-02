import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

part 'enums.dart';
part 'constants.dart';
part 'conversion.dart';
part 'extensions.dart';
part 'extractions/get_type.dart';
part 'extractions/get_sample_rate.dart';
part 'extractions/get_bit_rate.dart';
part 'extractions/get_duration.dart';
part 'extractions/get_channel_count.dart';
part 'extractions/get_bit_depth.dart';

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
    channelCount = _getChannelCount(bytes, type);
    bitDepth = _getBitDepth(bytes, type);
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

  /// Create an instance of [AudioMeta] from a [File] asynchronously.
  ///
  /// This method runs on a separate isolate to prevent blocking
  /// the main thread / UI, which is useful for large audio files.
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  ///
  /// Example:
  /// ```dart
  /// final file = File('audio.mp3');
  /// final meta = await AudioMeta.fromFileAsync(file);
  /// print(meta.type); // AudioType.mp3
  /// ```
  static Future<AudioMeta> fromFileAsync(File file) async =>
      Isolate.run(() async => AudioMeta.fromBytes(await file.readAsBytes()));

  /// Create an instance of [AudioMeta] from a file
  /// at the given [path] asynchronously.
  ///
  /// This method runs on a separate isolate to prevent blocking
  /// the main thread / UI, which is useful for large audio files.
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  ///
  /// Example:
  /// ```dart
  /// final meta = await AudioMeta.fromPathAsync('audio.mp3');
  /// print(meta.type); // AudioType.mp3
  /// ```
  static Future<AudioMeta> fromPathAsync(String path) =>
      fromFileAsync(File(path));

  /// Create an instance of [AudioMeta] from given [bytes] asynchronously.
  ///
  /// This method runs on a separate isolate to prevent blocking
  /// the main thread / UI, which is useful for large audio files.
  ///
  /// Example:
  /// ```dart
  /// final response = await http.get(Uri.parse('https://example.com/audio.mp3'));
  /// final bytes = response.bodyBytes;
  /// final meta = await AudioMeta.fromBytesAsync(bytes);
  /// print(meta.type); // AudioType.mp3
  /// ```
  static Future<AudioMeta> fromBytesAsync(Uint8List bytes) =>
      Isolate.run(() => AudioMeta._(bytes));

  /// Audio type (format) of the input bytes
  late final AudioType type;

  /// Audio sample rate in Hz
  late final int sampleRate;

  /// Audio bit rate in bps
  late final int bitRate;

  /// Audio duration
  late final Duration duration;

  /// Number of audio channels
  late final int channelCount;

  /// Audio bit depth
  late final int bitDepth;

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
