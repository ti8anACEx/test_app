import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/carousel/gf_items_carousel.dart';
import 'package:test_app/commons/widgets/custom_button.dart';
import 'package:test_app/commons/widgets/custom_progress_indicator.dart';
import 'package:test_app/constants/colors.dart';
import 'package:test_app/features/upload/controllers/upload_carousels_controller.dart';
import 'package:velocity_x/velocity_x.dart';

// ignore: must_be_immutable
class UploadCarouselImagesPage extends StatelessWidget {
  UploadCarouselImagesPage({super.key});

  UploadCarouselsController uploadCarouselsController =
      Get.put(UploadCarouselsController(), tag: 'upload-carousels-controller');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: "Upload Carousels".text.black.make(),
          centerTitle: true,
          shadowColor: transparentColor,
          backgroundColor: transparentColor,
          leading: const Icon(
            Icons.arrow_back_ios,
            color: blackColor,
          ).onTap(() {
            Get.back();
          }),
        ),
        body: Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: blackColor.withOpacity(0.4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: fontGrey,
                          ),
                          child: Column(
                            children: [
                              15.heightBox,
                              "Selected ${uploadCarouselsController.carouselImagesAsBytes.length.toString()}/4 images"
                                  .text
                                  .color(blackColor)
                                  .make(),
                              10.heightBox,
                              uploadCarouselsController
                                      .carouselImagesAsBytes.isEmpty
                                  ? "Please pick an image (max. 4)"
                                      .text
                                      .color(whiteColor)
                                      .make()
                                  : GFItemsCarousel(
                                      rowCount: 2,
                                      children: List.generate(
                                          uploadCarouselsController
                                              .carouselImagesAsBytes
                                              .length, (index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Stack(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            children: [
                                              ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: MemoryImage(
                                                              uploadCarouselsController
                                                                      .carouselImagesAsBytes[
                                                                  index],
                                                            ),
                                                            fit: BoxFit.cover)),
                                                  )),
                                              const Icon(Icons.cancel)
                                                  .onTap(() {
                                                uploadCarouselsController
                                                    .carouselImagesAsBytes
                                                    .removeAt(index);
                                              }),
                                            ],
                                          ),
                                        );
                                      })),
                              5.heightBox,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await uploadCarouselsController
                                          .pickFiles();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        backgroundColor: darkPinkColor),
                                    child: "Gallery".text.make(),
                                  ),
                                  20.widthBox,
                                  const Icon(Icons.camera_alt,
                                          color: blackColor, size: 30)
                                      .onTap(() {
                                    uploadCarouselsController
                                        .pickFilesWithCamera();
                                  }),
                                ],
                              ),
                              10.heightBox,
                            ],
                          )),
                    ),
                  ),
                  25.heightBox,
                  uploadCarouselsController.isLoading.value
                      ? customProgressIndicator()
                      : CustomButton(
                          text: 'Upload Carousels',
                          onTap: () async {
                            await uploadCarouselsController.uploadCarousels();
                          },
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                  20.heightBox,
                ],
              ),
            ),
          ),
        ));
  }
}
