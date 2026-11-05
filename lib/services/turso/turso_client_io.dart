import 'dart:convert';
import 'dart:io';
import 'turso_response.dart';

Future<TursoHttpResponse> sendTursoPost({
  required String url,
  required String token,
  required String jsonPayload,
}) async {
  HttpClient? client;
  try {
    client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    final uri = Uri.parse(url);
    final request = await client.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if (token.trim().isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${token.trim()}');
    }
    request.write(jsonPayload);
    final response = await request.close().timeout(const Duration(seconds: 8));
    final body = await response.transform(utf8.decoder).join();
    return TursoHttpResponse(
      statusCode: response.statusCode,
      body: body,
    );
  } catch (e) {
    return TursoHttpResponse(
      statusCode: 500,
      body: '',
      error: e.toString(),
    );
  } finally {
    client?.close();
  }
}

