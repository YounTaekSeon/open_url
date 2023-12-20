class RuntimeException implements Exception {
  const RuntimeException({this.message = ""});

  final String message;

  @override
  String toString() {
    return super.toString() +": $message";
  }
}