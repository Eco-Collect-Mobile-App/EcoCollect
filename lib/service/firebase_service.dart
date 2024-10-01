import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/user_management/services/auth.dart';

class FirebaseService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthServices _authServices =
      AuthServices(); // Create an instance of AuthServices

  // Method to add waste data including NIC and address
  Future<void> addWasteData({
    required String userId,
    required String pickupDate,
    required String pickupTime,
    required List<Map<String, dynamic>> wasteEntries,
    required String nic, // NIC parameter
    required String address,
  }) async {
    try {
      // Add the waste data including weight to Firestore
      await _firestore.collection('wasteData').add({
        'userId': userId, // Use the passed userId
        'pickupDate': pickupDate,
        'pickupTime': pickupTime,
        'wasteEntries': wasteEntries,
        'nic': nic, // Store NIC
        'address': address,
      });
    } catch (e) {
      print('Error adding waste data: $e');
      throw e;
    }
  }

  // Method to retrieve user data from Firestore using user ID
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print('No user data found for user ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      throw e; // Propagate the error if needed
    }
  }

  // Method to retrieve waste data from Firestore for the current logged-in user
  Stream<QuerySnapshot> getWasteRequestsForUser() async* {
    try {
      String? userId =
          await _authServices.getUserUid(); // Get the current user's UID

      if (userId == null) {
        throw Exception('No user is currently logged in.');
      }

      // Return only the current user's waste data
      yield* _firestore
          .collection('wasteData')
          .where('userId', isEqualTo: userId)
          .snapshots();
    } catch (e) {
      print('Error retrieving data: $e');
      throw e; // Propagate the error if needed
    }
  }

  // Method to delete a waste request by ID
  Future<void> deleteWasteRequest(String requestId) async {
    try {
      await _firestore.collection('wasteData').doc(requestId).delete();
      print('Request deleted successfully');
    } catch (e) {
      print('Error deleting request: $e');
      throw e;
    }
  }

  // Method to retrieve waste data for a specific request ID
  Future<Map<String, dynamic>?> getWasteData(String requestId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('wasteData').doc(requestId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print('No waste data found for request ID: $requestId');
        return null;
      }
    } catch (e) {
      print('Error retrieving waste data: $e');
      throw e; // Propagate the error if needed
    }
  }

  // Update waste data by request ID
  Future<void> updateWasteData({
    required String requestId,
    required String userId,
    required String pickupDate,
    required String pickupTime,
    required List<Map<String, dynamic>> wasteEntries,
    required String nic,
    required String address, // New city parameter for update
  }) async {
    try {
      await _firestore.collection('wasteData').doc(requestId).update({
        'userId': userId,
        'pickupDate': pickupDate,
        'pickupTime': pickupTime,
        'wasteEntries': wasteEntries,
        'nic': nic, // Update NIC
        'address': address, // Update address number
      });
    } catch (e) {
      throw Exception('Error updating waste data: $e');
    }
  }
}
