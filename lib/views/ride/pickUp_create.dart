import 'package:carpooling/views/ride/dropOff_create.dart';
import 'package:carpooling/widgets/main_navigator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class LocationSearchPage extends StatefulWidget {
  @override
  LocationSearchPageState createState() => LocationSearchPageState();
}

class LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  final String _apiKey = 'e80bab52-948d-4148-9f15-f56591cca16a'; // Replace with your Stadia Maps API key

  String? pickUpLocation; // to save the selected location

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

        final results = features
            .map((f) => f['properties']['label'] as String)
            .toList();

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

  void _onSuggestionTapped(String suggestion) {
    _controller.text = suggestion;
    pickUpLocation = suggestion;
    print(pickUpLocation);
    setState(() {
      _suggestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 60,),
            Row(
              children: [
                IconButton(onPressed: () {
                  Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainNavigator(),));
                }, icon: Icon(LucideIcons.arrowLeft, color: Colors.blue,)),
                Text('Pick-Up location',
                style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.blue,
            ),
                )
              ],
            ),
            SizedBox(height: 25,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                    hintText: 'Pick-up',
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)
                          ),
                    
                    onChanged: onTextChanged,
                    onSubmitted: (value) {
                      pickUpLocation = value;
                    },
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                   backgroundColor: Colors.blue,
                   foregroundColor: Colors.white,
                  elevation: 0,
                  
                  onPressed:
                      pickUpLocation != null
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SecondSearchPage(),
                              ),
                            );
                          }
                          : null,
                  child: Icon(LucideIcons.arrowRight),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            if (_suggestions.isNotEmpty)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_suggestions[index]),
                        onTap: () => _onSuggestionTapped(_suggestions[index]),
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
}
