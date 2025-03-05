part of '../audio_meta.dart';

(int, EncodingType)? _getHeaderOffsetAndEncoding(
        Uint8List bytes, AudioType type) =>
    (switch (type) {
      AudioType.mp3 => _getMp3HeaderOffset,
      AudioType.wav => _getWavHeaderOffset,
      AudioType.ogg => _getOggHeaderOffset,
      AudioType.flac => _getFlacHeaderOffset,
      AudioType.aac => _getAacHeaderOffset,
      _ => (_) => null,
    })(bytes);

(int, EncodingType)? _getMp3HeaderOffset(Uint8List bytes) {
  int? offset;
  int searched = 0;

  while (offset == null) {
    final index = bytes.indexOfSequence(_MP3_MPEG_HEADER_SEQUENCE, searched);

    if (index == null) {
      break;
    }

    if (bytes[index + 1] & 0xE0 == 0xE0) {
      offset = index;
    }

    searched = index;
  }

  if (offset == null) {
    return null;
  }

  final xingOffset =
      bytes.indexOfSequence(_MP3_XING_HEADER_SEQUENCE, offset, 64);

  return (
    offset,
    xingOffset == null ? EncodingType.mp3Cbr : EncodingType.mp3Vbr
  );
}

(int, EncodingType)? _getWavHeaderOffset(Uint8List bytes) {
  final offset = bytes.indexOfSequence(_WAV_HEADER_SEQUENCE, 12);
  var encoding = EncodingType.unknown;

  if (offset == null) {
    return null;
  }

  final formatCode = _bytesToIntLE(bytes.sublist(offset + 8, offset + 10));
  encoding = _WAV_FORMAT_CODES[formatCode] ?? EncodingType.unknown;

  return (offset, encoding);
}

(int, EncodingType)? _getOggHeaderOffset(Uint8List bytes) {
  var offset = bytes.indexOfSequence(_OGG_VORBIS_HEADER_SEQUENCE);

  if (offset != null) {
    return (offset, EncodingType.oggVorbis);
  }

  offset ??= bytes.indexOfSequence(_OGG_OPUS_HEADER_SEQUENCE);

  if (offset != null) {
    return (offset, EncodingType.oggOpus);
  }

  offset ??= bytes.indexOfSequence(_OGG_FLAC_HEADER_SEQUENCE);

  if (offset != null) {
    return (offset, EncodingType.oggFlac);
  }

  return null;
}

(int, EncodingType)? _getFlacHeaderOffset(Uint8List bytes) {
  final offset = bytes.indexOfSequence(_FLAC_HEADER_SEQUENCE);

  if (offset == null) {
    return null;
  }

  return (offset, EncodingType.flac);
}

(int, EncodingType)? _getAacHeaderOffset(Uint8List bytes) {
  var offset = bytes.indexOfSequence(_AAC_HEADER_SEQUENCE_ADIF, 0, 8);

  if (offset != null) {
    return (offset, EncodingType.aacAdif);
  }

  offset ??= bytes.indexOfSequence(_AAC_HEADER_SEQUENCE_ADTS, 0, 8);

  if (offset != null) {
    return (offset, EncodingType.aacAdts);
  }

  return null;
}
