import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:eco_collect/user_management/models/UserModel.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final CollectionReference fetchData =
      FirebaseFirestore.instance.collection("wasteData");

  @override
  Widget build(BuildContext context) {
    // Access the logged-in user's uid from the StreamProvider
    final user = Provider.of<UserModel?>(context);
    final String? uid = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: StreamBuilder(
        stream: fetchData.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          // Check for errors in the snapshot
          if (streamSnapshot.hasError) {
            return Center(
              child: Text('Error: ${streamSnapshot.error}'),
            );
          }

          // Check for connection state (loading)
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If data is available
          if (streamSnapshot.hasData) {
            // Filter documents by matching the uid with userId from Firestore
            var filteredDocs = streamSnapshot.data!.docs.where((doc) {
              return doc['userId'] ==
                  uid; // Only include documents with matching userId
            }).toList();

            if (filteredDocs.isEmpty) {
              return const Center(
                child: Text('No data found for this user'),
              );
            }

            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = filteredDocs[index];

                // Extracting necessary data from the document
                String pickupDate = documentSnapshot['pickupDate'];
                List wasteEntries = documentSnapshot['wasteEntries'];

                return Material(
                  child: ListTile(
                    title: Text('Pickup Date: $pickupDate'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: wasteEntries.map((entry) {
                        String wasteType = entry['wasteType'];

                        // Safely convert bagCount to an integer
                        int bagCount =
                            int.tryParse(entry['bagCount'].toString()) ?? 0;

                        // Handle weight, ensuring it's a string
                        var weight = entry['weight'] != null
                            ? entry['weight'].toString()
                            : 'N/A';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            'Waste Type: $wasteType, Bag Count: $bagCount, Weight: $weight',
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          }

          // If no data is available, show a message
          return const Center(
            child: Text('No data found'),
          );
        },
      ),
    );
  }
}
