class NotAdminException implements Exception {
  final String message;
  NotAdminException(this.message);

  @override
  String toString() => message;
}
