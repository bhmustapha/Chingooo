import 'package:carpooling/views/ride/pickUp_create.dart'; // to use lat lng
import 'package:carpooling/views/ride/route_preview.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart'; // place mark function
import 'package:geolocator/geolocator.dart'; // get user's current location
import 'package:latlong2/latlong.dart';

class SecondSearchPage extends StatefulWidget {
  @override
  SecondSearchPageState createState() => SecondSearchPageState();
}

class SecondSearchPageState extends State<SecondSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  final String _apiKey = 'e80bab52-948d-4148-9f15-f56591cca16a';

  String? destinationLocation; // to save the selected location
  double? selectedLat; // save the selected Latitude
  double? selectedLon; // save the selected Longitude
  final FocusNode _focusNode = FocusNode();

  // to show loading till get the response from get Coordinate
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text.isEmpty) {
        _showCurrentLocationOnly();
      }
    });
  }

String _cleanLabel(String label) {
  return label
      .replaceAll(', Oran, Algeria', '')
      .replaceAll(', Algeria', '')
      .trim();
}

  Future<void> _showCurrentLocationOnly() async {
    final currentLocation = await _getCurrentLocationSuggestion();
    if (currentLocation != null) {
      setState(() {
        _suggestions = [currentLocation];
      });
    }
  }

  // Fetch suggestions from Stadia Maps Geocoding API
  Future<void> onTextChanged(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final url = Uri.parse(
      'https://api.stadiamaps.com/geocoding/v1/search?text=$input&api_key=$_apiKey'
      '&boundary.rect.min_lat=35.6645'
      '&boundary.rect.min_lon=-0.6974'
      '&boundary.rect.max_lat=35.7527'
      '&boundary.rect.max_lon=-0.5419' // limit the search in oran city only
      '&autocomplete=true',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        final results =
            features.map((f) {
              final props = f['properties'];
              final coords = f['geometry']['coordinates'];
              return {
                'label': _cleanLabel(props['label']),
                'lat': coords[1],
                'lon': coords[0],
              };
            }).toList();

        final currentLocationSuggestion = await _getCurrentLocationSuggestion();

        if (currentLocationSuggestion != null) {
          results.insert(0, currentLocationSuggestion); // Add to the top
        }

        setState(() {
          _suggestions = results;
        });
      } else {
        print('Failed to fetch suggestions: ${response.statusCode}');
        setState(() {
          _suggestions.clear();
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _suggestions.clear();
      });
    }
  }

  void _onSuggestionTapped(Map<String, dynamic> suggestion) {
    _controller.text = suggestion['label'];
    destinationLocation = suggestion['label'];
    selectedLat = suggestion['lat'];
    selectedLon = suggestion['lon'];
    setState(() {
      _suggestions.clear();
    });
  }

  // fonction to call geocoding api
  Future<void> _getCoordinatesFromAddress(String address) async {
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

        selectedLat = lat;
        selectedLon = lon;
        setState(() {});
      }
    }
  }

  Future<Map<String, dynamic>?> _getCurrentLocationSuggestion() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = _cleanLabel("${place.name}, ${place.locality}, ${place.country}");

        return {
          'label': address,
          'lat': position.latitude,
          'lon': position.longitude,
          'isCurrentLocation': true,
        };
      }
    } catch (e) {
      print("Failed to get current location: $e");
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 60),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationSearchPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.blue),
                ),
                Text(
                  'Drop-off location',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: 'Enter drop-off location',
                      labelStyle: TextStyle( fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),

                    onChanged: onTextChanged,
                    onSubmitted: (value) async {
                      setState(() {
                        _isLoading = true;
                      });
                      destinationLocation = value;
                      await _getCoordinatesFromAddress(
                        value,
                      ); // Wait for coordinates to be fetched
                      setState(() {
                        _isLoading = false;
                      });

                      if (selectedLat != null &&
                          selectedLon != null &&
                          selectedPickUpLat != null &&
                          selectedPickUpLon != null &&
                          destinationLocation != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RoutePreviewPage(
                                  pickUp: LatLng(
                                    selectedPickUpLat!,
                                    selectedPickUpLon!,
                                  ),
                                  dropOff: LatLng(selectedLat!, selectedLon!),
                                  pickUpName: pickUpLocation!,
                                  destinationName: destinationLocation!,
                                ),
                          ),
                        );
                      } else {
                        // show an error to the user
                        showErrorSnackbar(context, "Please enter a valid location");
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                _isLoading
                    ? CircularProgressIndicator(
                      color: Colors.blue,
                    ) // if loading show this
                    : FloatingActionButton(
                      // if not show this
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      onPressed: () async {
                        setState(() {
                          _isLoading =
                              true; // when we press then loading is true till getting the response
                        });
                        destinationLocation = _controller.text;
                        await _getCoordinatesFromAddress(_controller.text);
                        //after getting the response
                        setState(() {
                          // trun loading to false
                          _isLoading = false;
                        });
                        setState(() {});
                        if (selectedLat != null &&
                            selectedLon != null &&
                            selectedPickUpLat != null &&
                            selectedPickUpLon != null &&
                            destinationLocation != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RoutePreviewPage(
                                    pickUp: LatLng(
                                      selectedPickUpLat!,
                                      selectedPickUpLon!,
                                    ),
                                    dropOff: LatLng(selectedLat!, selectedLon!),
                                    pickUpName: pickUpLocation!,
                                    destinationName: destinationLocation!,
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please enter a valid location",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },

                      child: Icon(Icons.arrow_forward_ios_outlined),
                    ),
              ],
            ),
            const SizedBox(height: 10),
            if (_suggestions.isNotEmpty)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        leading:
                            suggestion['isCurrentLocation'] == true
                                ? Icon(Icons.my_location)
                                : Icon(Icons.location_on),
                        subtitle: suggestion['isCurrentLocation'] == true
                                ? Text('Current location')
                                :null,       
                        title: Text(suggestion['label']),
                        onTap: () => _onSuggestionTapped(suggestion),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
