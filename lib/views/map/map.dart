import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../home/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

List<Map<String, dynamic>> _suggestions = [];

class MapPage extends StatefulWidget {
  final VoidCallback?
  onRouteDrawn; // to notify the home page that the route is created
  const MapPage({super.key, this.onRouteDrawn});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  // loadingg
  bool _isLoading = true;
  // getter for the _suggestoions
  List<Map<String, dynamic>> get currentSuggestions => _suggestions;
  //getter for the destination point
  LatLng? get selectedDestination =>
    markers.isNotEmpty ? markers.first.point : null;
  // getter for the _currentLocation
  LatLng? get currentLocation => _currentLocation;


  final MapController _mapController = MapController();
  LatLng? _currentLocation; // user current location (latlng is the type)

  List<Marker> markers = []; // list of markers (current + destination)
  List<LatLng> routePoints = []; // to draw the polyline in the map

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // initial state of the map is the current loc
  }

  void centerPosition() {
    _mapController.move(
      _currentLocation!,
      15.0,
    ); // move the map to the current loc ( for the button )
  }

  void clearSuggestions() {
    setState(() {
      _suggestions = []; // clear sugg when tap
    });
  }

  void onSuggestionTap(Map<String, dynamic> suggestion) async {
    setState(() => _isLoading = true); // Start loading
    final lat = suggestion['lat'];
    final lon = suggestion['lon'];
    final name = suggestion['name']; // set the suggestion map

    LatLng location = LatLng(lat, lon); // get the location

    //_mapController.move(location, 15.0);

    try {
      // Call getRoute to draw the route from current location to suggestion
      final route = await getRoute(_currentLocation!, location);

      setState(() {
        // Set the route points to draw the polyline
        routePoints = route;

        markers.clear(); // Clear previous markers
        // Add new marker for the selected suggestion
        markers.add(
          Marker(
            point: location,
            width: 60,
            height: 60,
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                color: Colors.blue[700],
                size: 45,
              ),
            ),
          ),
        );
      });
      widget.onRouteDrawn?.call();
      _suggestions = [];
      // Calculate the bounds of the route (from current location to destination)
      final bounds = LatLngBounds(
        _currentLocation!, // Start location
        location, // End location
      );
      _mapController.move(bounds.center, 11.5);
    } catch (e) {
      // Handle error (ex: no route found)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get route: $e')));
    } finally {
      setState(() => _isLoading = false); // Stop loading
    }

    setState(() {
      _suggestions = []; // Clear suggestions after tapping
      searchController.text =
          name; // Update search text field with the suggestion name
    });
    // Hide the keyboard when a suggestion is tapped
    FocusScope.of(context).unfocus();
  }

  // function to draw the route
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
      '?api_key=5b3ce3597851110001cf62489839c0fa729b43278c806b8b3197872e' // api key from open route
      '&start=${start.longitude},${start.latitude}'
      '&end=${end.longitude},${end.latitude}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // no errors
      final data = jsonDecode(response.body);
      final List<dynamic> coordinates =
          data['features'][0]['geometry']['coordinates'];

      // Convert coordinates to LatLng
      return coordinates
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true); // loading before getting permission
    LocationPermission permission =
        await Geolocator.requestPermission(); // user's permission to use the location
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false); // Stop loading on fail
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    LatLng userLocation = LatLng(
      position.latitude,
      position.longitude,
    ); // get the lat,long of user location

    setState(() {
      _currentLocation = userLocation; // set the current location
      _isLoading = false; // Stop loading when done
    });

    _mapController.move(userLocation, 15.0); // move the map there
  }

  // fonction to call geocoding api
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    final url = Uri.parse(
      'https://api.stadiamaps.com/geocoding/v1/search?text=${Uri.encodeComponent(address)}'
      '&api_key=e80bab52-948d-4148-9f15-f56591cca16a' // api key
      '&boundary.rect.min_lat=35.6645'
      '&boundary.rect.min_lon=-0.6974'
      '&boundary.rect.max_lat=35.7527' // limitted search for ORAN
      '&boundary.rect.max_lon=-0.5419'
      '&autocomplete=true', // auto complete the ser input
    );

    final response = await http.get(url); // send an http get request nd wait

    if (response.statusCode == 200) {
      // 200 means its ok , no errors
      final data = jsonDecode(
        response.body,
      ); // response.body = thee text of the server's answer (JSON format) / jsondecode to turns  that into dart map or list (easy to work with)
      if (data['features'].isNotEmpty) {
        final coords =
            data['features'][0]['geometry']['coordinates']; // the &st feature + geometry nd coordinates
        double lon = coords[0]; // the server gives lon first then lat
        double lat = coords[1];
        return LatLng(lat, lon); // but the latlng takes lat first then lon
      }
    }
    return null;
  }

  // Function to search and navigate to searched place
  void searchAndNavigate() async {
    final query = searchController.text;
    if (query.isEmpty) return; 
    setState(() => _isLoading = true); // Start loading

    final LatLng? location = await _getCoordinatesFromAddress(
      query,
    ); // get coordinate of the typed place
    if (location != null && _currentLocation != null) {
      // if it exist
      final route = await getRoute(_currentLocation!, location);
      setState(() {
        //set route points to draw the line
        routePoints = route;
        //clear the old markers
        markers.clear();
        // Add a new marker for search result
        markers.add(
          Marker(
            rotate: true,
            point: location,
            width: 60,
            height: 60,
            child: IgnorePointer(
              child: Icon(Icons.location_pin, color: Colors.blue, size: 45),
            ),
          ),
        );
        widget.onRouteDrawn?.call();
        final bounds = LatLngBounds(
          _currentLocation!, // Start location
          location, // End location
        );
        _mapController.move(bounds.center, 11.5);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found!')),
      ); // shwo small error message in the bottom
    }
    setState(() => _isLoading = false); // Stop loading
  }

  Future<List<Map<String, dynamic>>> fetchSuggestions(String query) async {
  if (query.isEmpty) {
    setState(() {
      _suggestions = [];
    });
    return []; // return empty list instead of void
  }
  final url = Uri.parse(
    'https://api.stadiamaps.com/geocoding/v1/search?text=${Uri.encodeComponent(query)}' // get the locations that match the query
    '&api_key=e80bab52-948d-4148-9f15-f56591cca16a'
    '&boundary.rect.min_lat=35.6645'
    '&boundary.rect.min_lon=-0.6974'
    '&boundary.rect.max_lat=35.7527'
    '&boundary.rect.max_lon=-0.5419' // limit the search in oran city only
    '&autocomplete=true',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final suggestionsList = data['features'].map<Map<String, dynamic>>((feature) {
      final coords = feature['geometry']['coordinates'];
      return {
        'name': feature['properties']['label'],
        'lat': coords[1],
        'lon': coords[0],
      };
    }).toList();

    setState(() {
      _suggestions = suggestionsList;
    });

    return suggestionsList;  // Return the suggestions list here
  }

  return []; // return empty list if request fails
}


  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Select the tile layer URL based on the theme
    final tileLayerUrl =
        isDark
            ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=e80bab52-948d-4148-9f15-f56591cca16a'
            : 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=e80bab52-948d-4148-9f15-f56591cca16a'; // get the current theme

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation ?? LatLng(0, 0),
            initialZoom: 20.0,
          ),
          children: [
            TileLayer(
              urlTemplate: tileLayerUrl,
              userAgentPackageName: 'com.example.carpooling',
            ),
            PolylineLayer(
              polylines: [
                if (routePoints.isNotEmpty)
                  Polyline(
                    points: routePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
              ],
            ),
            if (!_isLoading)
            MarkerLayer(
              markers: [
                Marker(
                  rotate: true,
                  point: _currentLocation ?? LatLng(0, 0),
                  width: 60,
                  height: 60,
                  child: IgnorePointer(
                    // invisible to all actions like tap or drag...
                    child: Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 45,
                    ),
                  ),
                ),
                ...markers,
              ],
            ),
          ],
        ),
        if (_isLoading) // Show loader
        Positioned.fill(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.blue
              ),
            ),
          ),
        ),
      ],
    );
  }
}
