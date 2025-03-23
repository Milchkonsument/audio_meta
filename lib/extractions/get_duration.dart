part of '../audio_meta.dart';

Duration _getDuration(
        Uint8List bytes, AudioType type, int offset, EncodingType encoding) =>
    switch (type) {
      AudioType.mp3 => _getMp3Duration(bytes, offset, encoding),
      AudioType.wav => _getWavDuration(bytes, offset),
      AudioType.ogg => _getOggDuration(bytes, offset),
      AudioType.flac => _getFlacDuration(bytes, offset),
      AudioType.aac => _getAacDuration(bytes, offset),
      _ => Duration.zero,
    };

Duration _getMp3Duration(Uint8List bytes, int offset, EncodingType encoding) {
  if (encoding == EncodingType.mp3Cbr) {
    final bitrate = _getMp3BitRate(bytes, offset, encoding);
    final fileSize = bytes.length;
    final headerSize = 4;
    final durationMs = (fileSize - headerSize) / bitrate * 1000;
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
    currentOffset = bytes.indexOfSequence(headerSequence, currentOffset + 4);
    frameCount++;
  }

  final durationInMs = frameCount * samplesPerFrame / sampleRate * 8 * 100000;
  return Duration(milliseconds: durationInMs.round());
}

Duration _getWavDuration(Uint8List bytes, int offset) {
  final dataOffset = bytes.indexOfSequence('data'.codeUnits);
  if (dataOffset == null) return Duration.zero;

  int byteRate =
      _bytesToIntILBE(bytes.sublist(offset + 8 + 8, offset + 8 + 12));
  int dataSize = _bytesToIntILBE(bytes.sublist(dataOffset + 4, dataOffset + 8));

  return byteRate > 0
      ? Duration(milliseconds: (dataSize * 1000) ~/ byteRate)
      : Duration.zero;
}

Duration _getOggDuration(Uint8List bytes, int offset) {
  if (bytes.length < offset + 14) return Duration.zero;

  final granulePos = bytes.sublist(offset + 6, offset + 14);
  return Duration(milliseconds: _bytesToIntILBE(granulePos) ~/ 48);
}

Duration _getFlacDuration(Uint8List bytes, int offset) {
  if (bytes.length < offset + 26) return Duration.zero;

  final sampleRateBytes = bytes.sublist(offset + 18, offset + 22);
  final sampleCountBytes = bytes.sublist(offset + 22, offset + 26);
  int sampleRate = _bytesToIntILBE(sampleRateBytes);
  int sampleCount = _bytesToIntILBE(sampleCountBytes);

  return sampleRate > 0
      ? Duration(seconds: sampleCount ~/ sampleRate)
      : Duration.zero;
}

Duration _getAacDuration(Uint8List bytes, int offset) {
  if (bytes.length < offset + 12) return Duration.zero;
  final durationBytes = bytes.sublist(offset + 8, offset + 12);
  return Duration(seconds: _bytesToIntILBE(durationBytes));
}
