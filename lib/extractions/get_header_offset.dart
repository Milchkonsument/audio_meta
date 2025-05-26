part of '../audio_meta.dart';

(int, AudioType, EncodingType)? _getHeaderOffsetTypeAndEncoding(
    Uint8List bytes) {
  return _getFlacHeaderOffset(bytes) ??
      _getWavHeaderOffset(bytes) ??
      _getMp3HeaderOffset(bytes) ??
      _getOggHeaderOffset(bytes) ??
      _getAacHeaderOffset(bytes);
}

(int, AudioType, EncodingType)? _getMp3HeaderOffset(Uint8List bytes) {
  final mpegOffset = bytes._indexOfSequence(
      _MP3_MPEG_HEADER_SEQUENCE, 0, 16384); // higher limit cuz of ID3 tags
  final xingOffset = bytes._indexOfSequence(_MP3_XING_HEADER_SEQUENCE);

  if (mpegOffset == null) {
    return null;
  }

  if (xingOffset != null) {
    return (
      mpegOffset,
      AudioType.mp3,
      EncodingType.mp3Vbr,
    );
  }

  // distinguish MPEG-MP3 header from MPEG-AAC header
  final b1 = bytes[mpegOffset + 1];
  final layerIndex = (b1 >> 1) & 0x03;
  final bitrateIndex = (bytes[mpegOffset + 2] >> 4) & 0x0F;
  final sampleRateIndex = (bytes[mpegOffset + 2] >> 2) & 0x03;

  if (layerIndex == 0 || bitrateIndex == 0x0F || sampleRateIndex == 0x03) {
    return null;
  }

  return (
    mpegOffset,
    AudioType.mp3,
    EncodingType.mp3Cbr,
  );
}

(int, AudioType, EncodingType)? _getWavHeaderOffset(Uint8List bytes) {
  final offset = bytes._indexOfSequence(_WAV_HEADER_SEQUENCE, 12);
  var encoding = EncodingType.unknown;

  if (offset == null) {
    return null;
  }

  final formatCode = _bytesToIntLE(bytes.sublist(offset + 8, offset + 10));
  encoding = _WAV_FORMAT_CODES[formatCode] ?? EncodingType.unknown;

  return (offset, AudioType.wav, encoding);
}

(int, AudioType, EncodingType)? _getOggHeaderOffset(Uint8List bytes) {
  var offset = bytes._indexOfSequence(_OGG_VORBIS_HEADER_SEQUENCE);

  if (offset != null) {
    return (offset, AudioType.ogg, EncodingType.oggVorbis);
  }

  offset ??= bytes._indexOfSequence(_OGG_OPUS_HEADER_SEQUENCE);

  if (offset != null) {
    return (offset, AudioType.ogg, EncodingType.oggOpus);
  }

  offset ??= bytes._indexOfSequence(_OGG_FLAC_HEADER_SEQUENCE);

  if (offset != null) {
    return (offset, AudioType.ogg, EncodingType.oggFlac);
  }

  return null;
}

(int, AudioType, EncodingType)? _getFlacHeaderOffset(Uint8List bytes) {
  final offset = bytes._indexOfSequence(_FLAC_HEADER_SEQUENCE);

  if (offset == null) {
    return null;
  }

  return (offset, AudioType.flac, EncodingType.flac);
}

(int, AudioType, EncodingType)? _getAacHeaderOffset(Uint8List bytes) {
  var offset = bytes._indexOfSequence(_AAC_ADIF_HEADER_SEQUENCE);

  if (offset != null) {
    return (offset, AudioType.aac, EncodingType.aacAdif);
  }

  offset ??= bytes._indexOfSequence(_AAC_ADTS_HEADER_SEQUENCE);

  if (offset != null) {
    return (offset, AudioType.aac, EncodingType.aacAdts);
  }

  return null;
}
