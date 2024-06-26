import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:test_app/commons/widgets/custom_button.dart';
import 'package:test_app/commons/widgets/custom_progress_indicator.dart';
import 'package:test_app/constants/colors.dart';
import 'package:velocity_x/velocity_x.dart';
import '../controllers/auth_controller.dart';

// ignore: must_be_immutable
class OTPPage extends StatelessWidget {
  OTPPage({super.key});

  AuthController authController = Get.find(tag: 'auth-controller');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              20.heightBox,
              Image.asset('assets/images/sauda2sale_png.png'),
              25.heightBox,
              "Sauda2Sale".text.size(35).semiBold.make(),
              25.heightBox,
              "Enter the OTP sent to ${authController.countryCode} ${authController.phoneNumberController.text}"
                  .text
                  .align(TextAlign.center)
                  .size(12)
                  .fontWeight(FontWeight.w500)
                  .make(),
              20.heightBox,
              OtpTextField(
                enabledBorderColor: blackColor,
                keyboardType: TextInputType.number,
                numberOfFields: authController.verificationCodeLength,
                borderColor: const Color(0xFF512DA8),
                onCodeChanged: (String code) {},
                onSubmit: (String verificationCode) {
                  authController.verificationCodeEntered.value =
                      verificationCode;
                }, // end onSubmit
              ),
              20.heightBox,
              Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 10,
                spacing: 10,
                children: [
                  "Didn't you receive the OTP? ".text.size(12).make(),
                  "Resend OTP"
                      .text
                      .size(13)
                      .fontWeight(FontWeight.bold)
                      .color(darkPinkColor)
                      .make()
                      .onTap(() async {
                    await authController.resendOTP();
                  }),
                ],
              ),
              20.heightBox,
              authController.isLoading.value
                  ? customProgressIndicator()
                  : CustomButton(
                      text: "Verify",
                      mainAxisAlignment: MainAxisAlignment.center,
                      onTap: () async {
                        await authController.twilioVerifyOTP();
                      },
                      color: pinkColor,
                    ),
              15.heightBox,
              Column(
                children: [
                  "By logging in, you accept to the".text.size(13).make(),
                  "Terms & Conditions and Privacy Policy"
                      .text
                      .bold
                      .color(darkPinkColor)
                      .size(13)
                      .make()
                      .onTap(() {
                    authController.showTermsAndConditions(context);
                  }),
                ],
              ),
              30.heightBox
            ],
          ),
        ),
      ),
    );
  }
}
