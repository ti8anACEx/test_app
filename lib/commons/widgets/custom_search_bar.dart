import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/constants/colors.dart';
import 'package:test_app/features/home/controllers/home_controller.dart';
import 'package:velocity_x/velocity_x.dart';

Widget customSearchBar() {
  HomeController homeController = Get.find(tag: 'home-controller');
  return Material(
    elevation: 0,
    borderRadius: BorderRadius.circular(30),
    child: TextFormField(
      onFieldSubmitted: (value) {
        homeController.isSearching.value = true;
        homeController.searchQuery();
        if (value == '') {
          homeController.isSearching.value = false;
        }
      },
      style: const TextStyle(
          fontWeight: FontWeight.w100, fontSize: 17, color: blackColor),
      controller: homeController.searchController,
      decoration: InputDecoration(
          labelText: "Search for 'Products'",
          // suffixIcon: const Icon(Icons.mic),
          constraints: const BoxConstraints(maxHeight: 75),
          contentPadding: const EdgeInsets.only(top: 5, left: 12, right: 12),
          suffix: "Clear".text.color(blackColor).make().onTap(() {
            homeController.searchController.clear();
            homeController.isSearching.value = false;
          }),
          prefixIconColor: redColor,
          hintText: "",
          fillColor: whiteColor,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: const Icon(Icons.search, color: blackColor),
          // prefixIcon: Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     7.widthBox,
          //     const Icon(Icons.search, color: blackColor),
          //     5.widthBox,
          //   ],
          // ),
          hintStyle: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 12,
              color: whiteColor.withOpacity(0.6))),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter your search...';
        }
        return null;
      },
    ),
  );
}
