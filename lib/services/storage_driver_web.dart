import 'dart:html' as html;

Future<String?> readData(String key) async {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}

Future<void> writeData(String key, String value) async {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {}
}

