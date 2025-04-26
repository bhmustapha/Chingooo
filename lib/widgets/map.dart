import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void centerPosition() {
    _mapController.move(_currentLocation!, 15.0);
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng userLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocation = userLocation;
    });

    _mapController.move(userLocation, 15.0);
  }



  @override
  Widget build(BuildContext context) {
    return  FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation ?? LatLng(0, 0),
          initialZoom: 15.0,
          
          
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=e80bab52-948d-4148-9f15-f56591cca16a",
            userAgentPackageName: 'com.example.carpooling',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation ?? LatLng(0, 0),
                width: 60,
                height: 60,
                child: IgnorePointer(
                  child: Icon(Icons.location_on, color: Colors.blue, size: 45),
                ),
              ),
            ],
          ),
        ],
      );
    
  }
}
