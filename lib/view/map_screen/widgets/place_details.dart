import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_map/model/places_model.dart';
import 'package:google_map/service/place_service.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsWidget extends StatelessWidget {
  const PlaceDetailsWidget({super.key, required this.place});

  final PlaceResult place;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // <<<<<<<< Place images section >>>>>>>>>>
          place.photos != null && place.photos![0].photoReference != null
              ? FutureBuilder(
                  future: fetchImagesOfPlace(place.photos!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(
                        strokeWidth: 3.5,
                        color: AppColors().primaryOrange,
                      );
                    } else if (snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      List<String> images = snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            images.length,
                            (index) => Container(
                              margin: const EdgeInsets.only(right: 10),
                              height: 135,
                              width: 145,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(images[index]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  })
              : const SizedBox(),
          const SizedBox(height: 10),

          // <<<<<<<<< Place details Section >>>>>>>>>>
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (place.formattedAddress != null)
                      const SizedBox(height: 2),
                    if (place.formattedAddress != null)
                      Text(place.formattedAddress!),
                    const SizedBox(height: 2),
                    place.rating != null && place.rating != 0
                        ? Row(
                            children: [
                              Text(place.rating.toString()),
                              RatingBarIndicator(
                                rating: place.rating!,
                                itemBuilder: (context, index) => const Icon(
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
                    // Text(place.types?.first ?? ""),
                    // const SizedBox(height: 2),
                    place.openingHours?.openNow == true
                        ? const Text(
                            'Open',
                            style: TextStyle(color: Colors.green),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),

              //* ::::::: BUTTON TO OPEN IN GOOGLE MAP ::::::::
              InkWell(
                onTap: () => navigateToGoogleMaps(
                  place.formattedAddress ?? '',
                  place.geometry.location.lat,
                  place.geometry.location.lng,
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors().greyColor.shade300,
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.directions, color: Color(0xff1a73e8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Future<List<String>> fetchImagesOfPlace(List<Photos> photos) async {
    List<String> imageUrls = [];

    for (Photos photo in photos) {
      if (photo.photoReference != null) {
        String imageUrl = await PlaceService().getPhotoUrl(
          photo.photoReference!,
          maxWidth: photo.width,
        );

        imageUrls.add(imageUrl);
      }
    }

    return imageUrls;
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
