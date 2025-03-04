part of '../audio_meta.dart';

int _getChannelCount(Uint8List bytes, AudioType type, int offset) =>
    switch (type) {
      AudioType.mp3 => _getMp3ChannelCount(bytes, offset),
      AudioType.wav => _getWavChannelCount(bytes, offset),
      AudioType.ogg => _getOggChannelCount(bytes, offset),
      AudioType.flac => _getFlacChannelCount(bytes, offset),
      AudioType.aac => _getAacChannelCount(bytes, offset),
      _ => 0,
    };

int _getAacChannelCount(Uint8List bytes, int offset) {
  return 0;
}

int _getFlacChannelCount(Uint8List bytes, int offset) {
  if (bytes.length < offset + 21) return 0;

  final byte = bytes[offset + 20];
  return ((byte >> 1) & 0x7) + 1;
}

int _getOggChannelCount(Uint8List bytes, int offset) {
  return 0;
}

int _getWavChannelCount(Uint8List bytes, int offset) {
  return 0;
}

int _getMp3ChannelCount(Uint8List bytes, int offset) {
  return 0;
}
