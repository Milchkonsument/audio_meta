part of '../audio_meta.dart';

int _getBitDepth(Uint8List bytes, AudioType type) => switch (type) {
      AudioType.mp3 => _getMp3BitDepth(bytes),
      AudioType.wav => _getWavBitDepth(bytes),
      AudioType.ogg => _getOggBitDepth(bytes),
      AudioType.flac => _getFlacBitDepth(bytes),
      AudioType.aac => _getAacBitDepth(bytes),
      _ => 0,
    };

_getAacBitDepth(Uint8List bytes) {}

_getFlacBitDepth(Uint8List bytes) {}

_getOggBitDepth(Uint8List bytes) {}

_getWavBitDepth(Uint8List bytes) {}

_getMp3BitDepth(Uint8List bytes) {}
