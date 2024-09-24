import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eco_collect/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PickupReqUpdate extends StatefulWidget {
  final String requestId; // Pass the existing request ID to update
  final Map<String, dynamic>
      existingData; // New parameter to hold existing data

  const PickupReqUpdate({
    Key? key,
    required this.requestId,
    required this.existingData, // Accept existing data
  }) : super(key: key);

  @override
  _PickupReqUpdateState createState() => _PickupReqUpdateState();
}

class _PickupReqUpdateState extends State<PickupReqUpdate> {
  final _formKey = GlobalKey<FormState>();

  // Create an instance of FirebaseService
  final FirebaseService _firebaseService = FirebaseService();
  // Controllers for form fields
  TextEditingController userIdController = TextEditingController();
  TextEditingController pickupDateController = TextEditingController();
  TextEditingController pickupTimeController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  List<Map<String, dynamic>> wasteEntries = [];

  final List<String> wasteTypes = ["Organic", "Plastic", "Recyclable", "Other"];

  @override
  void initState() {
    super.initState();
    _setUserId();
    _loadExistingData(); // Load the existing request data
  }

  // Function to get the current user's UID
  void _setUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userIdController.text = user.uid;
      });
    }
  }

  // Function to load existing data from the passed existingData
  void _loadExistingData() {
    setState(() {
      pickupDateController.text = widget.existingData['pickupDate'] ?? '';
      pickupTimeController.text = widget.existingData['pickupTime'] ?? '';
      wasteEntries = List<Map<String, dynamic>>.from(
          widget.existingData['wasteEntries'] ?? []);
    });
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
      String userId = userIdController.text;
      String pickupDate = pickupDateController.text;
      String pickupTime = pickupTimeController.text;

      try {
        // Update the data in Firestore
        await _firebaseService.updateWasteData(
          requestId: widget.requestId,
          userId: userId,
          pickupDate: pickupDate,
          pickupTime: pickupTime,
          wasteEntries: wasteEntries,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form Updated Successfully')),
        );

        Navigator.pop(context); // Navigate back after updating
      } catch (e, stackTrace) {
        print('Failed to update form: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Update Form: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Pickup Request"),
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
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'No. of Bags'),
                          initialValue:
                              wasteEntries[index]["bagCount"]?.toString(),
                          onChanged: (value) {
                            setState(() {
                              wasteEntries[index]["bagCount"] =
                                  int.tryParse(value);
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter bag count';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid integer';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              TextButton(
                onPressed: _addWasteEntry,
                child: const Text('Add Another Waste Type'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
