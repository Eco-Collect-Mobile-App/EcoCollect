import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add waste data to Firestore
  Future<void> addWasteData({
    required String userId,
    required String pickupDate,
    required String pickupTime,
    required List<Map<String, dynamic>> wasteEntries,
  }) async {
    try {
      await _firestore.collection('wasteData').add({
        'userId': userId,
        'pickupDate': pickupDate,
        'pickupTime': pickupTime,
        'wasteEntries': wasteEntries,
      });
      print('Data added successfully to Firestore');
    } catch (e) {
      print('Error adding data: $e');
      throw e; // Propagate the error if needed
    }
  }
}
