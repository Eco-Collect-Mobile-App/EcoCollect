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
  final FirebaseService _firebaseService = FirebaseService();

  TextEditingController userIdController = TextEditingController();
  TextEditingController nicController = TextEditingController();
  TextEditingController addressNoController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pickupDateController = TextEditingController();
  TextEditingController pickupTimeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  List<Map<String, dynamic>> wasteEntries = [
    {"wasteType": null, "bagCount": null, "weight": null}
  ];

  final List<String> wasteTypes = ["Organic", "Plastic", "Recyclable", "Other"];

  Set<String> selectedWasteTypes = Set<String>();

  @override
  void initState() {
    super.initState();
    _setUserId();
  }

  void _setUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userIdController.text = user.uid;
      });

      var userData = await _firebaseService.getUserData(user.uid);
      if (userData != null) {
        nicController.text = userData['nic'] ?? '';
        addressNoController.text = userData['addressNo'] ?? '';
        streetController.text = userData['street'] ?? '';
        cityController.text = userData['city'] ?? '';
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
      String userId = userIdController.text;
      String nic = nicController.text;
      String address =
          '${addressNoController.text}, ${streetController.text}, ${cityController.text}';
      String pickupDate = pickupDateController.text;
      String pickupTime = pickupTimeController.text;

      try {
        await _firebaseService.addWasteData(
          userId: userId,
          pickupDate: pickupDate,
          pickupTime: pickupTime,
          wasteEntries: wasteEntries,
          nic: nic,
          address: address,
        );

        pickupDateController.clear();
        pickupTimeController.clear();
        nicController.clear();
        addressNoController.clear();
        streetController.clear();
        cityController.clear();
        setState(() {
          wasteEntries = [
            {"wasteType": null, "bagCount": null, "weight": null}
          ];
          selectedWasteTypes.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form Submitted Successfully')),
        );
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
                          fillColor: Color.fromARGB(255, 235, 235, 235),
                          filled: true,
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
                        style: const TextStyle(
                            color: Color.fromARGB(255, 133, 133, 133)),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: nicController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'NIC',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(255, 235, 235, 235),
                          filled: true,
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
                        style: const TextStyle(
                            color: Color.fromARGB(255, 133, 133, 133)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your NIC';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: addressNoController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Address No',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(255, 235, 235, 235),
                          filled: true,
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
                        style: const TextStyle(
                            color: Color.fromARGB(255, 133, 133, 133)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: streetController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Street',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(255, 235, 235, 235),
                          filled: true,
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
                        style: const TextStyle(
                            color: Color.fromARGB(255, 133, 133, 133)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your street';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: cityController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 69, 69, 69),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(255, 235, 235, 235),
                          filled: true,
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
                        style: const TextStyle(
                            color: Color.fromARGB(255, 133, 133, 133)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: pickupDateController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Date',
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 37, 37, 37),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF5FAD46),
                            ),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 56, 56, 56)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a pickup date';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: pickupTimeController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Time',
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 37, 37, 37),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                          fillColor: Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 236, 236, 236),
                                width: 2.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                                color: Color(0xFF27AE60), width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.access_time,
                              color: Color(0xFF5FAD46),
                            ),
                            onPressed: () => _selectTime(context),
                          ),
                        ),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 56, 56, 56)),
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
                                      enabled: !selectedWasteTypes
                                              .contains(wasteType) ||
                                          wasteType == entry['wasteType'],
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      if (entry['wasteType'] != null) {
                                        selectedWasteTypes
                                            .remove(entry['wasteType']);
                                      }
                                      entry['wasteType'] = value;
                                      if (value != null) {
                                        selectedWasteTypes.add(value);
                                      }
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Type',
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 37, 37, 37),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    fillColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    filled: true,
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
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
                                  decoration: const InputDecoration(
                                    labelText: 'Bag Count',
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 37, 37, 37),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    fillColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    filled: true,
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
                                    if (int.tryParse(value) == null) {
                                      return 'Please enter a valid integer';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 56, 56, 56),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color(0xFF5FAD46),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (entry['wasteType'] != null) {
                                      selectedWasteTypes
                                          .remove(entry['wasteType']);
                                    }
                                    wasteEntries.remove(entry);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Container(
                        width: 90,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: _addWasteEntry,
                          child: Text(
                            '+ Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5FAD46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Container(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5FAD46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
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
