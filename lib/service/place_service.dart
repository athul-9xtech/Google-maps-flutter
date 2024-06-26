import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/place_controller.dart';
import 'package:google_map/model/places_model.dart';
import 'package:google_map/utils/constants.dart';

class PlaceService {
  final Dio dio = Dio();
  final placeController = Get.put(PlaceController());

  Future<PlacesResponse> fetchPlaces(String query,
      {String? countryCode,
      String? state,
      String? city,
      String? nextPageToken}) async {
    placeController.lastFetchedApi = 'textSearch'; //

    if (city != null) {
      query += '+$city';
    } else if (state != null) {
      query += '+$state';
    }
    final url =
        '${apiBaseUrl}textsearch/json?query=$query&key=$apitoken${nextPageToken != null ? '&pagetoken=$nextPageToken' : ''}';

    log(url);

    try {
      final response = await dio.get(
        url,
        queryParameters: countryCode != null ? {'region': countryCode} : null,
      );

      if (response.statusCode == 200) {
        PlacesResponse placesResponse = PlacesResponse.fromJson(response.data);

        // Filter the results based on the given criteria
        placesResponse.results = placesResponse.results?.where((place) {
          final types = place.types ?? [];
          final isHinduTemple = types.contains('hindu_temple');
          final isPlaceOfWorship = types.contains('place_of_worship');

          return !isHinduTemple && isPlaceOfWorship;
        }).toList();

        // fetch images
        await fetchAndSetImageUrls(placesResponse.results);
        return placesResponse;
      } else {
        throw Exception(
            'Failed to fetch places. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch places: $e');
    }
  }

  Future<PlacesResponse> nearbySearch(String query, String lat, String lng,
      {String? nextPageToken}) async {
    placeController.lastFetchedApi = 'nearby'; //

    final url =
        '${apiBaseUrl}nearbysearch/json?location=$lat,$lng&radius=50000&types=$query&keyword=$query&key=$apitoken${nextPageToken != null ? '&pagetoken=$nextPageToken' : ''}';
    try {
      log(url);
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        PlacesResponse placesResponse = PlacesResponse.fromJson(response.data);

        // Filter the results based on the given criteria
        placesResponse.results = placesResponse.results?.where((place) {
          final types = place.types ?? [];
          final isHinduTemple = types.contains('hindu_temple');
          final isPlaceOfWorship = types.contains('place_of_worship');

          return !isHinduTemple && isPlaceOfWorship;
        }).toList();

        // fetch images
        await fetchAndSetImageUrls(placesResponse.results);
        return placesResponse;
      } else {
        throw Exception(
            'Failed to fetch places. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch places: $e');
    }
  }

  Future<String> getPhotoUrl(String photoReference,
      {int? maxWidth = 400}) async {
    final baseUrl = '${apiBaseUrl}photo';
    try {
      final response = await Dio().get(
        baseUrl,
        queryParameters: {
          'maxwidth': maxWidth,
          'photoreference': photoReference,
          'key': apitoken,
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      if (response.statusCode == 302) {
        return response.headers['location']!.first;
      } else {
        throw Exception('Failed to load photo');
      }
    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load photo');
    }
  }

  Future<void> fetchAndSetImageUrls(List<PlaceResult>? places) async {
    if (places == null) return;

    for (var place in places) {
      if (place.photos != null && place.photos!.isNotEmpty) {
        place.imageUrls = [];
        for (var photo in place.photos!) {
          try {
            String imageUrl = await getPhotoUrl(photo.photoReference!);
            place.imageUrls!.add(imageUrl);
          } catch (e) {
            log('Failed to fetch image URL: $e');
          }
        }
      }
    }
  }
}
