import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/csc_controller.dart';
import 'package:google_map/controller/place_controller.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:google_map/view/place_screen/widgets/appbar_widget.dart';
import 'package:google_map/view/place_screen/widgets/gridview_shimmers.dart';
import 'package:google_map/view/place_screen/widgets/places_gridview.dart';

class PlaceScreen extends StatefulWidget {
  const PlaceScreen({super.key});

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  final placeController = Get.put(PlaceController());
  final cscController = Get.put(CscController());

  @override
  void initState() {
    cscController.countryCode = null;
    cscController.selectedCountry = null;
    cscController.state = null;
    cscController.city = null;
    fetchNearbyPlaces();
    super.initState();
  }

  Future<void> fetchNearbyPlaces() async {
    await placeController.nearbySearchEvent('Gurudwara');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              // --- Appbar contains title and filter button ---
              const AppbarWidget(),

              // -------- Listing out all places as grid ----------
              ValueListenableBuilder(
                valueListenable: placeController.isLoading,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return const Expanded(
                      child: PlaceGridviewShimmers(),
                    );
                  } else {
                    return placeController.placesData != null &&
                            placeController.placesData!.results != null &&
                            placeController.placesData!.results!.isNotEmpty

                        // --▽ Gridview showing all places ▽--
                        ? PlacesGridview(
                            placeController: placeController,
                            cscController: cscController,
                          )
                        : Expanded(
                            child: Center(
                              child: Text(
                                'No places Found.',
                                style: TextStyle(color: AppColors().darkOrange),
                              ),
                            ),
                          );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
