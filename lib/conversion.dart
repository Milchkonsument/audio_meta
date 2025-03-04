part of '../audio_meta.dart';

/// bytes to int, big-endian
int _bytesToIntBE(Uint8List bytes) {
  if (bytes.length > 8) {
    return 0;
  }

  var value = 0;

  for (var i = 0; i < bytes.length; i++) {
    final shift = (bytes.length - 1 - i) * 8;
    value |= bytes[i] << shift;
  }

  return value;
}

/// bytes to int, little-endian
int _bytesToIntLE(Uint8List bytes) {
  if (bytes.length > 8) {
    return 0;
  }

  var value = 0;

  for (var i = 0; i < bytes.length; i++) {
    value |= bytes[i] << (i * 8);
  }

  return value;
}

/// bytes to int from int list, big-endian
int _bytesToIntILBE(List<int> bytes) =>
    _bytesToIntBE(Uint8List.fromList(bytes));
