import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map/utils/app_colors.dart';
import 'package:google_map/view/map_screen/widgets/place_details.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map/model/places_model.dart' as place_model;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.place});

  final place_model.PlaceResult place;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};

  void findLocation() {
    LatLng latLng = LatLng(
      widget.place.geometry.location.lat,
      widget.place.geometry.location.lng,
    );
    // Move camera to the location
    _controller!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 12));
    // Add a marker at the finded location
    _addMarker(latLng, widget.place.name);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors().darkOrange,
            size: 20,
          ),
        ),
        title: Text(
          widget.place.name,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  _controller = controller;
                  findLocation();
                });
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(23.0225, 72.5714),
                zoom: 12,
              ),
              markers: _markers,
            ),
          ),

          //* -- Places Details Section --
          PlaceDetailsWidget(place: widget.place),
        ],
      ),
    );
  }
}
