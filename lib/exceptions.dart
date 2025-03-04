/// Exception thrown when an error occurs during the
/// extraction of audio metadata.
class ExtractionException implements Exception {
  /// Exception thrown when an error occurs during the
  /// extraction of audio metadata.
  ExtractionException(this.message);

  final String message;

  @override
  String toString() => 'ExtractionException: $message';
}
