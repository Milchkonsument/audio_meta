part of '../audio_meta.dart';

Duration _getDuration(
        Uint8List bytes, AudioType type, int offset, EncodingType encoding) =>
    switch (type) {
      AudioType.mp3 => _getMp3Duration(bytes, offset, encoding),
      AudioType.wav => _getWavDuration(bytes, offset),
      AudioType.ogg => _getOggDuration(bytes, offset, encoding),
      AudioType.flac => _getFlacDuration(bytes, offset),
      AudioType.aac => _getAacDuration(bytes, offset, encoding),
      _ => Duration.zero,
    };

Duration _getMp3Duration(Uint8List bytes, int offset, EncodingType encoding) {
  if (encoding == EncodingType.mp3Cbr) {
    final bitrate = _getMp3BitRate(bytes, offset, encoding);
    final fileSizeBits = bytes.length * 8;
    final durationMs = fileSizeBits / bitrate * 1000;
    return Duration(milliseconds: durationMs.toInt());
  }

  if (encoding == EncodingType.mp3Vbr) {
    return _estimateMp3DurationFromFrames(bytes, offset, encoding);
  }

  return Duration.zero;
}

Duration _estimateMp3DurationFromFrames(
    Uint8List bytes, int offset, EncodingType encoding) {
  final versionIndex = (bytes[offset + 1] >> 3) & 0x03;
  final samplesPerFrame =
      _MP3_SAMPLES_PER_FRAME_BY_VERSION_INDEX[versionIndex]!;
  final sampleRate = _getMp3SampleRate(bytes, offset, encoding);

  var frameCount = 0;
  int? currentOffset = offset;
  final headerSequence = encoding == EncodingType.mp3Cbr
      ? _MP3_MPEG_HEADER_SEQUENCE
      : _MP3_XING_HEADER_SEQUENCE;

  while (currentOffset != null) {
    currentOffset = bytes._indexOfSequence(headerSequence, currentOffset + 4);
    frameCount++;
  }

  final durationInMs = frameCount * samplesPerFrame / sampleRate * 8 * 100000;
  return Duration(milliseconds: durationInMs.round());
}

Duration _getWavDuration(Uint8List bytes, int offset) {
  final dataOffset = bytes._indexOfSequence('data'.codeUnits);
  if (dataOffset == null) return Duration.zero;

  int dataSizeBits =
      _bytesToIntILBE(bytes.sublist(dataOffset + 4, dataOffset + 8)) * 8;

  int bitRate = _getWavBitRate(bytes, offset);

  return bitRate > 0
      ? Duration(milliseconds: dataSizeBits ~/ bitRate)
      : Duration.zero;
}

Duration _getOggDuration(Uint8List bytes, int offset, EncodingType encoding) {
  if (encoding == EncodingType.oggFlac) {
    final flacOffset = bytes._indexOfSequence(_FLAC_HEADER_SEQUENCE, offset);
    if (flacOffset == null) return Duration.zero;
    return _getFlacDuration(bytes, flacOffset);
  }

  final lastOggPageOffset = bytes._indexOfSequenceFromEnd('OggS'.codeUnits);

  if (lastOggPageOffset == null) return Duration.zero;

  int granulePosition =
      ByteData.sublistView(bytes, lastOggPageOffset + 6, lastOggPageOffset + 14)
          .getInt64(0, Endian.little);

  int sampleRate = _getOggSampleRate(bytes, offset);

  final durationInMs = (granulePosition / sampleRate * 1000).toInt();
  return Duration(milliseconds: durationInMs);
}

Duration _getFlacDuration(Uint8List bytes, int offset) {
  final bitRate = _getFlacBitRate(bytes, offset);
  if (bitRate == 0) return Duration.zero;
  final dataSize = bytes.length - offset;
  final durationInMs = ((dataSize * 8) / bitRate * 1000).toInt();
  return Duration(milliseconds: durationInMs);
}

Duration _getAacDuration(Uint8List bytes, int offset, EncodingType encoding) {
  int? currentOffset = offset;
  int milliseconds = 0;

  while (currentOffset != null) {
    final containsCRC = bytes[currentOffset + 1] & 0x01;
    final adtsFrameHeaderSizeInBytes = containsCRC == 0 ? 7 : 9;
    final adtsFrameSize = ((bytes[currentOffset + 3] & 0x03) << 11) |
        ((bytes[currentOffset + 4] & 0xFF) << 3) |
        ((bytes[currentOffset + 5] & 0xE0) >> 5);
    final aacContentSizeBytes = adtsFrameSize - adtsFrameHeaderSizeInBytes;

    final sampleRate = _AAC_SAMPLE_RATES_BY_SAMPLE_RATE_INDEX[
        (bytes[currentOffset + 2] >> 2) & 0x0F];

    if (sampleRate == -1) {
      // TODO implement sample rate extraction for custom sample rates
      continue;
    }

    if (sampleRate == 0) {
      continue;
    }

    final bitrate = (adtsFrameSize * 8 * sampleRate) / 1024;
    milliseconds += (aacContentSizeBytes * 8 / bitrate * 1000).toInt();
    currentOffset = bytes._indexOfSequence(
        _AAC_ADTS_HEADER_SEQUENCE, currentOffset + adtsFrameSize - 1);
  }

  return Duration(milliseconds: milliseconds);
}
