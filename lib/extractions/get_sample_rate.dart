part of '../audio_meta.dart';

int _getSampleRate(Uint8List bytes, AudioType type) => switch (type) {
      AudioType.mp3 => _getMp3SampleRate(bytes),
      AudioType.wav => _getWavSampleRate(bytes),
      AudioType.ogg => _getOggSampleRate(bytes),
      AudioType.flac => _getFlacSampleRate(bytes),
      AudioType.aac => _getAacSampleRate(bytes),
      AudioType.opus => _getOpusSampleRate(bytes),
      _ => 0,
    };

// works
int _getMp3SampleRate(Uint8List bytes) {
  for (int i = 0; i < bytes.length - 3; i++) {
    if (bytes[i] == 0xFF && bytes[i + 1] == 0xE0) {
      int sampleRateIndex = (bytes[i + 2] >> 2) & 0x03;
      int versionBits = (bytes[i + 1] >> 3) & 0x03;

      return _mp3SampleRatesByVersionBits[versionBits]?[sampleRateIndex] ?? 0;
    }
  }
  return 0;
}

// works
int _getWavSampleRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fmt '.codeUnits], 12);

  if (offset == -1 || bytes.length < offset + 16) return 0;

  final sampleRateBytes = bytes.sublist(offset + 12, offset + 16);
  return _bytesToIntLE(sampleRateBytes);
}

// works
int _getOggSampleRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([0x01, ...'vorbis'.codeUnits]);

  if (offset == -1 || bytes.length < offset + 16) return 0;

  final sampleRateBytes = bytes.sublist(offset + 12, offset + 16);
  return _bytesToIntLE(sampleRateBytes);
}

// works
int _getFlacSampleRate(Uint8List bytes) {
  if (bytes.length < 20) return 0;

  final byte10 = bytes[18];
  final byte11 = bytes[19];
  final byte12 = bytes[20];

  int sampleRate = ((byte10 << 12) | (byte11 << 4) | (byte12 >> 4));
  return sampleRate;
}

// works
int _getAacSampleRate(Uint8List bytes) {
  if (bytes.length < 7) {
    return 0;
  }

  final sampleRateIndex = (bytes[2] & 0x3C) >> 2;
  if (sampleRateIndex >= 0 && sampleRateIndex < _aacSampleRates.length) {
    return _aacSampleRates[sampleRateIndex];
  }

  return 0;
}

// works
int _getOpusSampleRate(Uint8List bytes) {
  int offset = bytes.indexOfSequence([...'OpusHead'.codeUnits]);
  if (offset == -1 || bytes.length < offset + 16) return 0;

  final sampleRateBytes = bytes.sublist(offset + 12, offset + 16);
  return _bytesToIntLE(sampleRateBytes);
}
