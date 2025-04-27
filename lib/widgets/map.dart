import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../views/home/home_page.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../views/ride/create_ride.dart';
List<Map<String, dynamic>> suggestions = [];
class MapPage extends StatefulWidget {
// Callback for suggestion tap

  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
List<Map<String, dynamic>> get currentSuggestions => suggestions;

final MapController _mapController = MapController();
LatLng? _currentLocation;

  // markers [current + destination]
  List<Marker> _markers = [];
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void centerPosition() {
     _mapController.move(
      _currentLocation!,
       15.0,);


  }

  void clearSuggestions() {
  setState(() {
    suggestions = [];
  });
}

  void onSuggestionTap(Map<String, dynamic> suggestion) {
  final lat = suggestion['lat'];
  final lon = suggestion['lon'];
  final name = suggestion['name'];

  LatLng location = LatLng(lat, lon);

  _mapController.move(location, 15.0);

  setState(() {
    suggestions = []; // Clear suggestions
    _markers.clear();
    _markers.add(
      Marker(
        point: location,
        width: 60,
        height: 60,
        child: IgnorePointer(
          child: Icon(Icons.location_pin, color: Colors.red, size: 45),
        ),
      ),
    );
    searchController.text = name; // Update search field
  });
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

  // fonction to call geocoding api
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    
  final url = Uri.parse(
  'https://api.stadiamaps.com/geocoding/v1/search?text=${Uri.encodeComponent(address)}'
    '&api_key=e80bab52-948d-4148-9f15-f56591cca16a'
    '&boundary.rect.min_lat=35.6645'
    '&boundary.rect.min_lon=-0.6974'
    '&boundary.rect.max_lat=35.7527'// limitted search for ORAN
    '&boundary.rect.max_lon=-0.5419'
    '&autocomplete=true'
);

    
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['features'].isNotEmpty) {
        final coords = data['features'][0]['geometry']['coordinates'];
        double lon = coords[0];
        double lat = coords[1];
        return LatLng(lat, lon);
      }
    }
    return null;   
  }

  // Function to search and navigate to searched place
  void searchAndNavigate() async {
   // Get text from both controllers
  final query1 = searchController.text;
  final query2 = createSearchController.text; 
  // choose which one is not empty
  final query = query1.isNotEmpty ? query1 : query2;
  
    if (query.isEmpty) return;

    final LatLng? location = await _getCoordinatesFromAddress(query);
    if (location != null) {
      _mapController.move(location, 15.0); // zoom to searched location
      
      setState(() {
        //clear the old markers
        _markers.clear();
        // Add a new marker for search result
        _markers.add(
          Marker(
            point: location,
            width: 60,
            height: 60,
            child: IgnorePointer(
              child: Icon(Icons.location_pin, color: Colors.red, size: 45),
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found!')),
      );
    }
  } 

  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }
    final url = Uri.parse(
    'https://api.stadiamaps.com/geocoding/v1/search?text=${Uri.encodeComponent(query)}'
    '&api_key=e80bab52-948d-4148-9f15-f56591cca16a'
    '&boundary.rect.min_lat=35.6645'
    '&boundary.rect.min_lon=-0.6974'
    '&boundary.rect.max_lat=35.7527'
    '&boundary.rect.max_lon=-0.5419'
    '&autocomplete=true'
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    setState(() {
      suggestions = data['features'].map<Map<String, dynamic>>((feature) {
        final coords = feature['geometry']['coordinates'];
        return {
          'name': feature['properties']['label'], 
          'lat': coords[1],
          'lon': coords[0],
        };
      }).toList();
    });
  }
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
              ..._markers,
            ],
          ),
        ],
      );
    
  }
}
