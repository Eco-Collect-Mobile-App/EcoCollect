import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eco_collect/service/firebase_service.dart';
import 'package:eco_collect/pages/pickupReqHistory.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PickupRequest extends StatefulWidget {
  @override
  _PickupRequestState createState() => _PickupRequestState();
}

class _PickupRequestState extends State<PickupRequest> {
  final _formKey = GlobalKey<FormState>();

  // Create an instance of FirebaseService
  final FirebaseService _firebaseService = FirebaseService();

  // User input controllers
  TextEditingController userIdController = TextEditingController();
  TextEditingController nicController =
      TextEditingController(); // New NIC controller
  TextEditingController addressNoController =
      TextEditingController(); // New address number controller
  TextEditingController streetController =
      TextEditingController(); // New street controller
  TextEditingController cityController =
      TextEditingController(); // New city controller
  TextEditingController pickupDateController = TextEditingController();
  TextEditingController pickupTimeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Waste types and counts (weight is null by default)
  List<Map<String, dynamic>> wasteEntries = [
    {"wasteType": null, "bagCount": null, "weight": null}
  ];

  final List<String> wasteTypes = ["Organic", "Plastic", "Recyclable", "Other"];

  @override
  void initState() {
    super.initState();
    _setUserId(); // Call the function to set the current user ID
  }

  // Function to get the current user's UID and set it to userIdController
  void _setUserId() async {
    User? user =
        FirebaseAuth.instance.currentUser; // Get the current logged-in user
    if (user != null) {
      setState(() {
        userIdController.text = user.uid; // Set the uid to the controller
      });

      // Fetch user data (NIC and address) from Firestore
      var userData = await _firebaseService.getUserData(user.uid);
      if (userData != null) {
        nicController.text = userData['nic'] ?? ''; // Set NIC
        // Set address fields if available
        addressNoController.text = userData['addressNo'] ?? ''; // Address No
        streetController.text = userData['street'] ?? ''; // Street
        cityController.text = userData['city'] ?? ''; // City
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        pickupDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        pickupTimeController.text = picked.format(context);
      });
    }
  }

  void _addWasteEntry() {
    setState(() {
      wasteEntries.add({"wasteType": null, "bagCount": null, "weight": null});
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Collect the form data
      String userId = userIdController.text;
      String nic = nicController.text; // Get NIC

      // Concatenate the address parts into a single string
      String address =
          '${addressNoController.text}, ${streetController.text}, ${cityController.text}';

      String pickupDate = pickupDateController.text;
      String pickupTime = pickupTimeController.text;

      try {
        // Use the FirebaseService to add data to Firestore
        await _firebaseService.addWasteData(
          userId: userId,
          pickupDate: pickupDate,
          pickupTime: pickupTime,
          wasteEntries: wasteEntries,
          nic: nic, // Pass NIC
          address: address, // Pass concatenated address
        );

        // Clear the form
        pickupDateController.clear();
        pickupTimeController.clear();
        nicController.clear(); // Clear NIC
        addressNoController.clear(); // Clear Address No
        streetController.clear(); // Clear Street
        cityController.clear(); // Clear City
        setState(() {
          wasteEntries = [
            {"wasteType": null, "bagCount": null, "weight": null}
          ];
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form Submitted Successfully')),
        );

        // Navigate to the pickup request history page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PickupReqHistory()),
        );
      } catch (e, stackTrace) {
        print('Failed to submit form: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Submit Form: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF27AE60),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text("Garbage Pick-up Request",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // User ID
                      TextFormField(
                        controller: userIdController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'User ID',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(
                              255, 235, 235, 235), // Change fill color
                          filled: true, // Enable the fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                        ),
                        style: TextStyle(
                            color: const Color.fromARGB(255, 133, 133, 133)),
                      ),
                      SizedBox(height: 10),

                      // NIC Field
                      TextFormField(
                        controller: nicController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'NIC',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(
                              255, 235, 235, 235), // Change fill color
                          filled: true, // Enable the fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                        ),
                        style: TextStyle(
                            color: const Color.fromARGB(
                                255, 133, 133, 133)), // Input text color
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your NIC';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      TextFormField(
                        controller: addressNoController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Address No',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(
                              255, 235, 235, 235), // Change fill color
                          filled: true, // Enable the fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                        ),
                        style: TextStyle(
                            color: const Color.fromARGB(
                                255, 133, 133, 133)), // Input text color
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Street Field
                      TextFormField(
                        controller: streetController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Street',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(
                              255, 235, 235, 235), // Change fill color
                          filled: true, // Enable the fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                        ),
                        style: TextStyle(
                            color: const Color.fromARGB(
                                255, 133, 133, 133)), // Input text color
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your street';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

// City Field
                      TextFormField(
                        controller: cityController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'City',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(
                              255, 235, 235, 235), // Change fill color
                          filled: true, // Enable the fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                        ),
                        style: TextStyle(
                            color: const Color.fromARGB(
                                255, 133, 133, 133)), // Input text color
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Pickup Date Field
                      TextFormField(
                        controller: pickupDateController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Date',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 37, 37, 37),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(
                              255, 255, 255, 255), // Change fill color
                          filled: true, // Enable the fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              color: Color(
                                  0xFF5FAD46), // Set your desired color here
                            ),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        style: TextStyle(
                            color: const Color.fromARGB(
                                255, 56, 56, 56)), // Input text color
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a pickup date';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

// Pickup Time Field
                      TextFormField(
                        controller: pickupTimeController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Time',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 37, 37, 37),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(
                              255, 255, 255, 255), // Change fill color
                          filled: true, // Enable the fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.access_time,
                              color: Color(
                                  0xFF5FAD46), // Set your desired color here
                            ),
                            onPressed: () => _selectTime(context),
                          ),
                        ),
                        style: TextStyle(
                            color: const Color.fromARGB(
                                255, 56, 56, 56)), // Input text color
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a pickup time';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      const Text(
                        'Waste Details',
                        style: TextStyle(
                          color: Color.fromARGB(255, 61, 61, 61),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // Waste Entries
                      ...wasteEntries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: entry['wasteType'],
                                  items: wasteTypes.map((String wasteType) {
                                    return DropdownMenuItem<String>(
                                      value: wasteType,
                                      child: Text(wasteType),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      entry['wasteType'] = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Type',
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 37, 37, 37),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    fillColor: Color.fromARGB(255, 255, 255,
                                        255), // Change fill color
                                    filled: true, // Enable the fill color
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(
                                              255, 236, 236, 236),
                                          width: 2.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: Color(0xFF27AE60), width: 2.0),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Bag Count',
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 37, 37, 37),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    fillColor: Color.fromARGB(255, 255, 255,
                                        255), // Change fill color
                                    filled: true, // Enable the fill color
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(
                                              255, 236, 236, 236),
                                          width: 2.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(
                                          color: Color(0xFF27AE60), width: 2.0),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      entry['bagCount'] = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter bag count';
                                    }
                                    return null;
                                  },
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 56, 56, 56), // Input text color
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Color(
                                      0xFF5FAD46), // Set your desired color here
                                ),
                                onPressed: () {
                                  setState(() {
                                    // Remove the current entry from the wasteEntries list
                                    wasteEntries.remove(entry);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      Container(
                        width: 90, // Set your desired width
                        height: 30, // Set your desired height
                        child: ElevatedButton(
                          onPressed: _addWasteEntry,
                          child: Text(
                            '+ Add',
                            style: TextStyle(
                              color: Colors.white, // Set text color to white
                              fontSize: 15, // Set your desired font size
                              fontWeight: FontWeight
                                  .w500, // Set your desired font weight
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                                0xFF5FAD46), // Set your desired background color here
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  18), // Set button curvy with a radius
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 50),
                      Container(
                        width: 200, // Set your desired width
                        height: 40, // Set your desired height
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white, // Set text color to white
                              fontSize: 16, // Set your desired font size
                              fontWeight: FontWeight
                                  .w700, // Set your desired font weight
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                                0xFF5FAD46), // Set your desired background color here
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  18), // Set button curvy with a radius
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
