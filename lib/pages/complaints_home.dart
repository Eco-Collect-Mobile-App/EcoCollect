import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eco_collect/pages/complaint_details_page.dart';
import 'package:eco_collect/pages/complaints_form.dart';
import 'package:eco_collect/service/database.dart';

class ComplaintsHome extends StatefulWidget {
  const ComplaintsHome({super.key});

  @override
  State<ComplaintsHome> createState() => _ComplaintsHomeState();
}

class _ComplaintsHomeState extends State<ComplaintsHome> {
  Stream<QuerySnapshot>? complaintStream; //Stream to listen to user complaints

  // Function to load complaint stream for the logged-in user
  getOnTheLoad() async {
    // Get the current user's ID from Firebase Authentication
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    // Fetch the stream of complaints for the logged-in user
    complaintStream = DatabaseMethods().getUserComplaintsStream(userId);
    // Update the state to refresh UI with new complaintStream data
    setState(() {});
  }

  @override
  void initState() {
    getOnTheLoad(); // Call the function to load complaints when the widget is initialized
    super.initState();
  }

  // Widget to display the list of user complaints
  Widget allComplaintsDetails() {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    final String currentUserId = user?.uid ?? ''; // Get the user ID

    return StreamBuilder<QuerySnapshot>(
      stream: complaintStream, // Use the complaint stream to build the list
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Show loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // If no complaints are found, display a message
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No complaints found.'));
        }

        // Build a list of complaints
        return ListView.builder(
          itemCount: snapshot.data!.docs.length, // Number of complaints
          itemBuilder: (context, index) {
            DocumentSnapshot ds =
                snapshot.data!.docs[index]; // Get complaint data
            if (ds.exists) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: InkWell(
                  onTap: () {
                    // On tap, navigate to the ComplaintDetailsPage with selected complaint's details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintDetailsPage(
                          currentUserId: currentUserId,
                          complaintId: ds.id,
                          name: ds["Name"] ?? "Unknown",
                          email: ds["Email"] ?? "N/A",
                          date: ds["Date"] ?? "Unknown Date",
                          type: ds["Type"] ?? "N/A",
                          description: ds["Description"] ?? "No Description",
                          location: ds["Location"] ?? "N/A",
                          status: ds["Status"] ?? "pending",
                        ),
                      ),
                    );
                  },
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Display the complaint date
                              Text(
                                ds["Date"] ?? "Unknown Date",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 54, 54, 54),
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  // Display the complaint status with an icon
                                  Icon(
                                    ds["Status"] == "pending"
                                        ? Icons.pending
                                        : Icons.check_circle,
                                    color: ds["Status"] == "pending"
                                        ? const Color.fromARGB(163, 151, 95, 10)
                                        : const Color.fromARGB(
                                            174, 76, 175, 79),
                                  ),
                                  const SizedBox(width: 5.0),
                                  // Display the status text
                                  Text(
                                    ds["Status"] ?? "pending",
                                    style: TextStyle(
                                      color: ds["Status"] == "pending"
                                          ? const Color.fromARGB(
                                              163, 151, 95, 10)
                                          : const Color.fromARGB(
                                              174, 76, 175, 79),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          // Display the complaint description
                          Text(
                            ds["Description"] ?? "No description",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 54, 54, 54),
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink(); // No data
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        title: const Text(
          'Report an Issue',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint picture and introductory text
            Row(
              children: [
                Image.asset(
                  'assets/pic-1.png',
                  width: 70.0,
                  height: 70.0,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 25.0),
                const Expanded(
                  child: Text(
                    "Let us know if you have faced any problems with garbage collection service.",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            // Submit complaint button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5FAD46),
                ),
                onPressed: () {
                  // Navigate to complaints form page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ComplaintsForm()),
                  );
                },
                child: const Text(
                  "Add Complaint",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30.0),

            // main topic
            const Text(
              "My Complaints",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 3.0),

            // Subtopic text
            const Text(
              "Check the status of your previous reports.",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30.0),

            // Display the list of complaints
            Expanded(child: allComplaintsDetails()),
          ],
        ),
      ),
    );
  }
}
