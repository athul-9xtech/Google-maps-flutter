import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_map/utils/constants.dart';

class LocationController extends GetxController {
  Position? currentPosition;
  String? currentCountry;
  String? currentState;
  String? currentCity;

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      commonSnackbar(
        'Location services are disabled. Please enable the services',
        snackPosition: SnackPosition.BOTTOM,
        icon: Icons.location_off,
        bgColor: Colors.grey.shade900,
        textColor: Colors.grey.shade300,
      );

      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        commonSnackbar(
          'Location permissions are denied',
          snackPosition: SnackPosition.BOTTOM,
          icon: Icons.location_off,
          bgColor: Colors.grey.shade900,
          textColor: Colors.grey.shade300,
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      commonSnackbar(
        'Location permissions are permanently denied, we cannot request permissions.',
        snackPosition: SnackPosition.BOTTOM,
        icon: Icons.location_off,
        bgColor: Colors.grey.shade900,
        textColor: Colors.grey.shade300,
      );

      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();

    if (hasPermission) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        currentPosition = position;
        getAddressFromLatLng(position.latitude, position.longitude);
      }).catchError((e) {
        debugPrint(e);
      });
    }
  }

  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentCountry = place.country;
        currentState = place.administrativeArea;
        currentCity = place.locality;
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
