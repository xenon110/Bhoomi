import 'turso_response.dart';

Future<TursoHttpResponse> sendTursoPost({
  required String url,
  required String token,
  required String jsonPayload,
}) async {
  throw UnsupportedError('Cannot send Turso request without platform HTTP implementation.');
}

