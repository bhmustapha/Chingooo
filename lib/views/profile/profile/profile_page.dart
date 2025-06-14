import 'package:carpooling/views/profile/profile/edit_profile.dart';
import 'package:carpooling/views/profile/profile/history_page.dart';
import 'package:carpooling/views/profile/profile/my_rating.dart';
import 'package:carpooling/views/profile/vehicle/my_vehicle_page.dart';
import 'package:carpooling/views/ride/my_requested_rides.dart';
import 'package:carpooling/views/ride/my_rides.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../components/container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userData = doc.data();
      });
    }
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          userData == null
              ? Center(child: CircularProgressIndicator(color: Colors.blue))
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Profile',
                      // use theme for title
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: GreyContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: _getColorFromName(
                                  userData!['name'],
                                ),
                                child: Text(
                                  userData!['name'][0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  userData!['name'] ?? 'Unknown',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              if (userData!['averageRating'] != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyRatingsPage()));
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          userData!['averageRating'].toStringAsFixed(
                                            1,
                                          ), // Display rating with one decimal place
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: GreyContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Date de naissance',
                                userData!['birthdate'] ?? 'dd/mm/yyyy',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Email',
                                userData!['email'] ?? 'no email',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Numero de téléphone',
                                userData!['phone'] ?? 'xxxx xxx xxx',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.drive_eta, color: Colors.blue),
                              label: Text("My Rides "),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriverRidesPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.hail, color: Colors.green),
                              label: Text("My Ride Requests"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RideRequestsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.car_rental,
                                color: Colors.orange,
                              ),
                              label: Text("My Vehicles"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyVehiclesPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HistoryPage(),
                                  ),
                                );
                              },
                              label: Text('History'),
                              icon: Icon(LucideIcons.history),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(),
                                  ),
                                );
                                if (result == true) {
                                  _loadUserData();
                                }
                              },
                              label: Text('Edit'),
                              icon: Icon(Icons.edit),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.red.shade200,
      Colors.green.shade200,
      Colors.blue.shade200,
      Colors.orange.shade200,
      Colors.purple.shade200,
      Colors.teal.shade200,
      Colors.brown.shade200,
    ];
    final index =
        name.codeUnitAt(0) %
        colors
            .length; //This gets the Unicode code unit (an integer) of the first character in the string name ex: Bob => B= 66
    return colors[index]; // mraha yutilisi modulo ex: 66 mod 7 =3
  }
}
