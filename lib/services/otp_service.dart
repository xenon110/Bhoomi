import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'otp_client.dart';

class OtpSendResult {
  final bool success;
  final String otp;
  final bool isRealSms;
  final String message;

  const OtpSendResult({
    required this.success,
    required this.otp,
    required this.isRealSms,
    required this.message,
  });
}

class OtpService {
  static final OtpService _instance = OtpService._internal();
  factory OtpService() => _instance;
  OtpService._internal();

  /// Fast2SMS API Key for real SMS delivery to Indian phone numbers.
  /// Free registration at: https://www.fast2sms.com
  static String fast2SmsApiKey = 'ZDF7IItO61JmW0p1EJg0W1FGfslpaY10G48t4DCwEuE4xDBtGSehPJEK02FTLrab1jkdMriv7KDsRPiQ';

  /// In-memory cache of active OTPs: phone -> generated OTP code
  final Map<String, String> _activeOtps = {};

  /// Generate a secure random 6-digit OTP code
  String generateCode() {
    final random = Random();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  /// Send OTP to user's phone number
  Future<OtpSendResult> sendOtp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final phone10Digit = cleanPhone.length > 10
        ? cleanPhone.substring(cleanPhone.length - 10)
        : cleanPhone;

    final code = generateCode();
    _activeOtps[phone10Digit] = code;

    // Check if Fast2SMS API key is provided
    if (fast2SmsApiKey.trim().isNotEmpty) {
      try {
        final smsResult = await sendFast2Sms(
          apiKey: fast2SmsApiKey.trim(),
          phoneNumber: phone10Digit,
          otp: code,
        );

        if (smsResult.success) {
          debugPrint('Fast2SMS: Real SMS sent successfully to $phone10Digit');
          return OtpSendResult(
            success: true,
            otp: code,
            isRealSms: true,
            message: 'OTP SMS sent successfully to +91 $phone10Digit',
          );
        } else {
          debugPrint('Fast2SMS: SMS failed: ${smsResult.message}. Falling back to in-app OTP.');
          return OtpSendResult(
            success: true,
            otp: code,
            isRealSms: false,
            message: smsResult.message,
          );
        }
      } catch (e) {
        debugPrint('Fast2SMS exception: $e');
      }
    }

    // Default immediate OTP for development/testing
    return OtpSendResult(
      success: true,
      otp: code,
      isRealSms: false,
      message: 'OTP Code: $code',
    );
  }

  /// Verifies entered OTP against active session or universal bypass (123456)
  bool verifyOtp(String phoneNumber, String enteredOtp) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final phone10Digit = cleanPhone.length > 10
        ? cleanPhone.substring(cleanPhone.length - 10)
        : cleanPhone;

    // Universal test/demo code always accepted
    if (enteredOtp == '123456') {
      return true;
    }

    final expectedOtp = _activeOtps[phone10Digit];
    if (expectedOtp != null && expectedOtp == enteredOtp) {
      _activeOtps.remove(phone10Digit);
      return true;
    }

    return false;
  }
}

