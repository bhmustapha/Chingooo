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
  final ValueNotifier<bool> menuOpenNotifier = ValueNotifier<bool>(false);   // track the satet of menu over files
  @override
    void dispose() {
    menuOpenNotifier.dispose();
    super.dispose();
  }
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
                          borderRadius: BorderRadius.circular(30),
                          elevation: 6,
                          child:Material(

                            child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    LucideIcons.search,
                                    color: Colors.grey,
                                    ),
                                  hintText: 'Votre destination',
                            
                                  
                                  )
                                
                              ),
                          ),
                          ),
                        ),
                      
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
      