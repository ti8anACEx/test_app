import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/carousel/gf_items_carousel.dart';
import 'package:test_app/constants/colors.dart';
import 'package:test_app/features/product_details/controllers/edit_controller.dart';
import 'package:velocity_x/velocity_x.dart';

import 'single_image_selection.dart';

// ignore: must_be_immutable
class ImageDisplay extends StatelessWidget {
  final EditController editController;
  const ImageDisplay({super.key, required this.editController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
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
                  "Selected ${editController.draftImagesAsBytes.length.toString()}/4 images"
                      .text
                      .color(whiteColor)
                      .make(),
                  10.heightBox,
                  editController.draftImagesAsBytes.isEmpty
                      ? "Please pick an image (max. 4)"
                          .text
                          .color(whiteColor)
                          .make()
                      : GFItemsCarousel(
                          rowCount: 2,
                          children: List.generate(
                              editController.draftImagesAsBytes.length,
                              (index) {
                            return SingleImageSelection(
                                editController: editController, index: index);
                          })),
                  5.heightBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await editController.pickFiles();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                            backgroundColor: darkPinkColor),
                        child: "Gallery".text.make(),
                      ),
                      20.widthBox,
                      const Icon(Icons.camera_alt, color: blackColor, size: 30)
                          .onTap(() {
                        editController.pickFilesWithCamera();
                      }),
                    ],
                  ),
                  10.heightBox,
                ],
              )),
        ),
      ),
    );
  }
}
