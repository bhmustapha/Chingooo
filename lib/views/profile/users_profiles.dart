// lib/views/profile/user_profile_page.dart

import 'package:carpooling/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatefulWidget {
  final String userId; // The ID of the user whose profile is being viewed

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Helper method to dynamically get a color based on a name
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
    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      String period = date.hour < 12 ? 'AM' : 'PM';
      int hour = date.hour % 12;
      if (hour == 0) hour = 12;
      return 'Today at ${hour}:${date.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading Profile...'),
              elevation: 0,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (userSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile Error'),
              elevation: 0,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
            ),
            body: Center(child: Text('Error: ${userSnapshot.error}')),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile Not Found'),
              elevation: 0,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
            ),
            body: const Center(child: Text('User not found.')),
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String userName = userData['name'] ?? 'N/A';
        final String userEmail = userData['email'] ?? 'N/A';
        final double averageRating = (userData['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int ratingsCount = (userData['ratingsCount'] as int?) ?? 0;

        final String firstChar = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

        return Scaffold(
          appBar: AppBar(
            title: Text('$userName Profile'),
            actions: [
              if (currentUserId != widget.userId)
                // MODIFIED: Changed from IconButton to TextButton
                IconButton(
                  onPressed: () => ReportService.reportUser(context, widget.userId, userName),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red, // Make the text red
                  ),
                  icon: const Icon(Icons.report)
                ),
            ],
            elevation: 0,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 35,
                  backgroundColor: _getColorFromName(userName),
                  child: Text(
                    firstChar,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        ratingsCount > 0
                            ? '${averageRating.toStringAsFixed(1)} Stars'
                            : 'No ratings yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ratingsCount > 0) ...[
                        const SizedBox(width: 5),
                        Text(
                          '($ratingsCount reviews)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Vehicle Information Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(height: 20, thickness: 1, color: Theme.of(context).dividerColor),
                          _buildVehicleDetails(context, widget.userId),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Reviews for $userName',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('ratings')
                      .where('ratedUserId', isEqualTo: widget.userId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, ratingsSnapshot) {
                    if (ratingsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (ratingsSnapshot.hasError) {
                      return Center(child: Text('Error loading ratings: ${ratingsSnapshot.error}'));
                    }
                    if (!ratingsSnapshot.hasData || ratingsSnapshot.data!.docs.isEmpty) {
                      return Center(child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No reviews yet.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ratingsSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final ratingDoc = ratingsSnapshot.data!.docs[index];
                        final ratingData = ratingDoc.data() as Map<String, dynamic>;
                        final int rating = ratingData['rating'] ?? 0;
                        final String comment = ratingData['comment'] ?? 'No comment provided.';
                        final String raterId = ratingData['raterId'] ?? '';
                        final Timestamp timestamp = ratingData['timestamp'] ?? Timestamp.now();

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(raterId).get(),
                          builder: (context, raterSnapshot) {
                            String raterName = 'Anonymous User';
                            if (raterSnapshot.connectionState == ConnectionState.done && raterSnapshot.hasData) {
                              final raterData = raterSnapshot.data!.data() as Map<String, dynamic>?;
                              raterName = raterData?['name'] ?? 'Anonymous User';
                            } else if (raterSnapshot.hasError) {
                              raterName = 'Error Rater';
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              color: Theme.of(context).cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          raterName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex < rating ? Icons.star : Icons.star_border,
                                              size: 18,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      comment,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        _formatTimestamp(timestamp),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleDetails(BuildContext context, String userId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).collection('vehicles').get(),
      builder: (context, vehicleSnapshot) {
        if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vehicleSnapshot.hasError) {
          return Center(child: Text('Error loading vehicles: ${vehicleSnapshot.error}'));
        }
        if (!vehicleSnapshot.hasData || vehicleSnapshot.data!.docs.isEmpty) {
          return Text(
            'No vehicle information available.',
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: vehicleSnapshot.data!.docs.map((vehicleDoc) {
            final vehicleData = vehicleDoc.data() as Map<String, dynamic>;

            final String vehicleMake = vehicleData['make'] ?? 'N/A';
            final String vehicleModel = vehicleData['model'] ?? 'N/A';
            final String vehicleYear = vehicleData['year']?.toString() ?? 'N/A';
            final String vehicleColor = vehicleData['color'] ?? 'N/A';
            final String licensePlate = vehicleData['licensePlate'] ?? 'N/A';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vehicleSnapshot.data!.docs.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${vehicleMake} ${vehicleModel} (${vehicleYear})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  _buildProfileInfoRow(context, Icons.directions_car, 'Make', vehicleMake),
                  _buildProfileInfoRow(context, Icons.model_training, 'Model', vehicleModel),
                  _buildProfileInfoRow(context, Icons.calendar_today, 'Year', vehicleYear),
                  _buildProfileInfoRow(context, Icons.color_lens, 'Color', vehicleColor),
                  _buildProfileInfoRow(context, Icons.badge, 'License Plate', licensePlate),
                  if (vehicleDoc != vehicleSnapshot.data!.docs.last)
                    Divider(height: 30, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.5)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}