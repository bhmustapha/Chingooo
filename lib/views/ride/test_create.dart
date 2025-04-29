import 'package:carpooling/widgets/map.dart';
import 'package:flutter/material.dart';


class CreateRideMap extends StatefulWidget {
  const CreateRideMap({super.key});

  @override
  State<CreateRideMap> createState() => _CreateRideMapState();
}

class _CreateRideMapState extends State<CreateRideMap> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MapPage(),
        Container(
          
          child: Column(),
        )
      ],
    );
  }
}
    