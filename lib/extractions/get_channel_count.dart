part of '../audio_meta.dart';

int _getChannelCount(
        Uint8List bytes, AudioType type, int offset, EncodingType encoding) =>
    switch (type) {
      AudioType.mp3 => _getMp3ChannelCount(bytes, offset),
      AudioType.wav => _getWavChannelCount(bytes, offset),
      AudioType.ogg => _getOggChannelCount(bytes, offset, encoding),
      AudioType.flac => _getFlacChannelCount(bytes, offset),
      AudioType.aac => _getAacChannelCount(bytes, offset, encoding),
      _ => 0,
    };

int _getAacChannelCount(Uint8List bytes, int offset, EncodingType encoding) {
  if (encoding == EncodingType.aacAdts) {
    if (bytes.length < offset + 4) return 0;
    final byte0 = bytes[offset + 2];
    final byte1 = bytes[offset + 3];
    return ((byte0 & 0x1) << 2) | ((byte1 & 0xC0) >> 6);
  }

  if (encoding == EncodingType.aacAdif) {
    // TODO
    return 2;
  }

  return 0;
}

// works
int _getFlacChannelCount(Uint8List bytes, int offset) {
  if (bytes.length < offset + 21) return 0;

  final byte = bytes[offset + 20];
  return ((byte >> 1) & 0x7) + 1;
}

int _getOggChannelCount(Uint8List bytes, int offset, EncodingType encoding) {
  if (encoding == EncodingType.oggFlac) {
    final offsetFlac = _getFlacHeaderOffset(bytes)?.$1;
    if (offsetFlac == null) return 0;
    return _getFlacChannelCount(bytes, offsetFlac);
  }

  if (encoding == EncodingType.oggOpus) {
    if (bytes.length < offset + 10) return 0;
    return bytes[offset + 9];
  }

  if (encoding == EncodingType.oggVorbis) {
    if (bytes.length < offset + 12) return 0;
    return bytes[offset + 11];
  }

  if (encoding == EncodingType.oggSpeex) {
    if (bytes.length < offset + 35) return 0;
    return bytes[offset + 34];
  }

  return 0;
}

int _getWavChannelCount(Uint8List bytes, int offset) {
  if (bytes.length < offset + 13) return 0;

  return _bytesToIntLE(bytes.sublist(offset + 10, offset + 12));
}

int _getMp3ChannelCount(Uint8List bytes, int offset) {
  if (bytes.length < offset + 4) return 0;
  final byte = bytes[offset + 3];
  return (byte >> 6) & 0x3 == 0x3 ? 1 : 2;
}
