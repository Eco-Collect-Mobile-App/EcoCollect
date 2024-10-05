import 'package:flutter/material.dart';
import 'package:eco_collect/pages/edit_details_page.dart';
import 'package:eco_collect/service/database.dart';

class ComplaintDetailsPage extends StatelessWidget {
  final String currentUserId;
  final String complaintId;
  final String name;
  final String email;
  final String date;
  final String type;
  final String description;
  final String location;
  final String status;

  // Constructor to receive complaint details
  ComplaintDetailsPage({
    required this.currentUserId,
    required this.complaintId,
    required this.name,
    required this.email,
    required this.date,
    required this.type,
    required this.description,
    required this.location,
    required this.status,
  });

  // Function to handle the deletion with confirmation
  void _confirmDelete(BuildContext context) {
    // Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content:
              const Text("Are you sure you want to delete this complaint?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                // Perform the delete operation here
                _deleteComplaint(context); // Call delete function
                Navigator.popUntil(context, (route) => route.isFirst); // Navigate back to home
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete the complaint from Firestore
  Future<void> _deleteComplaint(BuildContext context) async {
    try {
      // Call the delete function from DatabaseMethods
      await DatabaseMethods().deleteComplaint(complaintId,currentUserId);
    } catch (e) {
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete complaint')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff27AE60),
        title: const Row(
          children: [
            Expanded(
              // Title
              child: Text(
                "Complaint Details",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.notifications, color: Colors.white) // Notifications icon
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the complaint type
            Text(
              type,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30.0),

            // Name field container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xffD4EED1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Name : $name",
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Email field container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xffD4EED1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Email : $email",
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Date field container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xffD4EED1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Date : $date",
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Description field container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xffD4EED1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Description : $description",
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Location field container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xffD4EED1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Location : $location",
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Complaint status (pending or resolved) with icon
            Row(
              children: [
                Icon(
                  status == "pending" ? Icons.pending : Icons.check_circle,
                  color: status == "pending"
                      ? const Color.fromARGB(163, 151, 95, 10)
                      : const Color.fromARGB(174, 76, 175, 79),
                ),
                const SizedBox(width: 8.0),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: status == "pending"
                        ? const Color.fromARGB(163, 151, 95, 10)
                        : const Color.fromARGB(174, 76, 175, 79),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50.0),

            // Edit and Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit Icon Button
                CircleAvatar(
                  backgroundColor: status == "resolved"
                      ? Colors.grey[300] // Disable editing if resolved
                      : Colors.lightGreen[100], // Green if pending
                  radius: 36,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: status == "resolved"
                          ? Colors.grey
                          : Colors.green, // Gray if resolved
                    ),
                    onPressed: status == "resolved"
                        ? null // Disable if status is resolved
                        : () async {
                            // Navigate to EditComplaintPage
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditComplaintPage(
                                  currentUserId: currentUserId,
                                  complaintId: complaintId,
                                  name: name,
                                  email: email,
                                  date: date,
                                  description: description,
                                  location: location,
                                  status: status,
                                ),
                              ),
                            );
                            if (result == true) {
                              // Refresh the details page with updated data
                              Navigator.pop(context, true);
                            }
                          },
                  ),
                ),
                const SizedBox(width: 20),

                // Delete Icon Button
                CircleAvatar(
                  backgroundColor: Colors.lightGreen[100],
                  radius: 36,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context); // Call delete confirmation
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
