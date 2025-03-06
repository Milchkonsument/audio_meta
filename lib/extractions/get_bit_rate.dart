part of '../audio_meta.dart';

int _getBitRate(
        Uint8List bytes, AudioType type, int offset, EncodingType encoding) =>
    switch (type) {
      AudioType.mp3 => _getMp3BitRate(bytes, offset, encoding),
      AudioType.wav => _getWavBitRate(bytes, offset),
      AudioType.ogg => _getOggBitRate(bytes, offset),
      AudioType.flac => _getFlacBitRate(bytes, offset),
      AudioType.aac => _getAacBitRate(bytes, offset),
      _ => 0,
    };

// works, although VBR is a little rough around the edges (inaccurate)
int _getMp3BitRate(Uint8List bytes, int offset, EncodingType encoding) {
  if (encoding == EncodingType.mp3Cbr) {
    return _getMp3BitRateAtFrameOffset(bytes, offset);
  }

  if (encoding == EncodingType.mp3Vbr) {
    var bitRateSamples = <int>[];
    int? currentOffset = offset;

    while (currentOffset != null && currentOffset < bytes.length - 4) {
      bitRateSamples.add(_getMp3BitRateAtFrameOffset(bytes, currentOffset));
      currentOffset = bytes.indexOfSequence([0xFF], currentOffset + 255);
    }
    bitRateSamples = bitRateSamples.where((b) => b != 0).toList();
    return bitRateSamples.fold(0, (a, b) => a + b) ~/ bitRateSamples.length;
  }

  return 0;
}

int _getMp3BitRateAtFrameOffset(Uint8List bytes, int offset) {
  final mpegVersion = (bytes[offset + 1] >> 3) & 0x03;
  final mpegLayer = (bytes[offset + 1] >> 1) & 0x03;
  final bitrateIndex = (bytes[offset + 2] >> 4) & 0x0F;

  return (_MP3_BITRATE_BY_BIT_INDEX_AND_VERSION_AND_LAYER[bitrateIndex]
              ?[mpegVersion]?[mpegLayer] ??
          0) *
      1000;
}

// works
int _getWavBitRate(Uint8List bytes, int offset) {
  if (bytes.length < offset + 20) {
    return 0;
  }

  return _bytesToIntLE(bytes.sublist(offset + 16, offset + 20)) * 8;
}

// ? works partially (no VBR support)
int _getOggBitRate(Uint8List bytes, int offset) {
  // vorbis
  if (bytes.length > offset + 24) {
    final bitRateBytes = bytes.sublist(offset + 20, offset + 24);
    return _bytesToIntLE(bitRateBytes);
  }

  // ! Ogg Opus ?
  return 0;
}

// works
int _getFlacBitRate(Uint8List bytes, int offset) {
  if (bytes.length < offset + 26) return 0;

  final byte21 = bytes[offset + 21];
  final byte22 = bytes[offset + 22];
  final byte23 = bytes[offset + 23];
  final byte24 = bytes[offset + 24];
  final byte25 = bytes[offset + 25];

  final sampleRate = _getFlacSampleRate(bytes, offset);
  final numberChannels = _getFlacChannelCount(bytes, offset);
  final bitDepth = _getFlacBitDepth(bytes, offset);

  if (sampleRate == 0) return 0;

  final totalSamples = ((byte21 & 0x0F) << 32) |
      byte22 << 24 |
      byte23 << 16 |
      byte24 << 8 |
      byte25;

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
int _getAacBitRate(Uint8List bytes, int offset) {
  var isADTSMPEG = bytes[offset] == 0xFF &&
      (bytes[offset + 1] == 0xF1 || bytes[offset + 1] == 0xF9);

  if (isADTSMPEG) {
    // frame length from bit 30 to 43 from the offset
    // [30-32] | [33-40] | [41-43]
    final frameLength = (bytes[offset + 3] & 0x03) << 11 |
        bytes[offset + 4] << 3 |
        (bytes[offset + 5] & 0xE0) >> 5;

    print(
        '[${bytes[offset + 3].toRadixString(2).padLeft(8, '0')}][${bytes[offset + 4].toRadixString(2).padLeft(8, '0')}][${bytes[offset + 5].toRadixString(2).padLeft(8, '0')}]');
    print(
        'frameLength: $frameLength \n0x${frameLength.toRadixString(2).padLeft(32, '0')}');

    final bitRate =
        (frameLength * 8 * _getAacSampleRate(bytes, offset)) ~/ 1024;
    return bitRate;
  }

  // ADIF Bitrate Extraction (bits 48-71 → 24-bit big-endian integer)
  // ? not tested yet
  final bitRate = [bytes[7], bytes[8], bytes[9] & 0xF0];
  return _bytesToIntILBE(bitRate) * 8;
}
