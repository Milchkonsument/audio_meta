import 'dart:math';
import 'dart:typed_data';

import 'package:audio_meta/exceptions.dart';

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

/// [AudioMeta] is a lightweight class that extracts audio stream info from audio data.
///
/// Currently supported audio types: `mp3`, `wav`, `ogg`, `flac`, `aac`, `opus`.
///
/// Example:
/// ```dart
/// final meta = AudioMeta(Uint8List.fromList(File('audio.mp3').readAsBytesSync()));
/// print(meta.type); // AudioType.mp3
/// print(meta.sampleRate); // 44100
/// print(meta.bitRate); // 128000
/// print(meta.duration); // Duration(seconds: 180)
/// ```
final class AudioMeta {
  /// [AudioMeta] is a lightweight class that extracts audio stream info from audio data.
  ///
  /// Currently supported audio types: `mp3`, `wav`, `ogg`, `flac`, `aac`, `opus`.
  ///
  /// Example:
  /// ```dart
  /// final meta = AudioMeta(Uint8List.fromList(File('audio.mp3').readAsBytesSync()));
  /// print(meta.type); // AudioType.mp3
  /// print(meta.sampleRate); // 44100
  /// print(meta.bitRate); // 128000
  /// print(meta.duration); // Duration(seconds: 180)
  /// ```
  AudioMeta(Uint8List bytes) {
    (int, AudioType, EncodingType)? offsetTypeAndEncoding;

    try {
      offsetTypeAndEncoding = _getHeaderOffsetTypeAndEncoding(bytes);
    } catch (e) {
      throw ExtractionException('Error reading audio data: $e');
    }

    if (offsetTypeAndEncoding == null) {
      throw ExtractionException('Unsupported audio type');
    }

    final offset = offsetTypeAndEncoding.$1;
    final type = offsetTypeAndEncoding.$2;
    final encoding = offsetTypeAndEncoding.$3;

    this.type = type;
    this.encoding = encoding;

    try {
      sampleRate = _getSampleRate(bytes, type, offset, encoding);
      bitRate = _getBitRate(bytes, type, offset, encoding);
      duration = _getDuration(bytes, type, offset, encoding);
      channelCount = _getChannelCount(bytes, type, offset, encoding);
      bitDepth = _getBitDepth(bytes, type, offset, encoding);
    } catch (e) {
      throw ExtractionException('Error extracting metadata: $e');
    }
  }

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
  /// (The bit depth of lossy audio encodings is picked by the encoder
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
