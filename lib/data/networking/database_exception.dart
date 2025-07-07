
class DatabaseException implements Exception {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  DatabaseException(this.message, {this.error, this.stackTrace});

  @override
  String toString() {
    return 'DatabaseException: $message';
  }
}
