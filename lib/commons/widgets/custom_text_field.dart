import 'package:flutter/material.dart';
import 'package:test_app/constants/colors.dart';

Widget customTextField(
    {TextInputType? textInputType = TextInputType.text,
    String? hint = '',
    String? prefixText = '',
    int? maxLength,
    bool isObscured = false,
    String labelText = '',
    required TextEditingController controller}) {
  return TextField(
    controller: controller,
    obscureText: isObscured,
    decoration: InputDecoration(
      fillColor: fontGrey.withOpacity(0.15),
      prefixText: prefixText,
      filled: true,
      labelText: labelText,
      labelStyle: const TextStyle(fontWeight: FontWeight.w200, fontSize: 12),
      contentPadding: const EdgeInsets.all(8.0),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: pinkColor, width: 2.0),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black),
    ),
    textAlign: TextAlign.start,
    maxLength: maxLength,
    keyboardType: textInputType,
    onChanged: (value) {
      // Handle onChanged event if needed
    },
  );
}
