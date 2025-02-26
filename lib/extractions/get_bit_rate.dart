part of '../audio_meta.dart';

int _getBitRate(Uint8List bytes, AudioType type) => switch (type) {
      AudioType.mp3 => _getMp3BitRate(bytes),
      AudioType.wav => _getWavBitRate(bytes),
      AudioType.ogg => _getOggBitRate(bytes),
      AudioType.flac => _getFlacBitRate(bytes),
      AudioType.aac => _getAacBitRate(bytes),
      _ => 0,
    };

// works
int _getMp3BitRate(Uint8List bytes) {
  // Check for Xing header (VBR)
  final xingOffset = bytes.indexOfSequence([...'Xing'.codeUnits]);

  if (bytes[xingOffset + 4] == 0) {
    // If no VBR bit rate is included, extract bitrate from MPEG frame (CBR)
    return _getMp3CbrBitRate(bytes);
  }

  if (xingOffset != -1 && bytes.length >= xingOffset + 16) {
    final bitRateBytes = bytes.sublist(xingOffset + 12, xingOffset + 16);
    return _bytesToIntBE(bitRateBytes) * 1000; // Xing header bitrate (VBR)
  }

  // If no Xing header, extract bitrate from MPEG frame (CBR)
  _getMp3CbrBitRate(bytes);

  return 0;
}

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

// works
int _getWavBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fmt '.codeUnits]);
  if (offset == -1) return 0;

  if (bytes.length >= offset + 28) {
    return _bytesToIntLE(bytes.sublist(offset + 16, offset + 20)) * 8;
  }

  return 0;
}

// ! doesn't work
int _getOggBitRate(Uint8List bytes) {
  // Check for Vorbis
  final vorbisOffset = bytes.indexOfSequence([...'vorbis'.codeUnits]);
  if (vorbisOffset != -1 && bytes.length >= vorbisOffset + 32) {
    final bitRateBytes = bytes.sublist(vorbisOffset + 28, vorbisOffset + 32);
    return _bytesToIntLE(bitRateBytes);
  }

  // Ogg Opus is VBR, so no need to check for constant bitrate
  return 0;
}

// ! doesn't work
int _getFlacBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fLaC'.codeUnits]);
  if (offset == -1 || bytes.length < offset + 34) return 0;

  final bitRate = bytes.skip(offset + 34).take(4).toList();
  return _bytesToIntILBE(bitRate);
}

// ! doesn't work
int _getAacBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'mdat'.codeUnits]);
  if (offset == -1) return 0;

  final bitRate = bytes.skip(offset + 4).take(4).toList();
  return _bytesToIntILBE(bitRate) * 8;
}
