import 'dart:async';
import 'dart:html' as html;
import 'turso_response.dart';

Future<TursoHttpResponse> sendTursoPost({
  required String url,
  required String token,
  required String jsonPayload,
}) async {
  final completer = Completer<TursoHttpResponse>();
  try {
    final xhr = html.HttpRequest();
    xhr.open('POST', url, async: true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    if (token.trim().isNotEmpty) {
      xhr.setRequestHeader('Authorization', 'Bearer ${token.trim()}');
    }

    xhr.onLoad.listen((_) {
      completer.complete(TursoHttpResponse(
        statusCode: xhr.status ?? 0,
        body: xhr.responseText ?? '',
      ));
    });

    xhr.onError.listen((e) {
      completer.complete(TursoHttpResponse(
        statusCode: xhr.status ?? 500,
        body: xhr.responseText ?? '',
        error: 'Network connection failed or host unreachable',
      ));
    });

    xhr.onTimeout.listen((_) {
      completer.complete(const TursoHttpResponse(
        statusCode: 408,
        body: '',
        error: 'Connection timed out',
      ));
    });

    xhr.timeout = 8000;
    xhr.send(jsonPayload);
  } catch (e) {
    completer.complete(TursoHttpResponse(
      statusCode: 500,
      body: '',
      error: e.toString(),
    ));
  }
  return completer.future;
}

