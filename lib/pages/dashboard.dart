import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            print(streamSnapshot.data!.docs); // Debugging: Log the data

            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

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
                        int bagCount = entry['bagCount'];
                        var weight =
                            entry['weight'] ?? 'N/A'; // Handle null weight

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
