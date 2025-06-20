import 'package:carpooling/main.dart';
import 'package:carpooling/views/ride/see_rides.dart';
import 'package:carpooling/widgets/toggle_menu.dart'; // menu
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../map/map.dart'; // the map

final GlobalKey<MapPageState> _mapKey =
    GlobalKey<MapPageState>(); // nametag to pin map widget
// controller of the search input
final TextEditingController searchController = TextEditingController();

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double? routeDistance;
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: MapPage(
            key: _mapKey,
            onRouteDrawn: () {
              setState(() {});
            },
            onDistanceCalculated: (distance) {
              setState(() {
                routeDistance = distance;
              });
            },
          ),
        ), // the map
        Positioned(
          top: 30,
          left: 15,
          right: 15,
          child: Container(
            // to set a height
            height: 55,
            width: double.infinity,
            child: Row(
              // menu button + search bar
              children: [
                ToggleMenu(), // menu
                SizedBox(width: 10), // little spacing
                Expanded(
                  child: Material(
                    // for the elevation + the borders
                    elevation: 6,
                    borderRadius: BorderRadius.circular(30),
                    child: TextField(
                      // search bar
                      controller: searchController,
                      onChanged: (value) {
                        _mapKey.currentState?.fetchSuggestions(
                          value,
                        ); // shwo the suggestions
                        setState(() {}); // refresh the page to show new content
                      },
                      onSubmitted: (value) {
                        _mapKey.currentState
                            ?.searchAndNavigate(); // move map and add marker
                        _mapKey.currentState
                            ?.clearSuggestions(); // clear suggestions
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        // button to clear the text
                        suffixIcon:
                            searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(LucideIcons.x, color: Colors.grey),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      _mapKey.currentState?.routePoints.clear();
                                      _mapKey.currentState?.markers.clear();
                                      _mapKey.currentState?.clearSuggestions();
                                    });
                                  },
                                )
                                : null, // so show 'x' only when there is text
                        hintText: 'Where are you going ?',
                        prefixIcon: Icon(LucideIcons.search),
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 90, // just under search bar
          left: 15,
          right: 15,
          child: StatefulBuilder(
            // the state will change
            builder: (context, setState) {
              final currentSuggestions =
                  _mapKey.currentState?.currentSuggestions ?? [];
              if (currentSuggestions.isEmpty) {
                return Container(); // invisible container ( if empty )
              }
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  color:
                      themeNotifier.value == ThemeMode.light
                          ? Colors.white
                          : Colors.grey[900],
                ),
                child: ListView.builder(
                  shrinkWrap: true, // take space only to fit it content
                  itemCount:
                      _mapKey.currentState?.currentSuggestions.length ?? 0,
                  itemBuilder: (context, index) {
                    final suggestion =
                        _mapKey.currentState!.currentSuggestions[index];
                    return ListTile(
                      title: Text(
                        suggestion['name'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        _mapKey.currentState?.onSuggestionTap(suggestion);
                        _mapKey.currentState
                            ?.clearSuggestions(); // clear the list
                        setState(() {});
                        // refresh the ui
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Row(
            children: [
              Visibility(
                visible: _mapKey.currentState?.routePoints.isNotEmpty ?? false,
                child:  TextButton(
                  
                    style: TextButton.styleFrom(
                      fixedSize: Size(200, 50),
                      backgroundColor: const Color.fromARGB(255, 33, 150, 243),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final destinationLatLon = _mapKey.currentState?.destinationLocation;
                      if (destinationLatLon != null) {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SeeRidesPage(
                                destinationLocation: searchController.text,
                                initialPickupLocation:
                                    _mapKey.currentState?.currentLocation,
                                fetchSuggestionsCallback:
                                    (input) => _mapKey.currentState!
                                        .fetchSuggestions(input),
                                distanceInKm: routeDistance!/1000 ,
                                destinationCoords: destinationLatLon,
                              ),
                        ),
                      );
                      }
                      
                    },
                    child: Text('See rides'),
                  ),
                ),
              
              SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () {
                  _mapKey.currentState
                      ?.centerPosition(); // go to user current location
                },
                child: Icon(LucideIcons.locate),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
