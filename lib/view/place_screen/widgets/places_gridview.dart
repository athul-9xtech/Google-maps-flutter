import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/csc_controller.dart';
import 'package:google_map/controller/location_controller.dart';
import 'package:google_map/controller/place_controller.dart';
import 'package:google_map/model/places_model.dart';
import 'package:google_map/service/place_service.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:google_map/view/map_screen/map_screen.dart';

class PlacesGridview extends StatefulWidget {
  const PlacesGridview(
      {super.key, required this.placeController, required this.cscController});

  final PlaceController placeController;
  final CscController cscController;

  @override
  State<PlacesGridview> createState() => _PlacesGridviewState();
}

class _PlacesGridviewState extends State<PlacesGridview> {
  final locationController = Get.put(LocationController());
  bool isLoading = false;

  Future<void> fetchPlacesWithNextToken() async {
    setState(() {
      isLoading = true;
    });
    PlacesResponse placesData;
    if (widget.placeController.lastFetchedApi == 'nearby') {
      placesData = await PlaceService().nearbySearch(
        'Gurudwara',
        locationController.currentPosition!.latitude.toString(),
        locationController.currentPosition!.longitude.toString(),
        nextPageToken: widget.placeController.placesData!.nextPageToken,
      );
    } else {
      placesData = await PlaceService().fetchPlaces(
        'Gurudwara',
        countryCode: widget.cscController.countryCode,
        state: widget.cscController.state?.name,
        city: widget.cscController.city?.name,
        nextPageToken: widget.placeController.placesData!.nextPageToken,
      );
    }

    if (placesData.results != null && placesData.results!.isNotEmpty) {
      widget.placeController.placesData!.results!.addAll(placesData.results!);
      widget.placeController.placesData!.nextPageToken =
          placesData.nextPageToken;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              isLoading == false) {
            if (widget.placeController.placesData!.nextPageToken != null) {
              fetchPlacesWithNextToken();
            }
          }
          return true;
        },
        child: GridView.builder(
          shrinkWrap: true,
          //padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: widget.placeController.placesData!.results!.length +
              (isLoading ? 1 : 0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            if (index == widget.placeController.placesData!.results!.length) {
              return Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    color: AppColors().darkOrange,
                    strokeWidth: 2.3,
                  ),
                ),
              );
            }

            final place = widget.placeController.placesData!.results![index];

            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(place: place),
                ),
              ),
              child: SizedBox(
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors().greyColor.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: place.imageUrls != null &&
                                place.imageUrls!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  place.imageUrls![0],
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                        // place.photos != null &&
                        //         place.photos![0].photoReference != null
                        //     ? FutureBuilder(
                        //         future: PlaceService().getPhotoUrl(
                        //           place.photos![0].photoReference!,
                        //           maxWidth: place.photos![0].width,
                        //         ),
                        //         builder: (context, snapshot) {
                        //           if (snapshot.connectionState ==
                        //               ConnectionState.waiting) {
                        //             return const SizedBox();
                        //           } else if (snapshot.hasData &&
                        //               snapshot.data != null) {
                        //             return ClipRRect(
                        //               borderRadius: BorderRadius.circular(5),
                        //               child: Image.network(
                        //                 snapshot.data!,
                        //                 fit: BoxFit.cover,
                        //               ),
                        //             );
                        //           } else {
                        //             return const Icon(
                        //               Icons.image_not_supported_rounded,
                        //               color: Colors.amber,
                        //             );
                        //           }
                        //         })
                        //     : const Icon(
                        //         Icons.image_not_supported_rounded,
                        //         color: Colors.white,
                        //         size: 30,
                        //       ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
