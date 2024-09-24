import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/service/firebase_service.dart';
import 'package:eco_collect/pages/pickupReqDelete.dart'; // Ensure this page exists
import 'package:eco_collect/pages/pickupReqUpdate.dart'; // Ensure this page exists

class PickupReqHistory extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  PickupReqHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Garbage Pick-up Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getWasteRequestsForUser(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No pickup requests found.'));
          }

          // Display the data in a ListView
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pickup Date: ${data['pickupDate'] ?? 'N/A'}", // Handle null
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Pickup Time: ${data['pickupTime'] ?? 'N/A'}", // Handle null
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Waste Entries:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...?data['wasteEntries']?.map<Widget>((entry) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${entry['wasteType'] ?? 'Unknown Waste Type'}: ${entry['bagCount'] ?? '0'} bags", // Handle null
                                  ),
                                  Text(
                                    "Weight: ${entry['weight'] != null ? entry['weight'].toString() + ' kg' : 'Pending'}", // Display weight or pending
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })?.toList() ??
                          [
                            Text('No waste entries available')
                          ], // Handle null waste entries
                      SizedBox(height: 10),

                      // Add Update and Delete buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the pickupReqUpdate page, pass the document ID and existing data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PickupReqUpdate(
                                    requestId: document.id,
                                    existingData:
                                        data, // Pass the existing data here
                                  ),
                                ),
                              );
                            },
                            child: Text("Update"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the pickupReqDelete page, pass the document ID
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PickupReqDelete(
                                    requestId: document.id, // Pass document ID
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red, // Red color for delete
                            ),
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
