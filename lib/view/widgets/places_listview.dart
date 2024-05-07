import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_map/controller/place_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class PlacesListview extends StatelessWidget {
  const PlacesListview({super.key, required this.placeController});

  final PlaceController placeController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: placeController.placesData != null &&
                placeController.placesData!.results != null
            ? ListView.separated(
                itemCount: placeController.placesData!.results!.length,
                itemBuilder: (context, index) {
                  final place = placeController.placesData!.results![index];

                  return InkWell(
                    onTap: () => navigateToGoogleMaps(
                      place.formattedAddress ?? '',
                      place.geometry.location.lat,
                      place.geometry.location.lng,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // place.photos != null
                          //     ? SingleChildScrollView(
                          //         scrollDirection: Axis.horizontal,
                          //         child: Row(
                          //           children: List.generate(
                          //             place.photos!.length,
                          //             (index) => Container(
                          //               margin: const EdgeInsets.only(right: 10),
                          //               height: 135,
                          //               width: 145,
                          //               decoration: BoxDecoration(
                          //                 borderRadius: BorderRadius.circular(10),
                          //                 color: Colors.accents[index],
                          //                 image: DecorationImage(
                          //                   fit: BoxFit.cover,
                          //                   image: NetworkImage(images[index]),
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       )
                          //     : const SizedBox(),
                          // const SizedBox(height: 10),
                          Text(
                            place.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          place.rating != null && place.rating != 0
                              ? Row(
                                  children: [
                                    Text(place.rating.toString()),
                                    RatingBarIndicator(
                                      rating: place.rating!,
                                      itemBuilder: (context, index) =>
                                          const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 16.0,
                                      unratedColor: Colors.grey.shade300,
                                    ),
                                    Text(' (${place.userRatingsTotal})'),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 2),
                          Text(place.types?.first ?? ""),
                          const SizedBox(height: 2),
                          place.openingHours?.openNow == true
                              ? const Text(
                                  'Open',
                                  style: TextStyle(color: Colors.green),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey.shade200,
                    thickness: 10,
                  );
                },
              )
            : const SizedBox(),
      ),
    );
  }

  Future<void> navigateToGoogleMaps(
      String placeAddress, double latitude, double longitude) async {
    // Construct the URL with the place's address
    final googleMapsUrl = placeAddress.isEmpty
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$placeAddress');

    if (!await launchUrl(googleMapsUrl)) {
      throw Exception('Could not launch $googleMapsUrl');
    }
  }
}
