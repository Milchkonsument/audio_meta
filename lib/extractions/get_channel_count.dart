part of '../audio_meta.dart';

int _getChannelCount(Uint8List bytes, AudioType type) => switch (type) {
      AudioType.mp3 => _getMp3ChannelCount(bytes),
      AudioType.wav => _getWavChannelCount(bytes),
      AudioType.ogg => _getOggChannelCount(bytes),
      AudioType.flac => _getFlacChannelCount(bytes),
      AudioType.aac => _getAacChannelCount(bytes),
      _ => 0,
    };

_getAacChannelCount(Uint8List bytes) {}

_getFlacChannelCount(Uint8List bytes) {}

_getOggChannelCount(Uint8List bytes) {}

_getWavChannelCount(Uint8List bytes) {}

_getMp3ChannelCount(Uint8List bytes) {}
