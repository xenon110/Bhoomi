class TursoHttpResponse {
  final int statusCode;
  final String body;
  final String? error;

  const TursoHttpResponse({
    required this.statusCode,
    required this.body,
    this.error,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

