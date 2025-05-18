import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class RoutePreviewPage extends StatefulWidget {
  final LatLng pickUp;
  final LatLng dropOff;
  final String destinationName;

  RoutePreviewPage({
    required this.pickUp,
    required this.dropOff,
    required this.destinationName,
  });

  @override
  _RoutePreviewPageState createState() => _RoutePreviewPageState();
}

class _RoutePreviewPageState extends State<RoutePreviewPage> {
  final MapController _mapController = MapController();
  List<LatLng> routePoints = [];
  double? distanceKm;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final String apiKey = 'e80bab52-948d-4148-9f15-f56591cca16a';
  final String routeApiKey =
      '5b3ce3597851110001cf62489839c0fa729b43278c806b8b3197872e';
  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder:  (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue,        // selected day circle + header bg
            onPrimary: Colors.white,     // text inside selected day circle
            onSurface: Colors.black,     // default day text
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.blue), // OK / Cancel buttons
          ),
        ),
        child: child!,
      );
    },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Colors.white,
            hourMinuteTextColor: Colors.white,
            hourMinuteColor: Colors.blue,
            dayPeriodTextColor: Colors.white,
            dayPeriodColor: Colors.blue,
            dialHandColor: Colors.blue,
            dialBackgroundColor: Colors.blueAccent,
            dialTextColor: Colors.white,
            entryModeIconColor: Colors.blue,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.blue), // OK/CANCEL buttons
          ),
        ),
        child: child!,
      );
      }
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _fetchRoute() async {
    final start = widget.pickUp;
    final end = widget.dropOff;

    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
      '?api_key=$routeApiKey'
      '&start=${start.longitude},${start.latitude}'
      '&end=${end.longitude},${end.latitude}',
    );

    try {
      final response = await http.get(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'];
        final distance =
            data['features'][0]['properties']['segments'][0]['distance'];

        setState(() {
          routePoints =
              coords
                  .map<LatLng>((point) => LatLng(point[1], point[0]))
                  .toList();
          distanceKm = distance / 1000;
          final bounds = LatLngBounds(
            start, // Start location
            end, // End location
          );
          _mapController.move(bounds.center, 11.5);
        });
      } else {
        print('Failed to fetch route data.');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.pickUp,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$apiKey',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.pickUp,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_on, color: Colors.blue),
                  ),
                  Marker(
                    point: widget.dropOff,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_on, color: Colors.red),
                  ),
                ],
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(LucideIcons.arrowLeft, color: Colors.blue),
            ),
          ),

          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.destinationName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (distanceKm != null)
                    Text(
                      'Distance: ${distanceKm!.toStringAsFixed(2)} km',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              selectedDate != null
                                  ? '${selectedDate!.toLocal()}'.split(' ')[0]
                                  : 'Select Date',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              selectedTime != null
                                  ? selectedTime!.format(context)
                                  : 'Select Time',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Add confirmation logic
                        print(
                          'Confirm Ride: $selectedDate at ${selectedTime?.format(context)}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Confirm Ride',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
