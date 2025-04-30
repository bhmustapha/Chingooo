import 'package:carpooling/widgets/map.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class CreateRideMap extends StatefulWidget {
  const CreateRideMap({super.key});

  @override
  State<CreateRideMap> createState() => _CreateRideMapState();
}

class _CreateRideMapState extends State<CreateRideMap> {
  String? destination;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapPage(),
        Positioned(top: 20,child: IconButton(onPressed: () {Navigator.pushNamed(context, '/create');}, icon: Icon(LucideIcons.x))),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            height: 250,
            color: Colors.white,
            child: Column(
                children: [
                  if (destination != null)
                  Text(destination!)
                  

                ],
              ),
          ),
        ),
        
      ],
    );
  }
}
    