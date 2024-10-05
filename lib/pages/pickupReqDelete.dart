import 'package:flutter/material.dart';
import 'package:eco_collect/service/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/pages/pickupReqHistory.dart';

class PickupReqDelete extends StatelessWidget {
  final String requestId;
  final FirebaseService _firebaseService = FirebaseService();

  PickupReqDelete({required this.requestId});

  Future<void> _confirmDeletion(BuildContext context) async {
    try {
      // Call the delete function from FirebaseService
      await _firebaseService.deleteWasteRequest(requestId);

      // Show a SnackBar with a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request deleted successfully')),
      );

      // Navigate to PickupReqHistory after deletion
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PickupReqHistory(),
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
        backgroundColor: Color(0xFF27AE60),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text("Delete Request",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xFFE7EBE8), // Set background color to #E7EBE8
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFEF8), // Set box color to #FFFEF8
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'By pressing the confirm deletion button, the request will be permanently deleted. Are you sure you want to proceed?',
                    style: TextStyle(
                        color: Color.fromARGB(255, 250, 21, 4),
                        fontWeight: FontWeight.w700,
                        fontSize: 17),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
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
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF5FAD46), // Button color set to green
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                onPressed: () => _confirmDeletion(context),
                child: Text(
                  'Confirm Deletion',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600), // Button text color set to white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
