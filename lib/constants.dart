part of 'audio_meta.dart';

/// Explanation of the Values:
/// Index 00:
/// MPEG-1: 44.1 kHz (standard for most MP3s)
/// MPEG-2: 22.05 kHz
/// MPEG-2.5: 11.025 kHz
/// Index 01:
/// MPEG-1: 48 kHz
/// MPEG-2: 24 kHz
/// MPEG-2.5: 12 kHz
/// Index 10:
/// MPEG-1: 32 kHz
/// MPEG-2: 16 kHz
/// MPEG-2.5: 8 kHz
/// Index 11: Reserved (not used)
const _mp3SampleRatesByVersionBits = {
  // MPEG-1
  0: [
    44100,
    48000,
    32000,
    0,
  ],
  // MPEG-2
  1: [
    22050,
    24000,
    16000,
    0,
  ],
  // MPEG-2.5
  2: [
    11025,
    12000,
    8000,
    0,
  ],
  3: [
    0,
    0,
    0,
    0,
  ],
};

const _aacSampleRates = [
  96000,
  88200,
  64000,
  48000,
  44100,
  32000,
];

const _mp3Bitrates = [
  0,
  32,
  40,
  48,
  56,
  64,
  80,
  96,
  112,
  128,
  160,
  192,
  224,
  256,
  320,
  0,
];
