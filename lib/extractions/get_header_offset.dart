part of '../audio_meta.dart';

int? _getHeaderOffset(Uint8List bytes, AudioType type) => (switch (type) {
      AudioType.mp3 => _getMp3HeaderOffset,
      AudioType.wav => _getWavHeaderOffset,
      AudioType.ogg => _getOggHeaderOffset,
      AudioType.flac => _getFlacHeaderOffset,
      AudioType.aac => _getAacHeaderOffset,
      _ => (_) => null,
    })(bytes);

int? _getMp3HeaderOffset(Uint8List bytes) {
  int? offset = bytes.indexOfSequence([...'Xing'.codeUnits]);
  offset ??= bytes.indexOfSequence([...'LAME'.codeUnits]);
  offset ??= bytes.indexOfSequence([...'Info'.codeUnits]);
  return offset;
}

int? _getWavHeaderOffset(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fmt '.codeUnits], 12);
  return offset;
}

int? _getOggHeaderOffset(Uint8List bytes) {
  final offset = bytes.indexOfSequence([0x01, ...'vorbis'.codeUnits]);
  // TODO handle other things than vorbis
  return offset;
}

int? _getFlacHeaderOffset(Uint8List bytes) {
  final offset = bytes.indexOfSequence([...'fLaC'.codeUnits]);
  return offset;
}

int? _getAacHeaderOffset(Uint8List bytes) {
  var offset = bytes.indexOfSequence([...'ADIF'.codeUnits], 0, 8) ??
      bytes.indexOfSequence([0xFF], 0, 8);

  return offset;
}
