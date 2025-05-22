import 'dart:io';

import 'package:audio_meta/audio_meta.dart';

extension AudioMetaCompatWeb on AudioMeta {
  static AudioMeta fromPathImpl(String path) {
    throw UnsupportedError('AudioMeta.fromPath() is not supported on web.'
        'Please use AudioMeta.fromBytes instead.');
  }

  static AudioMeta fromFileImpl(File file) {
    throw UnsupportedError('AudioMeta.fromFile() is not supported on web.'
        'Please use AudioMeta.fromBytes instead.');
  }

  static Future<AudioMeta> fromFileAsyncImpl(File file) {
    throw UnsupportedError('AudioMeta.fromFileAsync() is not supported on web.'
        'Please use AudioMeta.fromBytes instead.');
  }

  static Future<AudioMeta> fromPathAsyncImpl(String path) {
    throw UnsupportedError('AudioMeta.fromPathAsync() is not supported on web.'
        'Please use AudioMeta.fromBytes instead.');
  }
}
