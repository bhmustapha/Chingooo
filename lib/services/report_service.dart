
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//! to learn
class ReportService {

  static Future<void> reportUser(BuildContext context, String reportedUserId, String reportedUserName) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    String username = userSnapshot.get('name');

    if (currentUserId == reportedUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot report yourself.')),
      );
      return;
    }

    // Check if the current user has already reported this user
    final existingReport = await FirebaseFirestore.instance
        .collection('reports')
        .where('reporterId', isEqualTo: currentUserId)
        .where('reportedUserId', isEqualTo: reportedUserId)
        .limit(1)
        .get();

    if (existingReport.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already reported this user.')),
      );
      return;
    }

    TextEditingController reasonController = TextEditingController();
    bool? confirmReport = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Report $reportedUserName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to report $reportedUserName? Please provide a reason.'),
              const SizedBox(height: 15),
              // MODIFIED: Rounded border for TextField
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason for reporting (optional)',
                  labelStyle: TextStyle(
                    fontSize: 12
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Rounded borders
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Report', style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmReport == true) {
      try {
        // 1. Add the report document to the 'reports' collection
        await FirebaseFirestore.instance.collection('reports').add({
          'reporterId': currentUserId,
          'reportedUserId': reportedUserId,
          'reportedUserName': reportedUserName,
          'reason': reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : 'No reason provided',
          'timestamp': FieldValue.serverTimestamp(),
          'reporterName' : username,
          'status': 'pending',
        });

        // 2. Increment the 'reportCount' in the reported user's document
        await FirebaseFirestore.instance.collection('users').doc(reportedUserId).update({
          'reportCount': FieldValue.increment(1),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted for $reportedUserName. Thank you!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    }
  }
}