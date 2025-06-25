import 'package:carpooling/views/profile/users_profiles.dart'; // Make sure this path is correct
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  int? _selectedRatingFilter;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Reviews'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFilterButton(context, 'All', null),
                  const SizedBox(width: 8),
                  // Changed from '5⭐' to use a Row with Text and Icon
                  _buildFilterButtonWithIcon(context, '5', 5),
                  const SizedBox(width: 8),
                  _buildFilterButtonWithIcon(context, '4', 4),
                  const SizedBox(width: 8),
                  _buildFilterButtonWithIcon(context, '3', 3),
                  const SizedBox(width: 8),
                  _buildFilterButtonWithIcon(context, '2', 2),
                  const SizedBox(width: 8),
                  _buildFilterButtonWithIcon(context, '1', 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredReviewsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading reviews: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No reviews available for this filter.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final reviewDoc = snapshot.data!.docs[index];
                    final reviewData = reviewDoc.data() as Map<String, dynamic>;

                    final String raterId = reviewData['raterId'] ?? '';
                    final String raterName = reviewData['raterName'] ?? 'N/A';
                    final String ratedUserId = reviewData['ratedUserId'] ?? '';
                    final int rating = reviewData['rating'] ?? 0;
                    final String comment = reviewData['comment'] ?? 'No comment provided.';
                    final Timestamp timestamp = reviewData['timestamp'] ?? Timestamp.now();

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(ratedUserId).get(),
                      builder: (context, ratedUserSnapshot) {
                        String ratedUserName = 'Loading...';

                        if (ratedUserSnapshot.connectionState == ConnectionState.done && ratedUserSnapshot.hasData) {
                          final ratedUserData = ratedUserSnapshot.data!.data() as Map<String, dynamic>?;
                          ratedUserName = ratedUserData?['name'] ?? 'Unknown User';
                        } else if (ratedUserSnapshot.hasError) {
                          ratedUserName = 'Error User';
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userId: raterId)));
                                      },
                                      child: Text(
                                        'From: $raterName',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(timestamp),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userId: ratedUserId)));
                                  },
                                  child: Text(
                                    'To: $ratedUserName',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < rating ? Icons.star : Icons.star_border,
                                      size: 20,
                                      color: Colors.amber,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Comment: "$comment"',
                                  style: Theme.of(context).textTheme.bodyMedium,
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
          ),
        ],
      ),
    );
  }

  // Helper method to build a filter button for "All"
  Widget _buildFilterButton(BuildContext context, String text, int? ratingValue) {
    final bool isSelected = _selectedRatingFilter == ratingValue;
    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRatingFilter = selected ? ratingValue : null;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
        width: 1.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // New helper method to build a filter button with a solid star icon
  Widget _buildFilterButtonWithIcon(BuildContext context, String text, int? ratingValue) {
    final bool isSelected = _selectedRatingFilter == ratingValue;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min, // To make the row only as wide as its children
        children: [
          Text(text),
          const SizedBox(width: 4), // Small spacing between text and icon
          Icon(
            Icons.star,
            size: 16, // Adjust icon size to fit well within the chip
            color: isSelected ? Theme.of(context).primaryColor : Colors.amber, // Icon color
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRatingFilter = selected ? ratingValue : null;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
        width: 1.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Stream<QuerySnapshot> _getFilteredReviewsStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('ratings');

    if (_selectedRatingFilter != null) {
      query = query.where('rating', isEqualTo: _selectedRatingFilter);
    }

    return query.orderBy('timestamp', descending: true).snapshots();
  }
}