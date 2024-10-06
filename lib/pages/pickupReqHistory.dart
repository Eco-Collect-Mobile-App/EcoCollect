import 'package:eco_collect/pages/pickupReport.dart';
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
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PickupReqReport()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 31, 31, 31).withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchKeyword = value.toLowerCase();
                  });
                },
                style: const TextStyle(
                  color: Color.fromARGB(255, 65, 65, 65),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: "Search requests",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 178, 178, 178),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pickup requests found.'));
          }

          final filteredDocs =
              snapshot.data!.docs.where((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            bool matchesPickupDate = (data['pickupDate'] ?? '')
                .toLowerCase()
                .contains(searchKeyword);
            bool matchesPickupTime = (data['pickupTime'] ?? '')
                .toLowerCase()
                .contains(searchKeyword);

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

          return ListView(
            children: filteredDocs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: const Color(0xFFFFFEF8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pickup Date: ${data['pickupDate'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 51, 51, 51),
                        ),
                      ),
                      Text(
                        "Pickup Time: ${data['pickupTime'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 67, 67, 67),
                        ),
                      ),
                      Text(
                        "Address: ${data['address'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 105, 105, 105),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Waste Details:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 35, 35, 35),
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
                                      "${entry['wasteType'] ?? 'Unknown Waste Type'}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: Color.fromARGB(
                                              255, 105, 105, 105)),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "${entry['bagCount'] ?? '0'} bags",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Color.fromARGB(255, 105, 105, 105)),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    entry['weight'] != null
                                        ? "${entry['weight']} kg"
                                        : "Pending",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: entry['weight'] != null
                                          ? const Color.fromARGB(
                                              255, 105, 105, 105)
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })?.toList() ??
                          [
                            const Text('No waste entries available',
                                style: TextStyle(color: Colors.black)),
                          ],
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (data['wasteEntries'] != null &&
                              (data['wasteEntries'] as List)
                                  .any((entry) => entry['weight'] == null))
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PickupReqUpdate(
                                      requestId: document.id,
                                      existingData: data,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF5FAD46),
                              ),
                              child: Text("Update"),
                            ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PickupReqDelete(
                                    requestId: document.id,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromARGB(255, 185, 184, 184),
                            ),
                            child: const Text("Delete"),
                          ),
                          if (data['wasteEntries'] != null &&
                              (data['wasteEntries'] as List)
                                  .any((entry) => entry['weight'] == null))
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QRCodeGenerator(
                                      requestId: document.id,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF5FAD46),
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
