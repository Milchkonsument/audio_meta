// ignore_for_file: constant_identifier_names

part of 'audio_meta.dart';

/// 'fmt '
const _WAV_HEADER_SEQUENCE = [0x66, 0x6d, 0x74, 0x20];

/// '`0x1`vorbis'
const _OGG_VORBIS_HEADER_SEQUENCE = [0x01, 0x76, 0x6f, 0x72, 0x62, 0x69, 0x73];

/// OpusHead
const _OGG_OPUS_HEADER_SEQUENCE = [
  0x4F,
  0x70,
  0x75,
  0x73,
  0x48,
  0x65,
  0x61,
  0x64,
];

/// 'fLaC`0x00000022`'
const _OGG_FLAC_HEADER_SEQUENCE = [
  0x66,
  0x4C,
  0x61,
  0x43,
  0x00,
  0x00,
  0x00,
  0x22,
];

/// 'fLaC'
const _FLAC_HEADER_SEQUENCE = [0x66, 0x4c, 0x61, 0x43];

/// 'ADIF'
const _AAC_ADIF_HEADER_SEQUENCE = [0x41, 0x44, 0x49, 0x46];

/// 0b11111111
const _AAC_ADTS_HEADER_SEQUENCE = [0xFF];

/// 0b11111111111
const _MP3_MPEG_HEADER_SEQUENCE = [0xFF];

/// 'Xing'
const _MP3_XING_HEADER_SEQUENCE = [0x58, 0x69, 0x6E, 0x67];

const _WAV_FORMAT_CODES = {
  0x0001: EncodingType.wavPcm,
  0x0003: EncodingType.wavIeee,
  0x0006: EncodingType.wavAlaw,
  0x0007: EncodingType.wavMulaw,
  0x0011: EncodingType.wavAdpcm,
  0x0017: EncodingType.wavGsm,
  0x001A: EncodingType.wavAdpcm,
  0x0062: EncodingType.wavG722,
  0x0069: EncodingType.wavG729,
};

/// 00 - MPEG Version 2.5 (later extension of MPEG 2)
/// 01 - reserved
/// 10 - MPEG Version 2 (ISO/IEC 13818-3)
/// 11 - MPEG Version 1 (ISO/IEC 11172-3)
const _MP3_SAMPLE_RATES_BY_VERSION_AND_SAMPLE_RATE_INDEX = {
  // MPEG-1
  3: [
    44100,
    48000,
    32000,
    0,
  ],
  // MPEG-2
  2: [
    22050,
    24000,
    16000,
    0,
  ],
  // MPEG-2.5
  0: [
    11025,
    12000,
    8000,
    0,
  ],
  1: [
    0,
    0,
    0,
    0,
  ],
};

const Map<int, Map<int, Map<int, int>>>
    _MP3_BITRATE_BY_BIT_INDEX_AND_VERSION_AND_LAYER = {
  0x0: {
    0: {3: 0, 2: 0, 1: 0},
    2: {3: 0, 2: 0, 1: 0},
    3: {3: 0, 2: 0, 1: 0}
  },
  0x1: {
    0: {3: 32, 2: 32, 1: 32},
    2: {3: 32, 2: 8, 1: 8},
    3: {3: 32, 2: 32, 1: 32}
  },
  0x2: {
    0: {3: 64, 2: 48, 1: 40},
    2: {3: 48, 2: 16, 1: 16},
    3: {3: 64, 2: 48, 1: 40}
  },
  0x3: {
    0: {3: 96, 2: 56, 1: 48},
    2: {3: 56, 2: 24, 1: 24},
    3: {3: 96, 2: 56, 1: 48}
  },
  0x4: {
    0: {3: 128, 2: 64, 1: 56},
    2: {3: 64, 2: 32, 1: 32},
    3: {3: 128, 2: 64, 1: 56}
  },
  0x5: {
    0: {3: 160, 2: 80, 1: 64},
    2: {3: 80, 2: 40, 1: 40},
    3: {3: 160, 2: 80, 1: 64}
  },
  0x6: {
    0: {3: 192, 2: 96, 1: 80},
    2: {3: 96, 2: 48, 1: 48},
    3: {3: 192, 2: 96, 1: 80}
  },
  0x7: {
    0: {3: 224, 2: 112, 1: 96},
    2: {3: 112, 2: 56, 1: 56},
    3: {3: 224, 2: 112, 1: 96}
  },
  0x8: {
    0: {3: 256, 2: 128, 1: 112},
    2: {3: 128, 2: 64, 1: 64},
    3: {3: 256, 2: 128, 1: 112}
  },
  0x9: {
    0: {3: 288, 2: 160, 1: 128},
    2: {3: 144, 2: 80, 1: 80},
    3: {3: 288, 2: 160, 1: 128}
  },
  0xA: {
    0: {3: 320, 2: 192, 1: 160},
    2: {3: 160, 2: 96, 1: 96},
    3: {3: 320, 2: 192, 1: 160}
  },
  0xB: {
    0: {3: 352, 2: 224, 1: 192},
    2: {3: 176, 2: 112, 1: 112},
    3: {3: 352, 2: 224, 1: 192}
  },
  0xC: {
    0: {3: 384, 2: 256, 1: 224},
    2: {3: 192, 2: 128, 1: 128},
    3: {3: 384, 2: 256, 1: 224}
  },
  0xD: {
    0: {3: 416, 2: 320, 1: 256},
    2: {3: 224, 2: 144, 1: 144},
    3: {3: 416, 2: 320, 1: 256}
  },
  0xE: {
    0: {3: 448, 2: 384, 1: 320},
    2: {3: 256, 2: 160, 1: 160},
    3: {3: 448, 2: 384, 1: 320}
  },
  0xF: {
    0: {3: 0, 2: 0, 1: 0},
    2: {3: 0, 2: 0, 1: 0},
    3: {3: 0, 2: 0, 1: 0}
  },
};

/// ADTS sample rates
///
/// Returns the sample rate for each sample rate index in the ADTS header.
///
/// Returns -1 if the sample rate is written explicitly in the ADTS header.
const _AAC_SAMPLE_RATES_BY_SAMPLE_RATE_INDEX = [
  96000,
  88200,
  64000,
  48000,
  44100,
  32000,
  24000,
  22050,
  16000,
  12000,
  11025,
  8000,
  7350,
  0,
  0,
  // frequency is written explicitly in the ADTS header
  -1,
];

const _MP3_SAMPLES_PER_FRAME_COEFFICIENT_BY_LAYER_AND_VERSION_INDEX = {
  3: {
    // Layer I
    3: 48, // MPEG-1: 384 / 8
    2: 48, // MPEG-2: 384 / 8
    0: 48, // MPEG-2.5: 384 / 8
  },
  2: {
    // Layer II
    3: 144, // MPEG-1: 1152 / 8
    2: 144, // MPEG-2: 1152 / 8
    0: 144, // MPEG-2.5: 1152 / 8
  },
  1: {
    // Layer III
    3: 144, // MPEG-1: 1152 / 8
    2: 72, // MPEG-2: 576 / 8
    0: 72, // MPEG-2.5: 576 / 8
  },
};

const _MP3_SAMPLES_PER_FRAME_BY_LAYER_AND_VERSION_INDEX = {
  3: {
    // Layer I
    3: 384, // MPEG-1
    2: 384, // MPEG-2
    0: 384, // MPEG-2.5
  },
  2: {
    // Layer II
    3: 1152, // MPEG-1
    2: 1152, // MPEG-2
    0: 1152, // MPEG-2.5
  },
  1: {
    // Layer III
    3: 1152, // MPEG-1
    2: 576, // MPEG-2
    0: 576, // MPEG-2.5
  },
};