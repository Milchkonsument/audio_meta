import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_meta/exceptions.dart';
import 'package:audio_meta/impl/impl_io.dart'
    if (dart.library.html) 'impl/impl_web.dart' as impl;

part 'enums.dart';
part 'constants.dart';
part 'conversion.dart';
part 'extensions.dart';
part 'extractions/get_header_offset.dart';
part 'extractions/get_sample_rate.dart';
part 'extractions/get_bit_rate.dart';
part 'extractions/get_duration.dart';
part 'extractions/get_channel_count.dart';
part 'extractions/get_bit_depth.dart';

/// [AudioMeta] is a lightweight class that extracts audio metadata from audio data.
///
/// Currently supported audio types: `mp3`, `wav`, `ogg`, `flac`, `aac`.
///
/// Use [AudioMeta.fromFile], [AudioMeta.fromPath], or [AudioMeta.fromBytes]
/// to create an instance synchronously.
///
/// Use [AudioMeta.fromFileAsync], [AudioMeta.fromPathAsync],
/// or [AudioMeta.fromBytesAsync] to create an instance asynchronously.
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
    final offsetTypeAndEncoding = _getHeaderOffsetTypeAndEncoding(bytes);

    if (offsetTypeAndEncoding == null) {
      throw ExtractionException('Unsupported audio type');
    }

    final offset = offsetTypeAndEncoding.$1;
    final type = offsetTypeAndEncoding.$2;
    final encoding = offsetTypeAndEncoding.$3;

    this.type = type;
    this.encoding = encoding;

    void _timed(String name, void Function() action) {
      print(name);
      final now = DateTime.now();
      action();
      final elapsed = DateTime.now().difference(now);
      print('Elapsed: ${elapsed.inMilliseconds} ms');
    }

    _timed('Extracting sample rate', () {
      sampleRate = _getSampleRate(bytes, type, offset, encoding);
    });
    _timed('Extracting bit rate', () {
      bitRate = _getBitRate(bytes, type, offset, encoding);
    });
    _timed('Extracting duration', () {
      duration = _getDuration(bytes, type, offset, encoding);
    });
    _timed('Extracting channel count', () {
      channelCount = _getChannelCount(bytes, type, offset, encoding);
    });
    _timed('Extracting bit depth', () {
      bitDepth = _getBitDepth(bytes, type, offset, encoding);
    });

    // sampleRate = _getSampleRate(bytes, type, offset, encoding);
    // bitRate = _getBitRate(bytes, type, offset, encoding);
    // duration = _getDuration(bytes, type, offset, encoding);
    // channelCount = _getChannelCount(bytes, type, offset, encoding);
    // bitDepth = _getBitDepth(bytes, type, offset, encoding);
  }

  /// Create an instance of [AudioMeta] from a [File].
  ///
  /// This constructor is unsupported on web.
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  ///
  /// Throws an [ExtractionException] if any error occurs during extraction
  /// of metadata.
  ///
  /// Example:
  /// ```dart
  /// final meta = AudioMeta.fromFile(File('audio.mp3'));
  /// print(meta.type); // AudioType.mp3
  /// ```
  factory AudioMeta.fromFile(File file) => impl.fromFileImpl(file);

  /// Create an instance of [AudioMeta] from a file at the given [path].
  ///
  /// This constructor is unsupported on web.
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  ///
  /// Throws an [ExtractionException] if any error occurs during extraction
  /// of metadata.
  ///
  /// Example:
  /// ```dart
  /// final meta = AudioMeta.fromPath('audio.mp3');
  /// print(meta.type); // AudioType.mp3
  /// ```
  factory AudioMeta.fromPath(String path) => impl.fromPathImpl(path);

  /// Create an instance of [AudioMeta] from given [bytes].
  ///
  /// This constructor is supported on web.
  ///
  /// Throws an [ExtractionException] if any error occurs during extraction
  /// of metadata.
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
  /// This constructor is unsupported on web.
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  ///
  /// Throws an [ExtractionException] if any error occurs during extraction
  /// of metadata.
  ///
  /// Example:
  /// ```dart
  /// final file = File('audio.mp3');
  /// final meta = await AudioMeta.fromFileAsync(file);
  /// print(meta.type); // AudioType.mp3
  /// ```
  static Future<AudioMeta> fromFileAsync(File file) =>
      impl.fromFileAsyncImpl(file);

  /// Create an instance of [AudioMeta] from a file
  /// at the given [path] asynchronously.
  ///
  /// This constructor is unsupported on web.
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  ///
  /// Throws an [ExtractionException] if any error occurs during extraction
  /// of metadata.
  ///
  /// Example:
  /// ```dart
  /// final meta = await AudioMeta.fromPathAsync('audio.mp3');
  /// print(meta.type); // AudioType.mp3
  /// ```
  static Future<AudioMeta> fromPathAsync(String path) =>
      impl.fromPathAsyncImpl(path);

  /// Create an instance of [AudioMeta] from given [bytes] asynchronously.
  ///
  /// This constructor is supported on web.
  ///
  /// Throws an [ExtractionException] if any error occurs during extraction
  /// of metadata.
  ///
  /// Example:
  /// ```dart
  /// final response = await http.get(Uri.parse('https://example.com/audio.mp3'));
  /// final bytes = response.bodyBytes;
  /// final meta = await AudioMeta.fromBytesAsync(bytes);
  /// print(meta.type); // AudioType.mp3
  /// ```
  static Future<AudioMeta> fromBytesAsync(Uint8List bytes) async =>
      AudioMeta._(bytes);

  /// Audio file type
  late final AudioType type;

  /// Audio encoding type
  late final EncodingType encoding;

  /// Audio sample rate in Hz
  late final int sampleRate;

  /// Audio bit rate in bps
  late final int bitRate;

  /// Audio duration
  late final Duration duration;

  /// Number of audio channels
  late final int channelCount;

  /// Audio bit depth
  ///
  /// For lossy audio encodings, bit depth doesn't exist and will be `null`.
  /// (The bit depth of lossy audio ecodings is picked by the encoder
  /// and is not part of the audio data.)
  late final int? bitDepth;

  /// Audio bit rate in kbps
  int get kBitRate => bitRate ~/ 1000;

  /// Audio duration in seconds
  double get durationInSeconds => duration.inMilliseconds / 1000;

  /// Audio sample rate in kHz
  double get sampleRateInKHz => sampleRate / 1000;

  @override
  String toString() =>
      'AudioMeta($encoding, ${sampleRateInKHz.toStringAsFixed(2)}kHz, ${kBitRate}kbps, $duration, $channelCount channels, ${bitDepth ?? '-'} bit depth)';
}
