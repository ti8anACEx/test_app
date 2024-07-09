import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/commons/widgets/custom_snackbar.dart';

class TwilioService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late final String accountSid;
  late final String authToken;
  late final String serviceSid;

  String basicAuth() {
    return 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}';
  }

  Future<bool> sendOtp(String phoneNumber) async {
    var doc =
        await firestore.collection('confidential').doc('twilioCreds').get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      accountSid = data['accountSid'];
      authToken = data['authToken'];
      serviceSid = data['serviceSid'];

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
    } else {
      CustomSnackbar.show('Error', 'Failed operation. Please try again.');
      return false;
    }
  }

  Future<String> verifyOtp(String phoneNumber, String code) async {
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

    return responseData['status'];
  }
}
