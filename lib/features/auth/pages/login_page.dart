import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/commons/widgets/custom_button.dart';
import 'package:test_app/commons/widgets/custom_progress_indicator.dart';
import 'package:test_app/commons/widgets/custom_text_field.dart';
import 'package:test_app/constants/colors.dart';
import 'package:velocity_x/velocity_x.dart';
import '../controllers/auth_controller.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

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
              Image.asset('assets/images/sauda2sale_png.png').onLongPress(() {
                authController.toggleToTestCountryCode();
              }, key),
              50.heightBox,
              "Sauda Book".text.size(35).semiBold.make().onLongPress(() {
                authController.toggleWantEmailLogin();
              }, key),
              50.heightBox,
              customTextField(
                  labelText: 'Name',
                  controller: authController.usernameController),
              20.heightBox,
              customTextField(
                  prefixText: '+91',
                  labelText: 'Phone Number',
                  textInputType: TextInputType.phone,
                  controller: authController.phoneNumberController),
              20.heightBox,
              customTextField(
                  labelText: 'Email',
                  textInputType: TextInputType.emailAddress,
                  controller: authController.emailController),
              20.heightBox,
              customTextField(
                  labelText: 'Password',
                  isObscured: true,
                  controller: authController.passwordController),
              100.heightBox,
              Obx(
                () => authController.isLoading.value
                    ? Container()
                    : CustomButton(
                        text: "Get OTP",
                        trailingWidget: const Icon(
                          Icons.arrow_forward_ios,
                          color: whiteColor,
                        ),
                        onTap: () async {
                          await authController.getOTP();
                        },
                        color: pinkColor,
                      ),
              ),
              50.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}
