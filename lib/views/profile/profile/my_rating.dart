import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyRatingsPage extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Ratings', style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ratings')
                    .where('ratedUserId', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  var docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text("No ratings yet.", style: TextStyle(fontSize: 16)),
                    );
                  }
                  
                  double avg = docs
                          .map((doc) => doc['rating'] as num)
                          .reduce((a, b) => a + b) /
                      docs.length;

                  return Column(
                    children: [
                      Text("Average Rating", style: TextStyle(fontSize: 18)),
                      RatingBarIndicator(
                        rating: avg,
                        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 30.0,
                        direction: Axis.horizontal,
                      ),
                      SizedBox(height: 8),
                      Text("${avg.toStringAsFixed(1)} / 5.0", style: TextStyle(fontSize: 16)),
                    ],
                  );
                },
              ),

              SizedBox(height: 20),

              // Ratings List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('ratings')
                      .where('ratedUserId', isEqualTo: currentUserId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                    var ratings = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: ratings.length,
                      itemBuilder: (context, index) {
                        var data = ratings[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(data['raterName'] ?? "Anonymous",
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                RatingBarIndicator(
                                  rating: (data['rating'] as num).toDouble(),
                                  itemBuilder: (context, _) =>
                                      Icon(Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  direction: Axis.horizontal,
                                ),
                                SizedBox(height: 8),
                                if ((data['comment'] ?? "").toString().trim().isNotEmpty)
                                  Text(
                                    data['comment'],
                                    style: TextStyle(fontSize: 15),
                                  ),
                                SizedBox(height: 6),
                                Text(
                                  _formatTimestamp(data['timestamp']),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
