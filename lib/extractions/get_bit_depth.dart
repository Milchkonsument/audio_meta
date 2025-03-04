part of '../audio_meta.dart';

int _getBitDepth(Uint8List bytes, AudioType type, int offset) => switch (type) {
      AudioType.mp3 => _getMp3BitDepth(bytes, offset),
      AudioType.wav => _getWavBitDepth(bytes, offset),
      AudioType.ogg => _getOggBitDepth(bytes, offset),
      AudioType.flac => _getFlacBitDepth(bytes, offset),
      AudioType.aac => _getAacBitDepth(bytes, offset),
      _ => 0,
    };

int _getAacBitDepth(Uint8List bytes, int offset) {
  return 0;
}

int _getFlacBitDepth(Uint8List bytes, int offset) {
  if (bytes.length < offset + 22) return 0;

  final byte12 = bytes[offset + 20];
  final byte13 = bytes[offset + 21];

  return (((byte12 & 0x01) << 4) | (byte13 >> 4)) + 1;
}

int _getOggBitDepth(Uint8List bytes, int offset) {
  return 0;
}

int _getWavBitDepth(Uint8List bytes, int offset) {
  return 0;
}

int _getMp3BitDepth(Uint8List bytes, int offset) {
  return 0;
}
