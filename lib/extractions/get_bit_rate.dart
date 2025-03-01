part of '../audio_meta.dart';

int _getBitRate(Uint8List bytes, AudioType type) => switch (type) {
      AudioType.mp3 => _getMp3BitRate(bytes),
      AudioType.wav => _getWavBitRate(bytes),
      AudioType.ogg => _getOggBitRate(bytes),
      AudioType.flac => _getFlacBitRate(bytes),
      AudioType.aac => _getAacBitRate(bytes),
      _ => 0,
    };

// ? works partially
int _getMp3BitRate(Uint8List bytes) {
  // Check for Xing header (VBR)
  final xingOffset = bytes.indexOfSequence([...'Xing'.codeUnits]);

  if (bytes[xingOffset + 4] == 0) {
    // If no VBR bit rate is included, extract bitrate from MPEG frame (CBR)
    return _getMp3CbrBitRate(bytes);
  }

  // ! this part is probably wrong / untested
  if (xingOffset != -1 && bytes.length >= xingOffset + 16) {
    final bitRateBytes = bytes.sublist(xingOffset + 12, xingOffset + 16);
    return _bytesToIntBE(bitRateBytes) * 1000; // Xing header bitrate (VBR)
  }

  // If no Xing header, extract bitrate from MPEG frame (CBR)
  _getMp3CbrBitRate(bytes);

  return 0;
}

// works
int _getMp3CbrBitRate(Uint8List bytes) {
  for (int i = 0; i < bytes.length - 3; i++) {
    if (bytes[i] == 0xFF && (bytes[i + 1] & 0xE0) == 0xE0) {
      int bitRateIndex = (bytes[i + 2] >> 4) & 0x0F;
      int versionBit = (bytes[i + 1] >> 3) & 0x03;

      return _mp3BitRatesByVersionBits[versionBit]?[bitRateIndex] ?? 0;
    }
  }

  return 0;
}

// ? works partially
int _getWavBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fmt '.codeUnits]);
  if (offset == -1) return 0;

  if (bytes.length >= offset + 28) {
    return _bytesToIntLE(bytes.sublist(offset + 16, offset + 20)) * 8;
  }

  return 0;
}

// works
int _getOggBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([0x01, ...'vorbis'.codeUnits]);

  if (offset != -1 && bytes.length >= offset + 24) {
    final bitRateBytes = bytes.sublist(offset + 20, offset + 24);
    return _bytesToIntLE(bitRateBytes);
  }

  // ! Ogg Opus ?
  return 0;
}

// works
int _getFlacBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fLaC'.codeUnits]);
  if (offset == -1 || bytes.length < offset + 42) return 0;

  final byte10 = bytes[offset + 18];
  final byte11 = bytes[offset + 19];
  final byte12 = bytes[offset + 20];
  final byte13 = bytes[offset + 21];

  final byte14 = bytes[offset + 22];
  final byte15 = bytes[offset + 23];
  final byte16 = bytes[offset + 24];
  final byte17 = bytes[offset + 25];

  final sampleRate = ((byte10 << 12) | (byte11 << 4) | (byte12 >> 4));
  final numberChannels = ((byte12 >> 1) & 0x7) + 1;
  final bitDepth = (((byte12 & 0x1) << 4) | (byte13 >> 4)) + 1;

  if (sampleRate == 0) return 0;

  final totalSamples = ((byte13 & 0xF) << 32) |
      byte14 << 24 |
      byte15 << 16 |
      byte16 << 8 |
      byte17;

  if (totalSamples == 0) return 0;

  final uncompressedBitRate = sampleRate * bitDepth * numberChannels;
  final duration = totalSamples / sampleRate;
  final compressedSize = bytes.length;
  final uncompressedSize = uncompressedBitRate / 8 * duration;
  final compressionRatio = uncompressedSize / compressedSize;
  final compressedBitRate = uncompressedBitRate / compressionRatio;

  return compressedBitRate.round();
}

// ! doesn't work
int _getAacBitRate(Uint8List bytes) {
  var isADTSMPEG = false;

  var offset = bytes.indexOfSequence([...'ADIF'.codeUnits], 0, 8);

  if (offset == -1) {
    offset = bytes.indexOfSequence([0xFF, 0xF1], 0, 8);
    if (offset != -1) isADTSMPEG = true;
  }

  if (offset == -1) {
    offset = bytes.indexOfSequence([0xFF, 0xF9], 0, 8);
    if (offset != -1) isADTSMPEG = true;
  }

  if (offset == -1) return 0;

  if (isADTSMPEG) {
    final bitRate = (bytes[1] >> 2) & 0x0F;
    if (bitRate >= _aacAdtsBitRates.length) {
      return 0;
    }

    return _aacAdtsBitRates[bitRate];
  }

  final bitRate = bytes.sublist(offset + 6, offset + 9);
  return _bytesToIntBE(bitRate) * 8;
}
