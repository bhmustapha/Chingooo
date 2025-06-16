import 'package:carpooling/views/profile/users_profiles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // A map to store the visibility state for each report's ID
  // Key: report document ID, Value: boolean (true if ID is visible)
  final Map<String, bool> _showReportedUserId = {};

  // Helper method to format timestamps for display
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

  // Function to update the status of a report
  Future<void> _markReportAsReviewed(String reportDocId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportDocId)
          .update({'status': 'reviewed'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report marked as reviewed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark report as reviewed: $e')),
      );
    }
  }

  // Function to toggle the visibility of the reported user ID
  void _toggleIdVisibility(String reportId) {
    setState(() {
      _showReportedUserId[reportId] = !(_showReportedUserId[reportId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Reports'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading reports: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No new reports at the moment.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reportDoc = snapshot.data!.docs[index];
              final reportData = reportDoc.data() as Map<String, dynamic>;
              final String reportId = reportDoc.id;

              final String reporterId = reportData['reporterId'] ?? 'N/A';
              final String reporterName = reportData['reporterName'] ?? 'N/A';
              final String reportedUserId = reportData['reportedUserId'] ?? 'unknown';
              final String reportedUserName = reportData['reportedUserName'] ?? 'N/A';
              final String reason = reportData['reason'] ?? 'No reason provided.';
              final Timestamp timestamp = reportData['timestamp'] ?? Timestamp.now();
              final String status = reportData['status'] ?? 'pending';

              // Determine if the ID should be shown for this specific report
              final bool isIdVisible = _showReportedUserId[reportId] ?? false;

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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userId: reporterId)));
                      },
                            child: Text(
                              'Report by: $reporterName',
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
                      // Display Reported User Name and the Toggle Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userId: reportedUserId)));
                      },
                              child: Text(
                                'Reported User: $reportedUserName',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          // Button to show/hide the ID
                          TextButton(
                            onPressed: () => _toggleIdVisibility(reportId),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // Remove default padding
                              minimumSize: Size.zero, // Remove default minimum size
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap area
                            ),
                            child: Text(
                              isIdVisible ? 'Hide ID' : 'Show ID',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Display the ID conditionally
                      if (isIdVisible)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SelectableText( // Use SelectableText to allow copying
                            'ID: $reportedUserId',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Reason: "$reason"',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: status == 'pending' ? Colors.orange.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Status: ${status.toUpperCase()}',
                              style: TextStyle(
                                color: status == 'pending' ? Colors.orange.shade800 : Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (status == 'pending')
                            TextButton(
                              onPressed: () => _markReportAsReviewed(reportId),
                              style: TextButton.styleFrom(
                                foregroundColor:  Theme.of(context).primaryColor,
                              ),
                              child: const Text('Mark as Reviewed'),
                            ),
                        ],
                      ),
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