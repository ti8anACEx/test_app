import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/constants/colors.dart';
import 'package:test_app/features/home/controllers/home_controller.dart';
import 'package:test_app/features/home/pages/home_page.dart';
import 'package:test_app/models/item_model.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../commons/widgets/custom_snackbar.dart';

class ItemController extends GetxController {
  ItemModel? itemModel;
  HomeController homeController = Get.find(tag: 'home-controller');

  RxBool isRequestingRevoke = false.obs;
  RxBool isDeleting = false.obs;
  RxBool isLoading = true.obs;
  RxBool isPushedToSale = false.obs;

  RxString pushedRate = ''.obs;
  RxString pushedDate = ''.obs;
  RxString pushedProductName = ''.obs;
  RxString pushedDescription = ''.obs;

  RxList<String> pushedImageLinks = <String>[].obs;

  RxInt displayingImageIndex = 0.obs;
  DocumentSnapshot<Object?> item;
  Map<String, dynamic>? data;

  ItemController({required this.item}) {
    itemModel = ItemModel.fromSnap(item);

    isPushedToSale.value = itemModel!.isPushedToSale;
    pushedRate.value = itemModel!.pushedRate;
    pushedDate.value = itemModel!.pushedDate;
    pushedProductName.value = itemModel!.pushedProductName;
    pushedDescription.value = itemModel!.pushedDescription;
    pushedImageLinks.value = itemModel!.pushedImageLinks;

    data = item.data() as Map<String, dynamic>;
  }

  Future<void> revokeFromSale(ItemController itemController) async {
    removeFiles(itemController).then((value) async {
      Map<String, dynamic> fieldsToUpdate = {
        'pushedRate': '',
        'pushedDate': '',
        'pushedDescription': '',
        'pushedProductName': '',
        'pushedImageLinks': [],
        'isPushedToSale': false,
      };
      await updateItemFields(fieldsToUpdate, itemController);
    });
  }

  Future<void> deleteItem(BuildContext context) async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              20.heightBox,
              "Do you want to delete this item?".text.bold.make(),
              20.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  "No".text.color(darkPinkColor.withOpacity(0.5)).make(),
                  "Yes".text.color(redColor).make().onTap(() {
                    FirebaseFirestore.instance
                        .collection('items')
                        .doc(itemModel!.itemId)
                        .delete()
                        .then((value) {
                      Get.offAll(() => HomePage());
                      homeController.fetchPosts();
                    });
                  }),
                ],
              ),
              20.heightBox,
            ],
          );
        },
      );
    } catch (e) {
      CustomSnackbar.show('erroe', e.toString());
    }
  }

  Future<void> removeFiles(ItemController itemController) async {
    isDeleting.value = true;

    try {
      final storage = FirebaseStorage.instance;
      final directoryRef = storage.ref().child(
          'uploads/items/${itemController.itemModel!.itemId}/pushedImages/');

      final ListResult listResult = await directoryRef.listAll();

      await Future.forEach(listResult.items, (Reference item) async {
        await item.delete();
      });
      CustomSnackbar.show('Success', 'Revoked the item from sale');
    } catch (e) {
      CustomSnackbar.show('Erroe', 'Failed to remove the item from sale');
    } finally {
      isDeleting.value = false;
    }
  }

  // Update function
  Future<void> updateItemFields(Map<String, dynamic> fieldsToUpdate,
      ItemController itemController) async {
    try {
      DocumentReference itemRef = FirebaseFirestore.instance
          .collection('items')
          .doc(itemController.itemModel!.itemId);
      await itemRef.update(fieldsToUpdate);
      itemController.isPushedToSale.value = true;
      CustomSnackbar.show('Success', 'Revoked successfully!');
      itemController.isPushedToSale.value = false;

      homeController.fetchPosts();
      itemController.refresh();
      Get.off(() => HomePage());
    } catch (e) {
      log('Error updating item fields: $e');
      // Handle error here
    }
  }
}
