part of '../audio_meta.dart';

int? _getBitDepth(
        Uint8List bytes, AudioType type, int offset, EncodingType encoding) =>
    switch (type) {
      AudioType.mp3 => _getMp3BitDepth(bytes, offset),
      AudioType.wav => _getWavBitDepth(bytes, offset),
      AudioType.ogg => _getOggBitDepth(bytes, offset, encoding),
      AudioType.flac => _getFlacBitDepth(bytes, offset),
      AudioType.aac => _getAacBitDepth(bytes, offset),
      _ => 0,
    };

/// AAC has no bit depth, it's chosen by the encoder during requantization.
/// The bit depth of the source audio is not preserved.
int? _getAacBitDepth(Uint8List bytes, int offset) {
  return null;
}

int _getFlacBitDepth(Uint8List bytes, int offset) {
  if (bytes.length < offset + 22) return 0;

  final byte12 = bytes[offset + 20];
  final byte13 = bytes[offset + 21];

  return (((byte12 & 0x01) << 4) | (byte13 >> 4)) + 1;
}

/// OGG has no bit depth, except if it's storing FLAC audio.
int? _getOggBitDepth(Uint8List bytes, int offset, EncodingType encoding) {
  if (encoding == EncodingType.oggFlac) {
    final flacOffset = _getFlacHeaderOffset(bytes)?.$1;
    if (flacOffset == null) return null;
    return _getFlacBitDepth(bytes, flacOffset);
  }
  return null;
}

int _getWavBitDepth(Uint8List bytes, int offset) {
  if (bytes.length < offset + 23) return 0;

  final byte16 = bytes[offset + 22];
  final byte17 = bytes[offset + 23];

  return (byte17 << 8) | byte16;
}

/// MP3 has no bit depth, it's chosen by the encoder during requantization.
/// The bit depth of the source audio is not preserved.
int? _getMp3BitDepth(Uint8List bytes, int offset) {
  return null;
}
