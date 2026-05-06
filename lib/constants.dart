import 'package:flutter/material.dart';

const kFontSizeLarge = 24.0;
const kTextOpacity = 0.6;

const kPrimaryColor = Color(0xff72DBF2);
const kSecondaryTextColor = Color(0xff757575);

const kAppBackgroundBaseColor = Color(0xff0d1f22);
const kAppBackgroundGradient = [Color(0xff1a3a40), Color(0xff0d1f22)];

const kEdgeInsetsAll = EdgeInsets.all(16);
const kEdgeInsetsSymmetricHorizontal = EdgeInsets.symmetric(horizontal: 24);
const kProfileFieldBorderRadius = BorderRadius.all(Radius.circular(12));

OutlineInputBorder buildProfileOutlineInputBorder({
  required Color color,
  double width = 1.0,
}) {
  return OutlineInputBorder(
    borderRadius: kProfileFieldBorderRadius,
    borderSide: BorderSide(color: color, width: width),
  );
}

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
