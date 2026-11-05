import 'dart:io';

Future<String?> readData(String key) async {
  try {
    final file = File(key);
    if (await file.exists()) {
      return await file.readAsString();
    }
  } catch (_) {}
  return null;
}

Future<void> writeData(String key, String value) async {
  try {
    final file = File(key);
    await file.writeAsString(value);
  } catch (_) {}
}

