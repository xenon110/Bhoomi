import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'otp_client_stub.dart';

Future<Fast2SmsResult> sendFast2Sms({
  required String apiKey,
  required String phoneNumber,
  required String otp,
}) async {
  final completer = Completer<Fast2SmsResult>();
  try {
    final xhr = html.HttpRequest();
    xhr.open('POST', 'https://www.fast2sms.com/dev/bulkV2', async: true);
    xhr.setRequestHeader('authorization', apiKey.trim());
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.setRequestHeader('accept', 'application/json');
    xhr.onLoad.listen((_) {
      try {
        final data = jsonDecode(xhr.responseText ?? '{}');
        if (data['return'] == true) {
          completer.complete(const Fast2SmsResult(true, 'SMS sent successfully'));
        } else {
          final msg = data['message'] is List
              ? (data['message'] as List).join(', ')
              : data['message']?.toString() ?? 'Failed';
          completer.complete(Fast2SmsResult(false, msg));
        }
      } catch (e) {
        completer.complete(Fast2SmsResult(false, e.toString()));
      }
    });
    xhr.onError.listen((_) => completer.complete(const Fast2SmsResult(false, 'Network error')));
    xhr.onTimeout.listen((_) => completer.complete(const Fast2SmsResult(false, 'Timeout')));
    xhr.timeout = 10000;
    xhr.send(jsonEncode({
      'route': 'otp',
      'variables_values': otp,
      'numbers': phoneNumber,
    }));
  } catch (e) {
    completer.complete(Fast2SmsResult(false, e.toString()));
  }
  return completer.future;
}
