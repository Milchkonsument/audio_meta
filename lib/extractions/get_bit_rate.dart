part of '../audio_meta.dart';

int _getBitRate(
        Uint8List bytes, AudioType type, int offset, EncodingType encoding) =>
    switch (type) {
      AudioType.mp3 => _getMp3BitRate(bytes, offset, encoding),
      AudioType.wav => _getWavBitRate(bytes, offset),
      AudioType.ogg => _getOggBitRate(bytes, offset, encoding),
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
    var bitRates = <int>[];
    int? currentOffset = offset;

    while (currentOffset != null) {
      bitRates.add(_getMp3BitRateAtFrameOffset(bytes, currentOffset));
      currentOffset =
          bytes.indexOfSequence(_MP3_XING_HEADER_SEQUENCE, currentOffset + 8);
    }

    bitRates = bitRates.where((b) => b != 0).toList();
    return bitRates.fold(0, (a, b) => a + b) ~/ bitRates.length;
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

int _getOggBitRate(Uint8List bytes, int offset, EncodingType encoding) {
  if (encoding == EncodingType.oggVorbis) {
    final vorbisHeaderOffset =
        bytes.indexOfSequence(_OGG_VORBIS_HEADER_SEQUENCE);

    if (vorbisHeaderOffset == null) {
      return 0;
    }

    final bitrate = _bytesToIntBE(
        bytes.sublist(vorbisHeaderOffset + 20, vorbisHeaderOffset + 24));
    return bitrate;
  }

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

int _getAacBitRate(Uint8List bytes, int offset) {
  int? currentOffset = offset;
  final bitrates = <int>[];

  while (currentOffset != null) {
    final adtsFrameSize = ((bytes[currentOffset + 3] & 0x03) << 11) |
        ((bytes[currentOffset + 4] & 0xFF) << 3) |
        ((bytes[currentOffset + 5] & 0xE0) >> 5);

    final sampleRate = _AAC_SAMPLE_RATES_BY_SAMPLE_RATE_INDEX[
        (bytes[currentOffset + 2] >> 2) & 0x0F];

    if (sampleRate == -1) {
      // TODO implement sample rate extraction from ADTS header for variable sample rates
      continue;
    }

    if (sampleRate == 0) {
      continue;
    }

    final bitrate = (adtsFrameSize * 8 * sampleRate) / 1024;
    bitrates.add(bitrate.toInt());
    currentOffset = bytes.indexOfSequence(
        _AAC_ADTS_HEADER_SEQUENCE, currentOffset + adtsFrameSize - 1);
  }

  if (bitrates.isEmpty) {
    return 0;
  }

  return bitrates.fold(0, (a, b) => a + b) ~/ bitrates.length;
}
