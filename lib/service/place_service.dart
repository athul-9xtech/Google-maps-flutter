import 'package:dio/dio.dart';
import 'package:google_map/model/places_model.dart';
import 'package:google_map/utils/constants.dart';

class PlaceService {
  final Dio dio = Dio();

  Future<PlacesResponse> fetchPlaces(String query,
      {String? countryCode}) async {
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
        '${apiBaseUrl}nearbysearch/json?location=$lat,$lng&radius=1000&types=$query&keyword=$query&key=$apitoken';
    try {
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
}