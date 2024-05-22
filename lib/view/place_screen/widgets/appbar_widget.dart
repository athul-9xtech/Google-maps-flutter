import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/csc_controller.dart';
import 'package:google_map/controller/location_controller.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:google_map/view/place_screen/widgets/filter_box.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors().darkOrange,
                size: 20,
              ),
            ),
            Column(
              children: [
                Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors().greyColor.shade600,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'GURUDWARAS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // ------- Filter button --------
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      const FilterBox(), // open filter dialog box
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors().primaryOrange,
                      AppColors().darkOrange,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        GetBuilder<CscController>(
          init: CscController(),
          id: 'breadcrumb',
          builder: (controller) {
            String breadcrumb = '';
            if (controller.selectedCountry != null) {
              breadcrumb = controller.selectedCountry!;
              if (controller.state != null) {
                breadcrumb += ' / ${controller.state!.name}';
              }
              if (controller.city != null) {
                breadcrumb += ' / ${controller.city!.name}';
              }
            } else if (locationController.currentCountry != null) {
              breadcrumb = locationController.currentCountry!;
              if (locationController.currentState != null) {
                breadcrumb += ' / ${locationController.currentState}';
              }
              if (locationController.currentCity != null) {
                breadcrumb += ' / ${locationController.currentCity}';
              }
            }

            return controller.selectedCountry != null ||
                    locationController.currentCountry != null
                ? Column(
                    children: [
                      const SizedBox(height: 5),
                      // country/state/city
                      Text(
                        breadcrumb,
                        style: TextStyle(color: AppColors().darkOrange),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : const SizedBox(height: 20);
          },
        )
      ],
    );
  }
}
