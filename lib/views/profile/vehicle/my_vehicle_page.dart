import 'package:carpooling/views/profile/vehicle/add_vehicle_page.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:carpooling/models/vehicle.dart';
import 'package:carpooling/services/vehicle_service.dart';
import 'package:flutter_svg/svg.dart';

class MyVehiclesPage extends StatefulWidget {
  @override
  _MyVehiclesPageState createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  final VehicleService _vehicleService = VehicleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        centerTitle: true,
        elevation : 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddVehiclePage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: _vehicleService.getMyVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                
                  children: [
                    SvgPicture.asset(
                    'assets/images/my_car.svg',
                    width: 150,
                    height: 150,
                    ),
                  SizedBox(height: 15),
                    Text(
                      'You have no vehicles added yet.\nTap the + icon to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
            );
          }

          final vehicles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Show confirmation dialog before deleting
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: Text('Are you sure you want to delete ${vehicle.make} ${vehicle.model}?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirm == true) {
                                try {
                                  await _vehicleService.deleteVehicle(vehicle.id);
                                  showSuccessSnackbar(context, 'Vehicle deleted successfully!');
                                } catch (e) {
                                  showErrorSnackbar(context, 'Failed to delete vehicle: $e');
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('License Plate: ${vehicle.licensePlate}'),
                      Text('Color: ${vehicle.color}'),
                      Text('Capacity: ${vehicle.capacity} seats'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}