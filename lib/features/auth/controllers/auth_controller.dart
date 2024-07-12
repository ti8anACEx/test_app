import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:test_app/confidential/twilio_service.dart';
import 'package:test_app/constants/colors.dart';
import 'package:test_app/features/auth/pages/login_page.dart';
import 'package:test_app/features/auth/pages/otp_page.dart';
import 'package:test_app/features/auth/pages/splash_page.dart';
import 'package:test_app/features/home/pages/home_page.dart';
import 'package:test_app/models/vendor_model.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../commons/widgets/custom_snackbar.dart';
import '../../../constants/strings.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  RxBool isLoading = false.obs;
  RxBool isSplashing = true.obs;
  RxBool wantEmailLogin = false.obs;

  late Rx<User?> _userPersist;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TwilioService twilioService = TwilioService();
  late TwilioFlutter twilioFlutter;

  UserCredential? credential;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxString verificationCodeEntered = ''.obs;
  int verificationCodeLength = 6;
  RxString countryCode = '+91'.obs;

  RxString currentUserUID = ''.obs;
  RxString currentPhoneNumber = ''.obs;
  RxString currentUsername = ''.obs;
  RxString currentEmail = ''.obs;
  RxString currentProfilePic = ''.obs;
  RxString currentStoreName = ''.obs;
  RxString currentvendorAppBundleId = ''.obs;
  RxString currentGstin = ''.obs;
  RxString currentOfficeAddress = ''.obs;
  RxBool currentIsSubscribed = false.obs;

  void toggleWantEmailLogin() {
    wantEmailLogin.toggle();
    CustomSnackbar.show(
        "User wants Email Login", wantEmailLogin.value ? "Yes" : "No");
  }

  void toggleToTestCountryCode() {
    // for testing purposes to avoid going out of quota
    if (countryCode.value == "+91") {
      countryCode.value = "+1";
    } else {
      countryCode.value = "+91";
    }
    CustomSnackbar.show("CountryCodeChanged", countryCode.value);
  }

  Future<void> getOTP() async {
    try {
      isLoading.value = true;

      if (emailController.text.isNotEmpty &&
          phoneNumberController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          usernameController.text.isNotEmpty) {
        if (wantEmailLogin.value) {
          await checkIfUserExistsAndSign(false, null);
        } else {
          twilioSendTheOTP();
        }
      } else {
        return;
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackbar.show("error", e.toString());
    }
  }

  Future<void> twilioSendTheOTP() async {
    try {
      final success =
          await twilioService.sendOtp(countryCode + phoneNumberController.text);

      developer.log(success.toString());

      isLoading.value = false;

      // when done, goto OTP entering page
      Get.to(() => OTPPage());
    } catch (e) {
      CustomSnackbar.show('Error', e.toString());
    }
  }

  Future<void> twilioVerifyOTP() async {
    try {
      isLoading.value = true;

      final responseData = await twilioService.verifyOtp(
          countryCode + phoneNumberController.text,
          verificationCodeEntered.value);

      if (responseData == 'approved') {
        checkIfUserExistsAndSign(false, null);
      } else {
        responseData == 'expired'
            ? CustomSnackbar.show(
                'Session Expired', 'Please request to resend the OTP')
            : responseData == 'failed'
                ? CustomSnackbar.show(
                    'Failed', 'An internal error has occurred')
                : responseData == 'deleted'
                    ? CustomSnackbar.show('Deleted',
                        'The OTP has been removed, please click on resend OTP')
                    : responseData == 'canceled'
                        ? CustomSnackbar.show(
                            'Canceled', 'Please click on resend OTP')
                        : responseData == 'max_attempts_reached'
                            ? CustomSnackbar.show('Attention',
                                'Max attempt reached. Please try again later!')
                            : Container();
      }
    } catch (e) {
      CustomSnackbar.show('Error',
          'Invalid OTP. Please enter a valid OTP ot try requesting the OTP again');
    }
  }

  Future<void> resendOTP() async {
    try {
      TwilioService twilioService = TwilioService();
      final success =
          await twilioService.sendOtp(countryCode + phoneNumberController.text);

      developer.log(success.toString());
    } catch (e) {
      CustomSnackbar.show('Error', e.toString());
    }
  }

  // USER STATE PERSISTENCE
  @override
  void onReady() {
    super.onReady();
    _userPersist = Rx<User?>(firebaseAuth.currentUser);
    _userPersist.bindStream(firebaseAuth.authStateChanges());
    ever(_userPersist, _setInitialRoute);
  }

  _setInitialRoute(User? user) {
    if (user == null) {
      Get.to(() => const SplashPage());
      Future.delayed(const Duration(seconds: 2)); // check for problems
      Get.offAll(() => LoginPage());
    } else {
      Get.to(() => const SplashPage());
      setInitialVariables();
    }
  }

  void setInitialVariables() {
    try {
      firestore
          .collection('vendors')
          .doc(firebaseAuth.currentUser!.uid)
          .snapshots()
          .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.exists) {
          currentUserUID.value = FirebaseAuth.instance.currentUser!.uid;
          currentUsername.value = snapshot.data()?['username'] ?? '';
          currentEmail.value = snapshot.data()?['email'] ?? '';
          currentPhoneNumber.value = snapshot.data()?['phoneNumber'] ?? '';
          currentProfilePic.value = snapshot.data()?['profilePic'] ?? '';
          currentStoreName.value = snapshot.data()?['storeName'] ?? '';
          currentOfficeAddress.value = snapshot.data()?['officeAddress'] ?? '';
          currentvendorAppBundleId.value =
              snapshot.data()?['vendorAppBundleId'] ?? '';

          // currentHashedPassword.value = snapshot.data()?['hashedPassword'] ?? ''; // TODO : Hashed password is not made,

          isSplashing.value = false;
          Get.offAll(() => HomePage());
        } else {
          Get.offAll(() => HomePage());
        }
      });
    } catch (e) {
      CustomSnackbar.show('', '"Error occured while loading details"');
    }
  }

  Future<void> checkIfUserExistsAndSign(
      bool isPhoneAuth, AuthCredential? credential) async {
    // isPhoneAuth and credentials are supplied when we are doing firestore phone verification,
    // but we did Twilio OPT checking then.
    await firestore
        .collection('vendors')
        .where('email', isEqualTo: emailController.text)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        if (isPhoneAuth) {
          signInUserWithPhone(credential!);
        } else {
          signInUser();
        }
      } else {
        if (isPhoneAuth) {
          signUpUserWithPhone(credential!);
        } else {
          signUpUser();
        }
      }
    }).catchError((e) {
      CustomSnackbar.show('Error', "Failed to fetch details");
    });
  }

  // Sign Up / Registration

  Future<void> signUpUser() async {
    try {
      if (emailController.text.isNotEmpty &&
          phoneNumberController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          usernameController.text.isNotEmpty) {
        credential = await firebaseAuth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());
        currentUserUID.value = credential!.user!.uid;

        VendorModel vendorModel = VendorModel(
          storeName: '',
          vendorsAppBundleId: '',
          username: usernameController.text,
          email: emailController.text.trim(),
          profilePic: '',
          ownerName: usernameController.text,
          uid: currentUserUID.value,
          phoneNumber: phoneNumberController.text,
          isSubscribed: false,
          officeAddress: '',
          gstin: '',
        );

        await FirebaseFirestore.instance
            .collection("vendors")
            .doc(currentUserUID.value)
            .set(vendorModel.toJson());

        CustomSnackbar.show("Account Created",
            "Wassup ${currentUsername.value}, have a great time here!");
        Get.offAll(() => HomePage(), transition: Transition.circularReveal);
      } else {
        CustomSnackbar.show("Failed Creating Account",
            "Please make sure you have filled all the details");
      }
    } catch (e) {
      CustomSnackbar.show("Error Creating Account",
          "Please make sure you have filled all the details $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in / Log in
  Future<void> signInUser() async {
    isLoading.value = true;
    try {
      if (emailController.text.isNotEmpty &&
          usernameController.text.isNotEmpty &&
          phoneNumberController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());

        CustomSnackbar.show("Success", "Logged in successfully");
        Get.offAll(() => HomePage(), transition: Transition.circularReveal);
      } else {
        CustomSnackbar.show(
            "Error Logging in", "Please fill up all the blocks");
      }
    } catch (e) {
      CustomSnackbar.show("Error Logging in", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpUserWithPhone(AuthCredential credential) async {
    try {
      if (emailController.text.isNotEmpty &&
          phoneNumberController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          usernameController.text.isNotEmpty) {
        await firebaseAuth.signInWithCredential(credential);

        currentUserUID.value = firebaseAuth.currentUser!.uid;

        VendorModel vendorModel = VendorModel(
          storeName: '',
          vendorsAppBundleId: '',
          username: usernameController.text,
          email: emailController.text.trim(),
          profilePic: '',
          ownerName: usernameController.text,
          uid: currentUserUID.value,
          phoneNumber: phoneNumberController.text,
          isSubscribed: false,
          officeAddress: '',
          gstin: '',
        );

        await FirebaseFirestore.instance
            .collection("vendors")
            .doc(currentUserUID.value)
            .set(vendorModel.toJson());

        CustomSnackbar.show("Account Created",
            "Wassup ${currentUsername.value}, have a great time here!");
        Get.offAll(() => HomePage(), transition: Transition.circularReveal);
      } else {
        CustomSnackbar.show("Failed Creating Account",
            "Please make sure you have filled all the details");
      }
    } catch (e) {
      CustomSnackbar.show("Error Creating Account",
          "Please make sure you have filled all the details $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInUserWithPhone(AuthCredential credential) async {
    isLoading.value = true;
    try {
      if (emailController.text.isNotEmpty &&
          usernameController.text.isNotEmpty &&
          phoneNumberController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        await firebaseAuth.signInWithCredential(credential);
        CustomSnackbar.show("Success", "Logged in successfully");
        Get.offAll(() => HomePage(), transition: Transition.circularReveal);
      } else {
        CustomSnackbar.show(
            "Error Logging in", "Please fill up all the blocks");
      }
    } catch (e) {
      CustomSnackbar.show("Error Logging in", '');
    } finally {
      isLoading.value = false;
    }
  }

  void showTermsAndConditions(BuildContext context, {bool showLogout = false}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_back_ios).onTap(() {
                      Get.back();
                    }),
                    "Terms & Conditions and Privacy Policy"
                        .text
                        .bold
                        .size(14)
                        .make(),
                    ''.text.make(),
                  ],
                ),
                15.heightBox,
                const Text(termsAndConditionsString),
                showLogout
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: "Logout"
                                .text
                                .bold
                                .size(20)
                                .color(darkPinkColor)
                                .make()
                                .onTap(() async {
                              await FirebaseAuth.instance.signOut();
                            }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: "Delete Account"
                                .text
                                .bold
                                .size(18)
                                .color(redColor)
                                .make()
                                .onTap(() async {
                              deleteAcc(context);
                            }),
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteAcc(BuildContext context) async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              20.heightBox,
              "Do you want to delete this account for sure?\nThis will delete all your credentials, and\nyou can re-use your phone number to\ncreate a new account."
                  .text
                  .bold
                  .make(),
              20.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  "No"
                      .text
                      .color(darkPinkColor.withOpacity(0.5))
                      .make()
                      .onTap(() {
                    Get.back();
                  }),
                  "Yes".text.color(redColor).make().onTap(() async {
                    var uid = currentUserUID.value;
                    await FirebaseAuth.instance.signOut();
                    firestore.collection('users').doc(uid).delete();
                    CustomSnackbar.show(
                        'Success', 'Account deleted successfully');
                  }),
                ],
              ),
              20.heightBox,
            ],
          );
        },
      );
    } catch (e) {
      CustomSnackbar.show('error', e.toString());
    }
  }
}
