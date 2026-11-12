import 'dart:async';
import 'dart:html' as html;

Future<String?> httpGet(String url, {Map<String, String>? headers}) async {
  try {
    final xhr = html.HttpRequest();
    xhr.open('GET', url, async: true);
    headers?.forEach((k, v) => xhr.setRequestHeader(k, v));
    final completer = Completer<String?>();
    xhr.onLoad.listen((_) {
      if (xhr.status != null && xhr.status! >= 200 && xhr.status! < 300) {
        completer.complete(xhr.responseText);
      } else {
        completer.complete(null);
      }
    });
    xhr.onError.listen((_) => completer.complete(null));
    xhr.timeout = 8000;
    xhr.send();
    return await completer.future;
  } catch (_) {
    return null;
  }
}

Future<String?> httpPost(String url, {Map<String, String>? headers, String? body}) async {
  try {
    final xhr = html.HttpRequest();
    xhr.open('POST', url, async: true);
    headers?.forEach((k, v) => xhr.setRequestHeader(k, v));
    final completer = Completer<String?>();
    xhr.onLoad.listen((_) {
      if (xhr.status != null && xhr.status! >= 200 && xhr.status! < 300) {
        completer.complete(xhr.responseText);
      } else {
        completer.complete(null);
      }
    });
    xhr.onError.listen((_) => completer.complete(null));
    xhr.timeout = 15000;
    xhr.send(body);
    return await completer.future;
  } catch (_) {
    return null;
  }
}

