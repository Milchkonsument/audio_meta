part of '../audio_meta.dart';

extension Uint8ListExtensions on Uint8List {
  int? indexOfSequence(List<int> sequence, [int start = 0, int? limit]) {
    for (int i = start;
        i <= min(length - sequence.length, limit ?? length);
        i++) {
      if (sublist(i, i + sequence.length).equals(sequence)) {
        return i;
      }
    }

    return null;
  }

  bool equals(List<int> other) {
    if (length != other.length) return false;
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }
}
