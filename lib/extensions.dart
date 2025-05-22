part of '../audio_meta.dart';

extension _Uint8ListExtensions on Uint8List {
  int? _indexOfSequence(List<int> sequence, [int start = 0, int limit = 2048]) {
    final end = min(length - sequence.length, start + limit);

    for (int i = start; i <= end; i++) {
      if (sublist(i, i + sequence.length)._equals(sequence)) {
        return i;
      }
    }

    return null;
  }

  int? _indexOfSequenceFromEnd(List<int> sequence) {
    for (int i = length - sequence.length - 1; i >= 0; i--) {
      if (sublist(i, i + sequence.length)._equals(sequence)) {
        return i;
      }
    }

    return null;
  }

  bool _equals(List<int> other) {
    if (length != other.length) return false;

    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }

    return true;
  }
}
