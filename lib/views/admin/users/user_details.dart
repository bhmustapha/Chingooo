import 'package:carpooling/views/admin/users/edit_user.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  // Method to toggle user status (e.g., active/suspended)
  Future<void> _toggleUserStatus(String currentStatus) async {
    String newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'status': newStatus,
      });
      showSuccessSnackbar(context, 'User status updated to $newStatus');
    } catch (e) {
      showErrorSnackbar(context, 'Failed to update status: $e');
    }
  }

  // Method to show a confirmation dialog for account deletion
  Future<void> _confirmDeleteUser() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User Account'),
          content: const Text('Are you sure you want to permanently delete this user account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteUser();
    }
  }

  // Method to delete user account
  Future<void> _deleteUser() async {
    try {
      // TODO: Implement actual user deletion 
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();
      showSuccessSnackbar(context, 'User account deleted successfully');
      Navigator.pop(context); // Go back to the users list
    } catch (e) {
      showErrorSnackbar(context, 'Failed to delete user: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit User Profile",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditUserPage(userId: widget.userId,)));
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String name = userData['name'] ?? 'N/A';
          final String email = userData['email'] ?? 'N/A';
          final String phone = userData['phone'] ?? 'N/A';
          final String role = userData['role'] ?? 'N/A';
          final String status = userData['status'] ?? 'N/A';
          final Timestamp? registrationTimestamp = userData['createdAt'];
          final String registrationDate = registrationTimestamp != null
              ? DateFormat('MMM dd, yyyy HH:mm').format(registrationTimestamp.toDate())
              : 'N/A';
          

          Color statusColor;
          switch (status.toLowerCase()) {
            case 'active':
              statusColor = Colors.green;
              break;
            case 'suspended':
              statusColor = Colors.red;
              break;
            case 'pending_verification':
              statusColor = Colors.orange;
              break;
            case 'inactive':
              statusColor = Colors.grey;
              break;
            default:
              statusColor = Colors.blueGrey;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 40, color: Colors.blue, fontWeight: FontWeight.bold),
                          )
                        
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoCard(
                  title: "Basic Information",
                  children: [
                    _buildInfoRow(Icons.person, "Name", name),
                    _buildInfoRow(Icons.email, "Email", email),
                    _buildInfoRow(Icons.phone, "Phone", phone),
                    _buildInfoRow(Icons.account_circle, "Role", role.capitalize()),
                    _buildInfoRow(
                      Icons.info,
                      "Status",
                      status.capitalize(),
                      valueColor: statusColor,
                    ),
                    _buildInfoRow(Icons.calendar_today, "Joined", registrationDate),
                    
                  ],
                ),
                const SizedBox(height: 24),
                // Section for User Actions
                _buildInfoCard(
                  title: "Account Actions",
                  children: [
                    ListTile(
                      leading: Icon(
                        status == 'active' ? Icons.block : Icons.check_circle_outline,
                        color: status == 'active' ? Colors.red : Colors.green,
                      ),
                      title: Text(status == 'active' ? 'Suspend Account' : 'Activate Account'),
                      onTap: () => _toggleUserStatus(status),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_reset, color: Colors.deepOrange),
                      title: const Text('Reset Password'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password reset functionality not yet implemented")),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                      onTap: _confirmDeleteUser,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Data from other collections related to this user
                _buildSectionHeader("Rides History"),
                _buildRidesList(widget.userId),
                const SizedBox(height: 24),

                _buildSectionHeader("Ratings"),
                _buildRatingsList(widget.userId),
                const SizedBox(height: 24),

                
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 15 ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  // --- Widgets to display data from other collections ---

  Widget _buildRidesList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rides')
          .where('userId', isEqualTo: userId) 
          .orderBy('timestamp', descending: true)
          .limit(5) // Show last 5 rides
          .snapshots(),
      builder: (context, driverSnapshot) {
        // Also fetch rides as a rider
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('ride_requests')
              .where('userId', arrayContains: userId) 
              .orderBy('timestamp', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, riderSnapshot) {
            if (driverSnapshot.connectionState == ConnectionState.waiting ||
                riderSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (driverSnapshot.hasError || riderSnapshot.hasError) {
              return Text('Error loading rides: ${driverSnapshot.error ?? riderSnapshot.error}');
            }

            final List<DocumentSnapshot> allRides = [];
            allRides.addAll(driverSnapshot.data?.docs ?? []);
            allRides.addAll(riderSnapshot.data?.docs ?? []);

            // Remove duplicates if a user is both driver and rider on the same ride
            final uniqueRides = allRides.fold<List<DocumentSnapshot>>([], (previousValue, element) {
              if (!previousValue.any((e) => e.id == element.id)) {
                previousValue.add(element);
              }
              return previousValue;
            });

            if (uniqueRides.isEmpty) {
              return const Text("No recent rides found for this user.");
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // To prevent nested scrolling
              itemCount: uniqueRides.length,
              itemBuilder: (context, index) {
                final rideData = uniqueRides[index].data() as Map<String, dynamic>;
                final String from = rideData['pickUpName'] ?? 'N/A';
                final String to = rideData['destinationName'] ?? 'N/A';
                final Timestamp? startTime = rideData['timestamp'];
                final String status = rideData['status'] ?? 'N/A';
                final String rideType = (rideData['userId'] == userId) ? 'Driver' : 'Rider';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Icon(
                      rideType == 'Driver' ? Icons.drive_eta : Icons.person_outline,
                      color: Colors.blueAccent,
                    ),
                    title: Text('$from to $to'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${status.capitalize()}'),
                        Text('Date: ${startTime != null ? DateFormat('MMM dd, HH:mm').format(startTime.toDate()) : 'N/A'}'),
                      ],
                    ),
                    trailing: Text(rideType),
                    onTap: () {
                      // TODO: Navigate to Ride Detail 
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("View Ride ${uniqueRides[index].id} details")),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRatingsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .where('ratedUserId', isEqualTo: userId) 
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error loading ratings: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No recent ratings found for this user.");
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final ratingData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final double ratingValue = (ratingData['rating'] as num?)?.toDouble() ?? 0.0;
            final String comment = ratingData['comment'] ?? 'No comment';
            final Timestamp? timestamp = ratingData['timestamp'];
            final String raterId = ratingData['raterId'] ?? 'unknown';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(raterId).get(),
              builder: (context, raterSnapshot) {
                String raterName = 'Unknown User';
                if (raterSnapshot.hasData && raterSnapshot.data!.exists) {
                  raterName = (raterSnapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Unknown User';
                }
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Column(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 28),
                        Text('$ratingValue')
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(raterName),
                        const Spacer(),
                        Text(
                          timestamp != null ? DateFormat('MMM dd, yyyy').format(timestamp.toDate()) : 'N/A',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    subtitle: Text(comment),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}