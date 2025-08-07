part of '../audio_meta.dart';

int _getSampleRate(
        Uint8List bytes, AudioType type, int offset, EncodingType encoding) =>
    switch (type) {
      AudioType.mp3 => _getMp3SampleRate(bytes, offset, encoding),
      AudioType.wav => _getWavSampleRate(bytes, offset),
      AudioType.ogg => _getOggSampleRate(bytes, offset),
      AudioType.flac => _getFlacSampleRate(bytes, offset),
      AudioType.aac => _getAacSampleRate(bytes, offset),
      _ => 0,
    };

// works
int _getMp3SampleRate(Uint8List bytes, int offset, EncodingType encoding) {
  if (bytes.length < offset + 3) return 0;

  int sampleRateIndex = (bytes[offset + 2] >> 2) & 0x03;
  int versionBits = (bytes[offset + 1] >> 3) & 0x03;

  return _mp3SampleRatesByVersionAndSampleRateIndex[versionBits]
          ?[sampleRateIndex] ??
      0;
}

int _getWavSampleRate(Uint8List bytes, int offset) {
  if (bytes.length < offset + 16) return 0;
  final sampleRateBytes = bytes.sublist(offset + 12, offset + 16);
  return _bytesToIntLE(sampleRateBytes);
}

int _getOggSampleRate(Uint8List bytes, int offset) {
  if (bytes.length < offset + 16) return 0;

  final sampleRateBytes = bytes.sublist(offset + 12, offset + 16);
  return _bytesToIntLE(sampleRateBytes);
}

int _getFlacSampleRate(Uint8List bytes, int offset) {
  if (bytes.length < offset + 20) return 0;

  final byte10 = bytes[offset + 18];
  final byte11 = bytes[offset + 19];
  final byte12 = bytes[offset + 20];

  int sampleRate = ((byte10 << 12) | (byte11 << 4) | (byte12 >> 4));
  return sampleRate;
}

int _getAacSampleRate(Uint8List bytes, int offset) {
  if (bytes.length < offset + 4) return 0;

  int sampleRateIndex = (bytes[offset + 2] >> 2) & 0x0F;

  int sampleRate = _aacSampleRatesBySampleRateIndex[sampleRateIndex];

  if (sampleRate == -1) {
    throw UnsupportedError('AAC custom sample rates are not yet supported');
  }

  return sampleRate;
}
