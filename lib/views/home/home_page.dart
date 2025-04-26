import 'package:carpooling/widgets/toggle_menu.dart';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';    // for the map
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../widgets/map.dart';
import '../../widgets/navigation_bar.dart';

final GlobalKey<MapPageState> _mapKey = GlobalKey<MapPageState>(); // nametag to pin map widget
  // track the satet of menu over files


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  MapController  mapController = MapController();

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
      