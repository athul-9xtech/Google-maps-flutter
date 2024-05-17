import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:google_map/model/places_model.dart';
import 'package:google_map/utils/constants.dart';

class PlaceService {
  final Dio dio = Dio();

  Future<PlacesResponse> fetchPlaces(String query,
      {String? countryCode, String? state, String? city}) async {
    if (city != null) {
      query += city;
    } else if (state != null) {
      query += state;
    }
    final url = '${apiBaseUrl}textsearch/json?query=$query&key=$apitoken';

    try {
      final response = await dio.get(
        url,
        queryParameters: countryCode != null ? {'region': countryCode} : null,
      );

      if (response.statusCode == 200) {
        return PlacesResponse.fromJson(response.data);
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
    final url =
        '${apiBaseUrl}nearbysearch/json?location=$lat,$lng&radius=50000&types=$query&keyword=$query&key=$apitoken';
    try {
      log(url);
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return PlacesResponse.fromJson(response.data);
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
}
