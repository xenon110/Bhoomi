class Fast2SmsResult {
  final bool success;
  final String message;

  const Fast2SmsResult(this.success, this.message);
}

Future<Fast2SmsResult> sendFast2Sms({
  required String apiKey,
  required String phoneNumber,
  required String otp,
}) async {
  return const Fast2SmsResult(false, 'Unsupported platform');
}
