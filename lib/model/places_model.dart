class PlacesResponse {
  String? nextPageToken;
  final List<PlaceResult>? results;

  PlacesResponse({this.nextPageToken, required this.results});

  factory PlacesResponse.fromJson(Map<String, dynamic> json) {
    return PlacesResponse(
      nextPageToken: json['next_page_token'],
      results: (json['results'] as List)
          .map((result) => PlaceResult.fromJson(result))
          .toList(),
    );
  }
}

class PlaceResult {
  final String? businessStatus;
  final String? formattedAddress;
  final Geometry geometry;
  final String? icon;
  final String? iconBackgroundColor;
  final String? iconMaskBaseUri;
  final String name;
  final OpeningHours? openingHours;
  final List<Photos>? photos;
  final String placeId;
  final PlusCode? plusCode;
  final double? rating;
  final String reference;
  final List<String>? types;
  final int? userRatingsTotal;

  PlaceResult({
    this.businessStatus,
    this.formattedAddress,
    required this.geometry,
    this.icon,
    this.iconBackgroundColor,
    this.iconMaskBaseUri,
    required this.name,
    this.openingHours,
    this.photos,
    required this.placeId,
    this.plusCode,
    this.rating,
    required this.reference,
    this.types,
    this.userRatingsTotal,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      businessStatus: json['business_status'],
      formattedAddress: json['formatted_address'],
      geometry: Geometry.fromJson(json['geometry']),
      icon: json['icon'],
      iconBackgroundColor: json['icon_background_color'],
      iconMaskBaseUri: json['icon_mask_base_uri'],
      name: json['name'],
      openingHours: json['opening_hours'] != null
          ? OpeningHours.fromJson(json['opening_hours'])
          : null,
      photos: json['photos'] != null
          ? (json['photos'] as List)
              .map((photo) => Photos.fromJson(photo))
              .toList()
          : null,
      placeId: json['place_id'],
      plusCode: json['plus_code'] != null
          ? PlusCode.fromJson(json['plus_code'])
          : null,
      rating: json['rating']?.toDouble(),
      reference: json['reference'],
      types: json['types'] != null ? List<String>.from(json['types']) : null,
      userRatingsTotal: json['user_ratings_total'],
    );
  }
}

class Geometry {
  final Location location;
  final Viewport viewport;

  Geometry({required this.location, required this.viewport});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: Location.fromJson(json['location']),
      viewport: Viewport.fromJson(json['viewport']),
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class Viewport {
  final LatLng northeast;
  final LatLng southwest;

  Viewport({required this.northeast, required this.southwest});

  factory Viewport.fromJson(Map<String, dynamic> json) {
    return Viewport(
      northeast: LatLng.fromJson(json['northeast']),
      southwest: LatLng.fromJson(json['southwest']),
    );
  }
}

class LatLng {
  final double lat;
  final double lng;

  LatLng({required this.lat, required this.lng});

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class OpeningHours {
  final bool? openNow;

  OpeningHours({required this.openNow});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      openNow: json['open_now'],
    );
  }
}

class Photos {
  final int? height;
  final List<dynamic>? htmlAttributions;
  final String? photoReference;
  final int? width;

  Photos({this.height, this.htmlAttributions, this.photoReference, this.width});

  factory Photos.fromJson(Map<String, dynamic> json) {
    return Photos(
      height: json['height'],
      htmlAttributions: json['html_attributions'],
      photoReference: json['photo_reference'],
      width: json['width'],
    );
  }
}

class PlusCode {
  final String? compoundCode;
  final String? globalCode;

  PlusCode({this.compoundCode, this.globalCode});

  factory PlusCode.fromJson(Map<String, dynamic> json) {
    return PlusCode(
      compoundCode: json['compound_code'],
      globalCode: json['global_code'],
    );
  }
}
