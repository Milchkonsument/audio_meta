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
  int? offset;
  int searched = 0;

  while (offset == null) {
    final index = bytes.indexOfSequence(_MP3_HEADER_SEQUENCE, searched);

    if (index == null) {
      break;
    }

    if (bytes[index + 1] & 0xE0 == 0xE0) {
      offset = index;
    }

    searched = index;
  }

  return offset;
}

int? _getWavHeaderOffset(Uint8List bytes) {
  final offset = bytes.indexOfSequence(_WAV_HEADER_SEQUENCE, 12);
  return offset;
}

int? _getOggHeaderOffset(Uint8List bytes) {
  final offset = bytes.indexOfSequence(_OGG_VORBIS_HEADER_SEQUENCE, 64);
  // TODO handle other things than vorbis
  return offset;
}

int? _getFlacHeaderOffset(Uint8List bytes) {
  final offset = bytes.indexOfSequence(_FLAC_HEADER_SEQUENCE);
  return offset;
}

int? _getAacHeaderOffset(Uint8List bytes) {
  var offset = bytes.indexOfSequence(_AAC_HEADER_SEQUENCE_ADIF, 0, 8) ??
      bytes.indexOfSequence(_AAC_HEADER_SEQUENCE_ADTS, 0, 8);

  return offset;
}
