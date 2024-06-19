import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class TwilioService {
  final String accountSid = 'AC307c86aed594eb6535d430e9d9d1c7ff';
  final String authToken = '40825316289ec444dbc61b8ae9ed078d';
  final String serviceSid = 'VAfb7de0e934218256f8f60af738ec6364';

  String basicAuth() {
    return 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}';
  }

  Future<bool> sendOtp(String phoneNumber) async {
    final url =
        'https://verify.twilio.com/v2/Services/$serviceSid/Verifications';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': basicAuth(),
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {'To': phoneNumber, 'Channel': 'sms'},
    );

    developer.log('Send OTP response status: ${response.statusCode}');
    developer.log('Send OTP response body: ${response.body}');

    return response.statusCode == 201;
  }

  Future<bool> verifyOtp(String phoneNumber, String code) async {
    final url =
        'https://verify.twilio.com/v2/Services/$serviceSid/VerificationCheck';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': basicAuth(),
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {'To': phoneNumber, 'Code': code},
    );

    developer.log('Verify OTP response status: ${response.statusCode}');
    developer.log('Verify OTP response body: ${response.body}');

    final responseData = jsonDecode(response.body);
    return responseData['status'] == 'approved';
  }
}
