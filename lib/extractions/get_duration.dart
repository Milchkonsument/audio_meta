part of '../audio_meta.dart';

Duration _getDuration(Uint8List bytes, AudioType type) => switch (type) {
      AudioType.mp3 => _getMp3Duration(bytes),
      AudioType.wav => _getWavDuration(bytes),
      AudioType.ogg => _getOggDuration(bytes),
      AudioType.flac => _getFlacDuration(bytes),
      AudioType.aac => _getAacDuration(bytes),
      AudioType.opus => _getOpusDuration(bytes),
      _ => Duration.zero,
    };

Duration _getMp3Duration(Uint8List bytes) {
  final offset = bytes.indexOfSequence('TLEN'.codeUnits);
  if (offset != -1) {
    final durationBytes = bytes.sublist(offset + 7, offset + 11);
    return Duration(seconds: _bytesToIntILBE(durationBytes));
  }

  // If TLEN is not found, estimate from MP3 frame headers
  return _estimateMp3DurationFromFrames(bytes);
}

Duration _estimateMp3DurationFromFrames(Uint8List bytes) {
  int frameCount = 0;
  int totalBitrate = 0;

  for (int i = 0; i < bytes.length - 4; i++) {
    if (bytes[i] == 0xFF && (bytes[i + 1] & 0xE0) == 0xE0) {
      // Frame sync
      int bitrateIndex = (bytes[i + 2] >> 4) & 0x0F;
      int sampleRateIndex = (bytes[i + 2] >> 2) & 0x03;
      int versionIndex = (bytes[i + 1] >> 3) & 0x03;

      if (bitrateIndex == 0xF || sampleRateIndex == 0x03) continue;

      int bitrate = _mp3Bitrates[bitrateIndex];
      int sampleRate =
          _mp3SampleRatesByVersionBits[versionIndex]?[sampleRateIndex] ?? 0;

      if (bitrate == 0 || sampleRate == 0) continue;

      frameCount++;
      totalBitrate += bitrate;
    }
  }

  if (frameCount == 0) return Duration.zero;
  return Duration(
      milliseconds: (bytes.length * 8) ~/ (totalBitrate ~/ frameCount));
}

Duration _getWavDuration(Uint8List bytes) {
  final fmtOffset = bytes.indexOfSequence('fmt '.codeUnits);
  final dataOffset = bytes.indexOfSequence('data'.codeUnits);
  if (fmtOffset == -1 || dataOffset == -1) return Duration.zero;

  int byteRate =
      _bytesToIntILBE(bytes.sublist(fmtOffset + 8 + 8, fmtOffset + 8 + 12));
  int dataSize = _bytesToIntILBE(bytes.sublist(dataOffset + 4, dataOffset + 8));

  return byteRate > 0
      ? Duration(milliseconds: (dataSize * 1000) ~/ byteRate)
      : Duration.zero;
}

Duration _getOggDuration(Uint8List bytes) {
  final offset = bytes.indexOfSequence('OggS'.codeUnits);
  if (offset == -1) return Duration.zero;

  final granulePos = bytes.sublist(offset + 6, offset + 14);
  return Duration(milliseconds: _bytesToIntILBE(granulePos) ~/ 48);
}

Duration _getFlacDuration(Uint8List bytes) {
  final offset = bytes.indexOfSequence('fLaC'.codeUnits);
  if (offset == -1) return Duration.zero;

  final sampleRateBytes = bytes.sublist(offset + 18, offset + 22);
  final sampleCountBytes = bytes.sublist(offset + 22, offset + 26);
  int sampleRate = _bytesToIntILBE(sampleRateBytes);
  int sampleCount = _bytesToIntILBE(sampleCountBytes);

  return sampleRate > 0
      ? Duration(seconds: sampleCount ~/ sampleRate)
      : Duration.zero;
}

Duration _getAacDuration(Uint8List bytes) {
  final offset = bytes.indexOfSequence('mdat'.codeUnits);
  if (offset == -1) return Duration.zero;

  final durationBytes = bytes.sublist(offset + 8, offset + 12);
  return Duration(seconds: _bytesToIntILBE(durationBytes));
}

Duration _getOpusDuration(Uint8List bytes) {
  final offset = bytes.indexOfSequence('OpusHead'.codeUnits);
  if (offset == -1) return Duration.zero;

  final preSkipBytes = bytes.sublist(offset + 10, offset + 12);
  int preSkip = _bytesToIntILBE(preSkipBytes);
  return Duration(milliseconds: preSkip);
}
