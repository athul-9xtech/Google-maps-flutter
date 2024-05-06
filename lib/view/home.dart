import 'dart:async';
import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_map/controller/location_controller.dart';
import 'package:google_map/controller/place_controller.dart';
import 'package:google_map/service/place_service.dart';
import 'package:google_map/view/widgets/places_listview.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final placeController = Get.put(PlaceController());
  final locationController = Get.put(LocationController());
  final searchController = TextEditingController();
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  bool isLocationFound = false;
  int selectedChip = 0;
  String? countryCode;
  String? selectedCountry;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> searchLocation(String query) async {
    isLocationFound = false;
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location firstLocation = locations.first;
        LatLng latLng = LatLng(firstLocation.latitude, firstLocation.longitude);
        // Move camera to the searched location
        _controller!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 12));
        // Add a marker at the searched location
        _addMarker(latLng, query);
        isLocationFound = true;
      }
    } catch (e) {
      //log('Error searching location: $e');
    }
  }

  void _addMarker(LatLng latLng, String title) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: latLng,
          infoWindow: InfoWindow(
            title: title,
          ),
        ),
      );
    });
  }

  void addMultipleMarker() {
    _markers.clear();
    for (var place in placeController.placesData!.results!) {
      _markers.add(
        Marker(
          markerId: MarkerId(place.name),
          position:
              LatLng(place.geometry.location.lat, place.geometry.location.lng),
          infoWindow: InfoWindow(
            title: place.name,
          ),
        ),
      );
    }
  }

  Future<void> findPlaces(String query, {String? countryCode}) async {
    isLoading.value = true;
    // find places
    placeController.placesData =
        await PlaceService().fetchPlaces(query, countryCode: countryCode);
    isLoading.value = false;

    addMultipleMarker();

    if (isLocationFound == false) _fitMarkersToBounds();
    setState(() {}); //todo -----------------------
  }

  void _fitMarkersToBounds() {
    if (_markers.isEmpty) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (Marker marker in _markers) {
      double lat = marker.position.latitude;
      double lng = marker.position.longitude;

      minLat = min(lat, minLat);
      maxLat = max(lat, maxLat);
      minLng = min(lng, minLng);
      maxLng = max(lng, maxLng);
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(
      bounds,
      100, // padding
    );
    _controller!.animateCamera(cameraUpdate);
  }

  Future<void> nearbyChipEvent() async {
    isLoading.value = true;
    await locationController.getCurrentPosition();
    if (locationController.currentPosition != null) {
      placeController.placesData = await PlaceService().nearbySearch(
        searchController.text.trim(),
        locationController.currentPosition!.latitude.toString(),
        locationController.currentPosition!.longitude.toString(),
      );
      addMultipleMarker();
      _fitMarkersToBounds();
      setState(() {});
    }
    isLoading.value = false;
  }

  InputChip _buildFilterChip(int buttonIdx, String label, bool isSelected) {
    return InputChip(
      selected: isSelected,
      label: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
      selectedColor: Colors.blue.shade100,
      side: BorderSide(color: Colors.grey.shade400),
      onPressed: () async {
        if (isSelected) {
          selectedChip = 0;
          countryCode = null;
          selectedCountry = null;
          await searchLocation(searchController.text.trim());
          findPlaces(searchController.text.trim());
        } else {
          if (buttonIdx == 1) {
            // nearby event
            nearbyChipEvent();
            final hasPermission =
                await locationController.handleLocationPermission();
            if (hasPermission) selectedChip = buttonIdx;
          } else {
            openCountryPicker(); // show country pick sheet
          }
        }
        placeController.update(['Filter-chips']);
      },
    );
  }

  void openCountryPicker() {
    showCountryPicker(
      context: context,
      useSafeArea: true,
      countryListTheme: CountryListThemeData(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: const TextStyle(height: 2.2),
        inputDecoration: countryPickerInputDecoration(),
      ),
      onSelect: (Country country) async {
        countryCode = country.countryCode;
        selectedCountry = country.displayNameNoCountryCode;
        selectedChip = 2;
        placeController.update(['Filter-chips']);
        await searchLocation(searchController.text.trim());
        findPlaces(searchController.text.trim(), countryCode: countryCode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              // -- search field --
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: searchController,
                  onChanged: (value) {
                    placeController.update(['Filter-chips']);
                  },
                  onFieldSubmitted: (value) async {
                    await searchLocation(value);
                    findPlaces(value);
                  },
                  decoration: _searchFieldDecoration(),
                ),
              ),

              // nearby and wordwide chips
              GetBuilder<PlaceController>(
                id: 'Filter-chips',
                builder: (controller) {
                  return Visibility(
                    visible: searchController.text.isNotEmpty &&
                        isLocationFound == false,
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        _buildFilterChip(1, 'Nearby', selectedChip == 1),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          2,
                          selectedCountry ?? 'Worldwide',
                          selectedChip == 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // --- Google Map ---
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    setState(() {
                      _controller = controller;
                    });
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(23.0225, 72.5714),
                    zoom: 12,
                  ),
                  markers: _markers,
                ),
              ),

              //* -- Places Listview --
              GetBuilder<PlaceController>(
                id: 'places-listview',
                builder: (controller) {
                  return PlacesListview(placeController: controller);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration countryPickerInputDecoration() {
    return InputDecoration(
      isDense: true,
      hintText: 'Search',
      prefixIcon: const Icon(CupertinoIcons.search, size: 21),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  InputDecoration _searchFieldDecoration() {
    return InputDecoration(
      isDense: true,
      hintText: 'Search',
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      suffixIcon: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, value, child) {
          return value
              ? Transform.scale(
                  scale: 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.grey.shade800,
                  ),
                )
              : InkWell(
                  onTap: () => searchLocation(searchController.text.trim()),
                  child: const Icon(CupertinoIcons.search, size: 21),
                );
        },
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
