import 'dart:convert';
import 'dart:io';

Future<String?> httpGet(String url, {Map<String, String>? headers}) async {
  HttpClient? client;
  try {
    client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    final request = await client.getUrl(Uri.parse(url));
    headers?.forEach((k, v) => request.headers.set(k, v));
    final response = await request.close().timeout(const Duration(seconds: 8));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await response.transform(utf8.decoder).join();
    }
  } catch (_) {
  } finally {
    client?.close();
  }
  return null;
}

Future<String?> httpPost(String url, {Map<String, String>? headers, String? body}) async {
  HttpClient? client;
  try {
    client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    final request = await client.postUrl(Uri.parse(url));
    headers?.forEach((k, v) => request.headers.set(k, v));
    if (body != null) {
      request.write(body);
    }
    final response = await request.close().timeout(const Duration(seconds: 15));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return await response.transform(utf8.decoder).join();
    }
  } catch (_) {
  } finally {
    client?.close();
  }
  return null;
}

