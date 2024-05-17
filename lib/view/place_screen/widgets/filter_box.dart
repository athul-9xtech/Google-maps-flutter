import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/csc_controller.dart';
import 'package:google_map/controller/place_controller.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:google_map/view/place_screen/widgets/filter_dropdown_btn.dart';

class FilterBox extends StatefulWidget {
  const FilterBox({super.key});

  @override
  State<FilterBox> createState() => _FilterBoxState();
}

class _FilterBoxState extends State<FilterBox> {
  final cscController = Get.put(CscController());
  final placeController = Get.put(PlaceController());

  InkWell _buildCountryDropdown(PlaceController controller) {
    return InkWell(
      onTap: () => cscController.openCountryPicker(context, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: cscController.selectedCountry != null
                ? AppColors().primaryOrange
                : Colors.grey.shade400,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              cscController.selectedCountry ?? 'country',
              style: TextStyle(
                color: cscController.selectedCountry != null
                    ? AppColors().primaryOrange
                    : Colors.black,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: cscController.selectedCountry != null
                  ? AppColors().primaryOrange
                  : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  dynamic _buildStatesDropdown() {
    if (cscController.countryCode != null) {
      return FutureBuilder(
        future: csc.getStatesOfCountry(cscController.countryCode!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.data != null && snapshot.hasData) {
            List<csc.State> states = snapshot.data!;
            return FilterDropDownButton(
              hintText: 'State',
              states: states,
            );
          } else {
            return const SizedBox();
          }
        },
      );
    } else {
      return const FilterDropDownButton(
        hintText: 'State',
        states: [],
      );
    }
  }

  GetBuilder<CscController> _buildCityDropdown() {
    return GetBuilder<CscController>(
      id: 'city-dropdown',
      builder: (controller) {
        if (cscController.countryCode != null && cscController.state != null) {
          return FutureBuilder(
            future:
                // cscController.state != null
                //     ?
                csc.getStateCities(
                    cscController.countryCode!, cscController.state!.isoCode),

            // :
            // csc.getCountryCities(
            //     cscController.countryCode!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const FilterDropDownButton(
                  hintText: 'City',
                  cities: [],
                );
              } else if (snapshot.data != null && snapshot.hasData) {
                List<csc.City> cities = snapshot.data!;
                return FilterDropDownButton(
                  hintText: 'City',
                  cities: cities,
                );
              } else {
                return const SizedBox();
              }
            },
          );
        } else {
          return const FilterDropDownButton(
            hintText: 'City',
            cities: [],
          );
        }
      },
    );
  }

  GestureDetector _buildSearchButton() {
    return GestureDetector(
      onTap: _searchEvent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 40,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            colors: [
              AppColors().primaryOrange,
              AppColors().darkOrange,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Text(
          'SEARCH',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future _searchEvent() async {
    if (cscController.selectedCountry != null ||
        cscController.state != null ||
        cscController.city != null) {
      Get.back(); // close filter pop up

      await placeController.findPlaces(
        'Gurudwara',
        countryCode: cscController.countryCode,
        stateName: cscController.state?.name,
        city: cscController.city?.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GetBuilder<PlaceController>(
        init: PlaceController(),
        id: 'Filter-options',
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose country'),
                const SizedBox(height: 8),
                _buildCountryDropdown(controller), //#

                const SizedBox(height: 14),
                const Text('State'),
                const SizedBox(height: 3),
                _buildStatesDropdown(), //#

                const SizedBox(height: 12),
                const Text('City'),
                const SizedBox(height: 3),
                _buildCityDropdown(), //#

                const SizedBox(height: 25),

                //* ::::::::::::: Search Button :::::::::::::
                _buildSearchButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
