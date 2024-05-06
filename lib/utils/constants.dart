import 'package:flutter/material.dart';
import 'package:get/get.dart';

String apiBaseUrl = "https://maps.googleapis.com/maps/api/place/";
String apitoken = "AIzaSyD5tD4C3pB2ImYegrMskiGFvDWbitwKwVY";

// textSearch url = "${apiBaseUrl}textsearch/json?query=hindu+temples&key=${apitoken}"
// nearbySearch url = "${apiBaseUrl}nearbysearch/json?location=${userLocation.lat},${userLocation.lng}&radius=1000&types=${typed}&keyword=${keyword}&key=${apitoken}${nextPageToken ? &pagetoken=${nextPageToken} : ''}"

commonSnackbar(
  String text, {
  IconData? icon,
  Color? iconColor,
  Color? textColor,
  Color? bgColor,
  SnackPosition? snackPosition,
}) {
  return Get.snackbar(
    '',
    '',
    titleText: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        icon != null
            ? Icon(icon, color: iconColor ?? Colors.white)
            : const SizedBox.shrink(),
        SizedBox(width: icon != null ? 15 : 0),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    ),
    messageText: const SizedBox.shrink(),
    snackPosition: snackPosition ?? SnackPosition.TOP,
    backgroundColor: bgColor,
    animationDuration: const Duration(milliseconds: 500),
  );
}
