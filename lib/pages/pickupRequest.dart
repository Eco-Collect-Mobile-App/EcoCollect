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
        title: Text("Pickup Request"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: userIdController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'User ID'),
              ),
              TextFormField(
                controller: nicController, // New NIC field
                decoration: InputDecoration(labelText: 'NIC'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your NIC';
                  }
                  return null;
                },
              ),
              // Address fields
              TextFormField(
                controller: addressNoController, // New address number field
                decoration: InputDecoration(labelText: 'Address No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: streetController, // New street field
                decoration: InputDecoration(labelText: 'Street'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: cityController, // New city field
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: pickupDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Pickup Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a pickup date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: pickupTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Pickup Time',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a pickup time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              const Text(
                'Waste Types and Bag Counts:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: wasteEntries.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      // Waste Type Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: wasteEntries[index]["wasteType"],
                          decoration: const InputDecoration(
                            labelText: 'Waste Type',
                          ),
                          items: wasteTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              wasteEntries[index]["wasteType"] = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a waste type';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      // Bag Count Field
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Bag Count'),
                          onChanged: (value) {
                            setState(() {
                              wasteEntries[index]["bagCount"] =
                                  int.tryParse(value);
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the bag count';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            wasteEntries.removeAt(index);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: _addWasteEntry,
                child: const Text('Add Another Waste Entry'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
