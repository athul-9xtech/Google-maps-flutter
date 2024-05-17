import 'package:country_picker/country_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/place_controller.dart';
import 'package:google_map/utils/constants.dart';

class CscController extends GetxController {
  String? selectedCountry;
  String? countryCode;
  csc.State? state;
  csc.City? city;

  void openCountryPicker(
      BuildContext context, PlaceController placeController) {
    showCountryPicker(
      context: context,
      useSafeArea: true,
      countryListTheme: CountryListThemeData(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: const TextStyle(height: 2.2),
        inputDecoration: countryPickerInputDecoration(),
      ),
      onSelect: (Country country) async {
        countryCode = country.countryCode;
        selectedCountry = country.displayNameNoCountryCode;
        state = null;
        city = null;
        placeController.update(['Filter-options']);
      },
    );
  }
}
