part of '../audio_meta.dart';

int _getBitRate(Uint8List bytes, AudioType type) => switch (type) {
      AudioType.mp3 => _getMp3BitRate(bytes),
      AudioType.wav => _getWavBitRate(bytes),
      AudioType.ogg => _getOggBitRate(bytes),
      AudioType.flac => _getFlacBitRate(bytes),
      AudioType.aac => _getAacBitRate(bytes),
      AudioType.opus => _getOpusBitRate(bytes),
      _ => 0,
    };

int _getMp3BitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'Xing'.codeUnits]);
  if (offset == -1) return 0;

  final bitRate = bytes.skip(offset + 12).take(4).toList();
  return _bytesToIntILBE(bitRate) * 1000;
}

int _getWavBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fmt '.codeUnits]);
  if (offset == -1) return 0;

  final bitRate = bytes.skip(offset + 24).take(4).toList();
  return _bytesToIntILBE(bitRate) * 8;
}

int _getOggBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'vorbis'.codeUnits]);
  if (offset == -1) return 0;

  final bitRate = bytes.skip(offset + 30).take(4).toList();
  return _bytesToIntILBE(bitRate);
}

int _getFlacBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fLaC'.codeUnits]);
  if (offset == -1) return 0;

  final bitRate = bytes.skip(offset + 34).take(4).toList();
  return _bytesToIntILBE(bitRate);
}

int _getAacBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'mdat'.codeUnits]);
  if (offset == -1) return 0;

  final bitRate = bytes.skip(offset + 4).take(4).toList();
  return _bytesToIntILBE(bitRate) * 8;
}

int _getOpusBitRate(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'OpusHead'.codeUnits]);
  if (offset == -1) return 0;

  final bitRate = bytes.skip(offset + 12).take(4).toList();
  return _bytesToIntILBE(bitRate);
}
