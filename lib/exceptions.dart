/// Exception thrown when an error occurs during the
/// extraction of audio information.
class ExtractionException implements Exception {
  /// Exception thrown when an error occurs during the
  /// extraction of audio information.
  ExtractionException(this.message);

  final String message;

  @override
  String toString() => 'ExtractionException: $message';
}
