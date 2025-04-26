import 'package:carpooling/widgets/toggle_menu.dart';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';    // for the map
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../widgets/map.dart';
import '../../widgets/navigation_bar.dart';

final GlobalKey<MapPageState> _mapKey = GlobalKey<MapPageState>(); // nametag to pin map widget
// cpntroller of the search input
final TextEditingController searchController = TextEditingController();


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override



  Widget build(BuildContext context) {
    return  Stack(
          children: [
            Positioned.fill(
              child: MapPage(
                 key: _mapKey,
                 
              ),
              ),

              Positioned(
                top: 30,
                left: 15,
                right: 15,
                child: Container(
                  height: 55,
                  width: double.infinity,
                  child: Row(
                    children: [
                      ToggleMenu(),
                      SizedBox(width: 10) ,// little spacing
                      Expanded(
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(30),
                          child:  Container(
                            height: 55,
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                _mapKey.currentState?.fetchSuggestions(value);
                                setState(() {});
                              },
                              onSubmitted: (value) {
                                _mapKey.currentState?.searchAndNavigate(); // move map and add marker
                                _mapKey.currentState?.clearSuggestions(); // clear suggestions
                              },
                                decoration: InputDecoration(
                                  hintText: 'Votre destination ?',
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
                                )
                                ),
                              ),
                          ),
                          ),
                        )
                          
                        
                      
                    ],
                        ),
                ),
              ),
              Positioned(
                  top: 90, // just under search bar
                  left: 15,
                  right: 15,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      final currentSuggestions = _mapKey.currentState?.currentSuggestions ?? [];
                      if (currentSuggestions.isEmpty) {
                        return Container();
                      }
                      return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _mapKey.currentState?.currentSuggestions.length ?? 0,
                      itemBuilder: (context, index) {
                      final suggestion = _mapKey.currentState!.currentSuggestions[index];
                        return ListTile(
                          title: Text(
                            suggestion['name'],
                            style: Theme.of(context).textTheme.bodySmall
                            ),
                          onTap: () {
                            _mapKey.currentState?.onSuggestionTap(suggestion);
                            suggestions.clear(); // clear the list
                            setState(() {}); // refresh the ui
                          },
                        );
                      },
                    ),
                  );
                }
              )
                  
              ),
        
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                  onPressed: () {
        
                    _mapKey.currentState?.centerPosition();
                  },
                  child: Icon(
                    LucideIcons.locate
                   
        
                  ),
                  )
              )
            ],
            );
  }}
      