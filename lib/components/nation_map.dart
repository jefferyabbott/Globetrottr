import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NationMap extends StatelessWidget {
  final dynamic lat;
  final dynamic lon;
  final double zoom;

  NationMap(
      {super.key, required this.lat, required this.lon, required this.zoom});

  late final GoogleMapController mapController;

  late final LatLng _center = LatLng(lat, lon);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: zoom,
      ),
    );
  }
}
