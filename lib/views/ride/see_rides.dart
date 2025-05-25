import 'package:carpooling/themes/costum_reusable.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeeRidesPage extends StatefulWidget {
  final String destinationLocation;
  final LatLng? initialPickupLocation;
  final Future<List<Map<String, dynamic>>> Function(String)
  fetchSuggestionsCallback;

  SeeRidesPage({
    required this.destinationLocation,
    required this.fetchSuggestionsCallback,
    this.initialPickupLocation,
    super.key,
  });

  @override
  State<SeeRidesPage> createState() => _SeeRidesPageState();
}

class _SeeRidesPageState extends State<SeeRidesPage> {
  late TextEditingController pickupController;
  List<Map<String, dynamic>> suggestions = [];
  LatLng? selectedPickupCoords;

  @override
  void initState() {
    super.initState();
    pickupController = TextEditingController(
      text: widget.initialPickupLocation != null ? "Current Location" : '',
    );
    selectedPickupCoords = widget.initialPickupLocation;
  }

  @override
  void dispose() {
    pickupController.dispose();
    super.dispose();
  }

  void onPickupChanged(String input) async {
    if (input.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }
    final fetchedSuggestions = await widget.fetchSuggestionsCallback(input);
    setState(() {
      suggestions = fetchedSuggestions;
    });
  }

  void onSuggestionSelected(Map<String, dynamic> suggestion) {
    setState(() {
      pickupController.text = suggestion['name'];
      selectedPickupCoords = LatLng(suggestion['lat'], suggestion['lon']);
      suggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  void showRequestRideBottomSheet() {
    DateTime selectedDateTime = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 6,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Text('Request Ride', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    Text('Destination:'),
                    SizedBox(height: 5),
                    Text(
                      widget.destinationLocation,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Pickup Location:'),
                    SizedBox(height: 5),
                    TextField(
                      controller: pickupController,
                      decoration: InputDecoration(
                        hintText: 'Search pickup location',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        border: roundedInputBorder(14.0),
                        enabledBorder: roundedInputBorder(14.0),
                        focusedBorder: roundedInputBorder(14.0),
                      ),
                      onChanged: (value) {
                        onPickupChanged(value);
                        setSheetState(() {});
                      },
                    ),

                    if (suggestions.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return ListTile(
                            title: Text(suggestion['name']),
                            onTap: () {
                              onSuggestionSelected(suggestion);
                              setSheetState(() {});
                            },
                          );
                        },
                      ),
                    SizedBox(height: 20),
                    Text('Date & Time:'),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDateTime,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  Duration(days: 365),
                                ),
                              );
                              if (date == null) return;
                              setSheetState(() {
                                selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  selectedDateTime.hour,
                                  selectedDateTime.minute,
                                );
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2, '0')}-${selectedDateTime.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  selectedDateTime,
                                ),
                              );
                              if (time == null) return;
                              setSheetState(() {
                                selectedDateTime = DateTime(
                                  selectedDateTime.year,
                                  selectedDateTime.month,
                                  selectedDateTime.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 12),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            String pickupName = pickupController.text;
                            String destination = widget.destinationLocation;
                            String datetimeStr =
                                '${selectedDateTime.toLocal()}'.split('.')[0];

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ride requested:\nFrom: $pickupName\nTo: $destination\nAt: $datetimeStr',
                                ),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          },
                          child: Text('Request'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: Text('no available rides!')),
          Positioned(
            top: 30,
            left: 14,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(LucideIcons.arrowLeft),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    fixedSize: Size(270, 55),
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: showRequestRideBottomSheet,
                  child: Text(
                    'Post a ride request',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
