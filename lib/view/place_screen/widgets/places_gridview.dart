import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/place_controller.dart';
import 'package:google_map/service/place_service.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:google_map/view/map_screen/map_screen.dart';

class PlacesGridview extends StatelessWidget {
  const PlacesGridview({super.key, required this.placeController});

  final PlaceController placeController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: placeController.placesData!.results!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final place = placeController.placesData!.results![index];

          return InkWell(
            onTap: () => Get.to(
              () => MapScreen(place: place),
              transition: Transition.rightToLeft,
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
                      child: place.photos != null &&
                              place.photos![0].photoReference != null
                          ? FutureBuilder(
                              future: PlaceService().getPhotoUrl(
                                place.photos![0].photoReference!,
                                maxWidth: place.photos![0].width,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox();
                                } else if (snapshot.hasData &&
                                    snapshot.data != null) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                } else {
                                  return const Icon(
                                    Icons.image_not_supported_rounded,
                                    color: Colors.amber,
                                  );
                                }
                              })
                          : const Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
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
    );
  }
}
