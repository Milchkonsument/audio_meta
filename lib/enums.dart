part of '../audio_meta.dart';

enum AudioType {
  mp3,
  wav,
  ogg,
  flac,
  aac,
  unknown,
}

enum EncodingType {
  aacAdts,
  aacAdif,
  mp3Vbr,
  mp3Cbr,
  wavPcm,
  wavAdpcm,
  wavIeee,
  wavAlaw,
  wavMulaw,
  wavGsm,
  wavG722,
  wavG729,
  flac,
  oggVorbis,
  oggOpus,
  oggFlac,
  oggSpeex,
  unknown;

  @override
  toString() => switch (this) {
        EncodingType.aacAdts => 'AAC ADTS',
        EncodingType.aacAdif => 'AAC ADIF',
        EncodingType.mp3Vbr => 'MP3 VBR',
        EncodingType.mp3Cbr => 'MP3 CBR',
        EncodingType.wavPcm => 'WAV PCM',
        EncodingType.wavAdpcm => 'WAV ADPCM',
        EncodingType.wavIeee => 'WAV IEEE',
        EncodingType.flac => 'FLAC',
        EncodingType.oggVorbis => 'OGG Vorbis',
        EncodingType.oggOpus => 'OGG Opus',
        EncodingType.oggFlac => 'OGG FLAC',
        EncodingType.oggSpeex => 'OGG Speex',
        EncodingType.unknown => 'Unknown',
        EncodingType.wavAlaw => 'WAV ALaw',
        EncodingType.wavMulaw => 'WAV MuLaw',
        EncodingType.wavGsm => 'WAV GSM',
        EncodingType.wavG722 => 'WAV G722',
        EncodingType.wavG729 => 'WAV G729',
      };
}
