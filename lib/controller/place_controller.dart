import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/csc_controller.dart';
import 'package:google_map/controller/location_controller.dart';
import 'package:google_map/model/places_model.dart';
import 'package:google_map/service/place_service.dart';

class PlaceController extends GetxController {
  PlacesResponse? placesData;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final locationController = Get.put(LocationController());
  final cscController = Get.put(CscController());

  Future<void> findPlaces(String query,
      {String? countryCode, String? stateName, String? city}) async {
    isLoading.value = true;
    // find places
    placesData = await PlaceService().fetchPlaces(
      query,
      countryCode: countryCode,
      state: stateName,
      city: city,
    );
    isLoading.value = false;
  }

  Future<void> nearbySearchEvent(String query) async {
    isLoading.value = true;
    final hasPermission = await locationController.handleLocationPermission();
    if (hasPermission) {
      await locationController.getCurrentPosition();
      if (locationController.currentPosition != null) {
        placesData = await PlaceService().nearbySearch(
          query,
          locationController.currentPosition!.latitude.toString(),
          locationController.currentPosition!.longitude.toString(),
        );
      } else {
        await findPlaces(
          'Gurudwara',
          countryCode: cscController.countryCode,
          stateName: cscController.state?.name,
          city: cscController.city?.name,
        );
      }
    } else {
      // if user denied location permission,
      // then fetch places normally instead of nearby.
      await findPlaces(
        'Gurudwara',
        countryCode: cscController.countryCode,
        stateName: cscController.state?.name,
        city: cscController.city?.name,
      );
    }
    isLoading.value = false;
  }
}
