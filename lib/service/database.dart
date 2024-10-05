import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to insert complaint details to the database
  // This method adds a new complaint to the "Complaints" collection in Firestore.
  Future addComplaintsDetails(
      Map<String, dynamic> complaintsInfoMap, String id) async {
    try {
      // Set the complaint data with the provided ID in the "Complaints" collection
      await FirebaseFirestore.instance
          .collection("Complaints")
          .doc(id)
          .set(complaintsInfoMap);
    } catch (e) {
      // Print error and rethrow in case of failure
      print("Error adding complaint details: $e");
      throw e;
    }
  }

  // Method to Read complaint from the database
  // This method returns a stream of snapshots that can be used to listen to changes
  Stream<QuerySnapshot> getUserComplaintsStream(String userId) {
  // Query the "Complaints" collection and filter results where the "userId" matches the provided userId
  return _firestore.collection("Complaints")
      .where("userId", isEqualTo: userId) // Filter by user ID
      .snapshots(); // Return a stream of snapshots
  }



  // Method to update complaint details in the database
  // This method ensures that only the user who submitted the complaint can update it.
  Future<void> updateComplaintDetails(String complaintId, String userId, Map<String, dynamic> updatedData) async {
    try {
      // Retrieve the complaint document to check if the user is the owner
      DocumentSnapshot complaintDoc = await _firestore
        .collection('Complaints')
        .doc(complaintId)
        .get();

      // Check if the complaint exists
      if (complaintDoc.exists) {
        String complaintUserId = complaintDoc["userId"];

        // Ensure the logged-in user is the owner of the complaint
        if (complaintUserId == userId) {
          await _firestore
            .collection('Complaints')
            .doc(complaintId)
            .update(updatedData);

          print("Complaint updated successfully!");
        } else {
          // Handle error if the user is not authorized to update the complaint
          print("Error: You do not have permission to update this complaint.");
          throw Exception("You do not have permission to update this complaint.");
        }
      } else {
        // Handle error if the complaint document does not exist
        print("Error: Complaint not found.");
        throw Exception("Complaint not found.");
      }
    } catch (e) {
      // Print error and rethrow in case of failure
      print("Error updating complaint details: $e");
      throw e;
    }
  }


  // Method to delete complaint from the database
  // This method ensures that only the user who submitted the complaint can delete it.
  Future<void> deleteComplaint(String complaintId, String userId) async {
    try {
      // Retrieve the complaint to check if the user is the owner
      DocumentSnapshot complaintDoc = await _firestore
        .collection('Complaints')
        .doc(complaintId)
        .get();

      if (complaintDoc.exists) {
        String complaintUserId = complaintDoc["userId"];

        // Ensure the logged-in user is the owner of the complaint
        if (complaintUserId == userId) {
          await _firestore
          .collection('Complaints')
          .doc(complaintId)
          .delete();

          print("Complaint deleted successfully!");
        } else {
          // Handle error if the user is not authorized to delete the complaint
          print("Error: You do not have permission to delete this complaint.");
          throw Exception("You do not have permission to delete this complaint.");
        }
      } else {
        // Handle error if the complaint document does not exist
        print("Error: Complaint not found.");
        throw Exception("Complaint not found.");
      }
    } catch (e) {
      // Print error and rethrow in case of failure
      print("Error deleting complaint: $e");
      throw e;
    }
  }

}
