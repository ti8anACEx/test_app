import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/features/auth/controllers/auth_controller.dart';
import 'package:test_app/features/home/controllers/home_controller.dart';
import 'package:uuid/uuid.dart';

import '../../../commons/widgets/custom_snackbar.dart';

class UploadCarouselsController extends GetxController {
  RxList<Uint8List> carouselImagesAsBytes = <Uint8List>[].obs;
  RxList<String> carouselImagesLinks = <String>[].obs;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  AuthController authController = Get.find(tag: 'auth-controller');
  HomeController homeController = Get.find(tag: 'home-controller');

  RxBool isLoading = false.obs;
  RxBool isUploadingFiles = false.obs;

  void checkAndClearList({int extra = 0}) {
    if ((carouselImagesAsBytes.length + extra) >= 4) {
      carouselImagesAsBytes.clear();
    }
  }

  Future<void> pickFiles() async {
    try {
      checkAndClearList();
      var pickedImgs = await ImagePicker().pickMultiImage();
      checkAndClearList(extra: pickedImgs.length);
      var len = 0;
      for (final image in pickedImgs) {
        len++;
        final imageBytes = await File(image.path).readAsBytes();
        carouselImagesAsBytes.add(imageBytes);
        if (len >= 4) {
          return;
        }
      }
    } catch (e) {
      CustomSnackbar.show("Error", e.toString());
    }
  }

  Future<void> pickFilesWithCamera() async {
    try {
      checkAndClearList();

      var image = await ImagePicker().pickImage(source: ImageSource.camera);

      final imageBytes = await File(image!.path).readAsBytes();
      carouselImagesAsBytes.add(imageBytes);
    } catch (e) {
      CustomSnackbar.show("Error", e.toString());
    }
  }

  Future<void> uploadCarousels() async {
    isLoading.value = true;
    if (carouselImagesAsBytes.isNotEmpty) {
      if (carouselImagesAsBytes.isEmpty) {
        isLoading.value = false;
        return;
      }

      try {
        String itemId = const Uuid().v1();

        await uploadFiles(itemId).then((value) async {
          await firestore
              .collection('vendors')
              .doc(authController.currentUserUID.value)
              .update({'carouselImages': carouselImagesLinks});

          CustomSnackbar.show("Success", "Uploads successful!");
          homeController.fetchPosts();
        });
      } catch (e) {
        CustomSnackbar.show("Error", e.toString());
      } finally {
        isLoading.value = false;
      }
    } else {
      CustomSnackbar.show("Failed", "Make sure to enter all fields properly");
      isLoading.value = false;
    }
  }

  Future<void> uploadFiles(String itemId) async {
    carouselImagesLinks.clear();
    isUploadingFiles.value = true;
    try {
      for (int i = 0; i < carouselImagesAsBytes.length; i++) {
        Uint8List fileBytes = carouselImagesAsBytes[i];

        String cimg = 'carousel_image_$i';

        Reference storageReference =
            storage.ref().child('uploads/vednors/carouselImages/$cimg');
        UploadTask uploadTask = storageReference.putData(fileBytes);

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        carouselImagesLinks.add(downloadURL);
      }
    } catch (e) {
      CustomSnackbar.show("Error", e.toString());
    } finally {
      isUploadingFiles.value = false;
    }
  }

  Future<void> deleteExistingCarousels() async {
    try {
      await firestore
          .collection('vendors')
          .doc(authController.currentUserUID.value)
          .update({'carouselImages': []});
      CustomSnackbar.show(
          "Successs", "Existing carousel images deleted successfully!");
    } catch (e) {
      CustomSnackbar.show("Error", e.toString());
    }
  }
}
