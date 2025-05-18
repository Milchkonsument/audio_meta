part of '../audio_meta.dart';

extension _Uint8ListExtensions on Uint8List {
  int? _indexOfSequence(Iterable<int> sequence,
      [int start = 0, int limit = 256]) {
    final end = min(length - sequence.length, start + limit);
    for (int i = start; i <= end; i++) {
      if (sublist(i, i + sequence.length)._equals(sequence)) {
        return i;
      }
    }

    return null;
  }

  int? _indexOfSequenceFromEnd(Iterable<int> sequence) {
    for (int i = length - sequence.length - 1; i >= 0; i--) {
      if (sublist(i, i + sequence.length)._equals(sequence)) {
        return i;
      }
    }

    return null;
  }

  bool _equals(Iterable<int> other) {
    if (length != other.length) return false;

    final iter = other.iterator;

    for (int i = 0; i < length; i++) {
      if (!iter.moveNext()) return false;
      if (this[i] != iter.current) return false;
    }

    return true;
  }
}
