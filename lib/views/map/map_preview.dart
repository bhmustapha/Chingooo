import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPreviewPage extends StatefulWidget {
  final LatLng location;
  final String? placeName; // Optional: to display a friendly name for the location

  const LocationPreviewPage({
    super.key,
    required this.location,
    this.placeName,
  });

  @override
  State<LocationPreviewPage> createState() => _LocationPreviewPageState();
}

class _LocationPreviewPageState extends State<LocationPreviewPage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose(); // Dispose the controller when the state is removed
    super.dispose();
  }

  void _recenterMap() {
    _mapController.move(widget.location, 15); // Move to the initial location with zoom 15
  }

  @override
  Widget build(BuildContext context) {
    const Color markerColor = Colors.blue; // A neutral blue for general location
    const IconData markerIcon = Icons.location_on; // A general location pin icon

    return Scaffold(
      appBar: AppBar(title: const Text('Location Details')), // More general title
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // Assign the controller to the map
            options: MapOptions(
              initialCenter: widget.location,
              initialZoom: 15, // Zoom in a bit more for a single point
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.example.carpooling',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.location,
                    width: 40,
                    height: 40,
                    child: Icon(markerIcon, color: markerColor, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location:', // Generic label
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          markerIcon,
                          color: markerColor,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.placeName ??
                                'Latitude: ${widget.location.latitude.toStringAsFixed(4)}, Longitude: ${widget.location.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    if (widget.placeName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Coordinates: ${widget.location.latitude.toStringAsFixed(4)}, ${widget.location.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recenterMap,
        child: const Icon(Icons.my_location, color: Colors.blue),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}