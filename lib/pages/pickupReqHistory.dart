import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/service/firebase_service.dart';
import 'package:eco_collect/pages/pickupReqDelete.dart';
import 'package:eco_collect/pages/pickupReqUpdate.dart';
import 'package:eco_collect/pages/qrcodeGenerator.dart';

class PickupReqHistory extends StatefulWidget {
  @override
  _PickupReqHistoryState createState() => _PickupReqHistoryState();
}

class _PickupReqHistoryState extends State<PickupReqHistory> {
  final FirebaseService _firebaseService = FirebaseService();
  String searchKeyword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF27AE60),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          "Pick-up Timeline",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
            onPressed: () {
              // Define the functionality of the button here
              print("Dwonload report");
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(60.0), // Set height for the bottom widget
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color of the container
                borderRadius:
                    BorderRadius.all(Radius.circular(12)), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 31, 31, 31)
                        .withOpacity(0.1), // Shadow color with opacity
                    spreadRadius: 5, // Spread radius of the shadow
                    blurRadius: 10, // Blur radius of the shadow
                    offset: const Offset(0, 2), // Position of the shadow
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchKeyword =
                        value.toLowerCase(); // Update the search keyword
                  });
                },
                style: const TextStyle(
                  color:
                      Color.fromARGB(255, 65, 65, 65), // Set a light text color
                  fontSize: 16, // Adjust font size
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: "Search requests",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(
                        255, 178, 178, 178), // Light hint text color
                    fontSize: 15, // Match hint font size with the text
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins', // Match hint font type with the text
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none, // No border
                    borderRadius: BorderRadius.all(
                        Radius.circular(12)), // Rounded corners
                  ),
                  filled: true,
                  fillColor: Colors.white, // Fill color for the TextField
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0), // Padding
                ),
              ),
            ),
          ),
        ),
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

          // Filter the data based on the search keyword
          final filteredDocs =
              snapshot.data!.docs.where((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            // Check if the search keyword matches pickupDate, pickupTime, or any wasteType in wasteEntries
            bool matchesPickupDate = (data['pickupDate'] ?? '')
                .toLowerCase()
                .contains(searchKeyword);
            bool matchesPickupTime = (data['pickupTime'] ?? '')
                .toLowerCase()
                .contains(searchKeyword);

            // Ensure wasteEntries is a list and check for matches
            bool matchesWasteEntries = (data['wasteEntries'] is List)
                ? (data['wasteEntries'] as List).any((entry) {
                    return (entry['wasteType'] ?? '')
                        .toLowerCase()
                        .contains(searchKeyword);
                  })
                : false;

            return matchesPickupDate ||
                matchesPickupTime ||
                matchesWasteEntries;
          }).toList();

          // Display the filtered data in a ListView
          return ListView(
            children: filteredDocs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: const Color(0xFFFFFEF8), // Set card color to hex #FFFEF8
                elevation: 4, // Add shadow to the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pickup Date: ${data['pickupDate'] ?? 'N/A'}", // Handle null
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(
                              255, 51, 51, 51), // Set text color to black
                        ),
                      ),
                      Text(
                        "Pickup Time: ${data['pickupTime'] ?? 'N/A'}", // Handle null
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(
                              255, 67, 67, 67), // Set text color to black
                        ),
                      ),
                      Text(
                        "Address: ${data['address'] ?? 'N/A'}", // Display the address
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(
                              255, 105, 105, 105), // Set text color to black
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Waste Details:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(
                              255, 35, 35, 35), // Set text color to black
                        ),
                      ),
                      ...?data['wasteEntries']?.map<Widget>((entry) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${entry['wasteType'] ?? 'Unknown Waste Type'}", // Waste type
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromARGB(
                                              255,
                                              105,
                                              105,
                                              105)), // Set text color to black
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "${entry['bagCount'] ?? '0'} bags", // Bag count
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: const Color.fromARGB(
                                            255,
                                            105,
                                            105,
                                            105)), // Set text color to black
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    entry['weight'] != null
                                        ? "${entry['weight']} kg" // Display weight
                                        : "Pending", // Use string "Pending" directly
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: entry['weight'] != null
                                          ? const Color.fromARGB(255, 105, 105,
                                              105) // Set text color to gray for weight
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })?.toList() ??
                          [
                            Text('No waste entries available',
                                style: TextStyle(
                                    color: Colors
                                        .black)), // Handle null waste entries
                          ],
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
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Color(0xFF5FAD46), // White text color
                            ),
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
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromARGB(
                                  255, 185, 184, 184), // White text color
                            ),
                            child: const Text("Delete"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the QR Code generator page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QRCodeGenerator(
                                    requestId: document
                                        .id, // Pass the document ID to QR Code page if needed
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Color(0xFF5FAD46), // White text color
                            ),
                            child: Text("QR Code"),
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
