import 'package:flutter/material.dart';
import 'package:eco_collect/service/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/pages/pickupReqHistory.dart';

class PickupReqDelete extends StatelessWidget {
  final String requestId;
  final FirebaseService _firebaseService = FirebaseService();

  PickupReqDelete({required this.requestId});

  // Function to handle deletion and navigation
  Future<void> _confirmDeletion(BuildContext context) async {
    try {
      // Call the delete function from FirebaseService
      await _firebaseService.deleteWasteRequest(requestId);

      // Navigate to PickupReqHistory after deletion
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PickupReqHistory(), // Navigate to PickupReqHistory page
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Request Deletion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By pressing the confirm deletion button, the request will be permanently deleted. Are you sure you want to proceed?',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('wasteData')
                  .doc(requestId)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // If the request exists, show its details
                if (snapshot.data != null && snapshot.data!.exists) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pickup Date: ${data['pickupDate']}"),
                      Text("Pickup Time: ${data['pickupTime']}"),
                      SizedBox(height: 10),
                      Text("Waste Entries:"),
                      ...data['wasteEntries'].map<Widget>((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                              "${entry['wasteType']}: ${entry['bagCount']} bags"),
                        );
                      }).toList(),
                    ],
                  );
                } else {
                  return Center(child: Text('Request not found.'));
                }
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _confirmDeletion(context),
                child: Text('Confirm Deletion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
