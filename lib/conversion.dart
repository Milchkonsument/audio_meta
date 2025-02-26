part of '../audio_meta.dart';

/// bytes to int, big-endian
int _bytesToIntBE(Uint8List bytes) {
  if (bytes.length < 4) {
    return 0;
  }

  return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
}

/// bytes to int, little-endian
int _bytesToIntLE(Uint8List bytes) {
  if (bytes.length < 4) {
    return 0;
  }

  return (bytes[3] << 24) | (bytes[2] << 16) | (bytes[1] << 8) | bytes[0];
}

/// bytes to int from int list, big-endian
int _bytesToIntILBE(List<int> bytes) {
  if (bytes.length < 4) {
    return 0;
  }

  return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
}
