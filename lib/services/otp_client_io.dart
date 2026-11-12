import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'otp_client_stub.dart';

Future<Fast2SmsResult> sendFast2Sms({
  required String apiKey,
  required String phoneNumber,
  required String otp,
}) async {
  HttpClient? client;
  try {
    client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    final uri = Uri.parse('https://www.fast2sms.com/dev/bulkV2');

    // 1. Try official OTP route first
    final request = await client.postUrl(uri);
    request.headers.set('authorization', apiKey.trim());
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set('accept', 'application/json');

    final payload = jsonEncode({
      'route': 'otp',
      'variables_values': otp,
      'numbers': phoneNumber,
    });
    request.write(payload);
    final response = await request.close().timeout(const Duration(seconds: 10));
    final body = await response.transform(utf8.decoder).join();
    debugPrint('Fast2SMS OTP Route response (${response.statusCode}): $body');

    try {
      final data = jsonDecode(body);
      if (data['return'] == true) {
        return const Fast2SmsResult(true, 'SMS sent successfully');
      }
    } catch (_) {}

    // 2. Try Quick SMS route with required language field
    final client2 = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    final request2 = await client2.postUrl(uri);
    request2.headers.set('authorization', apiKey.trim());
    request2.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request2.headers.set('accept', 'application/json');

    final payload2 = jsonEncode({
      'route': 'q',
      'message': 'Your Bhoomi verification code is $otp',
      'language': 'english',
      'flash': 0,
      'numbers': phoneNumber,
    });
    request2.write(payload2);
    final response2 = await request2.close().timeout(const Duration(seconds: 10));
    final body2 = await response2.transform(utf8.decoder).join();
    debugPrint('Fast2SMS Quick Route response (${response2.statusCode}): $body2');

    final data2 = jsonDecode(body2);
    if (data2['return'] == true) {
      return const Fast2SmsResult(true, 'SMS sent successfully via Quick Route');
    }

    final msg = data2['message'] is List
        ? (data2['message'] as List).join(', ')
        : data2['message']?.toString() ?? 'Failed to send SMS';
    return Fast2SmsResult(false, msg);
  } catch (e) {
    debugPrint('Fast2SMS request error: $e');
    return Fast2SmsResult(false, e.toString());
  } finally {
    client?.close();
  }
}
