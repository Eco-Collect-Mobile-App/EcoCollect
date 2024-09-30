import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/components/lineChart.dart'; // Aliased import

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isFirebaseInitialized = false;
  String? _initializationError;
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _isFirebaseInitialized = true;
        _updateStream();
      });
    } catch (e) {
      setState(() {
        _initializationError = e.toString();
      });
    }
  }

  void _updateStream() {
    final CollectionReference fetchData =
        FirebaseFirestore.instance.collection("wasteData");

    // Apply NIC filter
    _stream = fetchData.where('nic', isEqualTo: '2424').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializationError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error initializing Firebase: $_initializationError'),
        ),
      );
    }

    if (!_isFirebaseInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_stream == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        foregroundColor: Colors.white,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification button press
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Notifications'),
                  content: const Text('No new notifications.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16), // Space between icon and edge of AppBar
        ],
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (streamSnapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Text('Error fetching data: ${streamSnapshot.error}'),
              ),
            );
          }

          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No data found for NIC: 2424'),
            );
          }

          final wasteDataList = streamSnapshot.data!.docs
              .map((doc) => WasteData(
                  name: doc['name'],
                  nic: doc['nic'],
                  organic: doc['organic'],
                  plastic: doc['plastic'],
                  recyclable: doc['recyclable'],
                  other: doc['other']))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your waste in the recent 7 days',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(
                    height: 20), // Add some spacing between text and chart
                WasteLineChart(wasteDataList: wasteDataList),
              ],
            ),
          );
        },
      ),
    );
  }
}
