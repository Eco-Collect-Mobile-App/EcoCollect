import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eco_collect/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PickupReqUpdate extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> existingData;

  const PickupReqUpdate({
    Key? key,
    required this.requestId,
    required this.existingData,
  }) : super(key: key);

  @override
  _PickupReqUpdateState createState() => _PickupReqUpdateState();
}

class _PickupReqUpdateState extends State<PickupReqUpdate> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  // Controllers for form fields
  TextEditingController userIdController = TextEditingController();
  TextEditingController pickupDateController = TextEditingController();
  TextEditingController pickupTimeController = TextEditingController();
  TextEditingController nicController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  List<Map<String, dynamic>> wasteEntries = [];
  final List<String> wasteTypes = ["Organic", "Plastic", "Recyclable", "Other"];

  @override
  void initState() {
    super.initState();
    _setUserId();
    _loadExistingData();
  }

  void _setUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userIdController.text = user.uid;
      });
    }
  }

  void _loadExistingData() {
    setState(() {
      pickupDateController.text = widget.existingData['pickupDate'] ?? '';
      pickupTimeController.text = widget.existingData['pickupTime'] ?? '';
      nicController.text = widget.existingData['nic'] ?? '';
      addressController.text = widget.existingData['address'] ?? '';
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

  void _removeWasteEntry(int index) {
    setState(() {
      wasteEntries.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String userId = userIdController.text;
      String pickupDate = pickupDateController.text;
      String pickupTime = pickupTimeController.text;
      String nic = nicController.text;
      String address = addressController.text;

      try {
        await _firebaseService.updateWasteData(
          requestId: widget.requestId,
          userId: userId,
          pickupDate: pickupDate,
          pickupTime: pickupTime,
          wasteEntries: wasteEntries,
          nic: nic,
          address: address,
        );

        _showSnackBar('Form Updated Successfully');

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        print('Failed to update form: $e');
        _showSnackBar('Failed to Update Form: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        title: const Text("Update Pick-up Request",
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
                      SizedBox(height: 15),
                      TextFormField(
                        controller: addressController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Address',
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
                            return 'Please enter Address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                      SizedBox(height: 16),
                      TextFormField(
                        controller: pickupTimeController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Time',
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
                      SizedBox(height: 16),
                      const Text(
                        'Waste Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color.fromARGB(255, 58, 58, 58)),
                      ),
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: wasteEntries.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: wasteEntries[index]["wasteType"],
                                  decoration: const InputDecoration(
                                    labelText: 'Type',
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 37, 37, 37),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
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
                                  items: wasteTypes.map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      wasteEntries[index]["wasteType"] =
                                          newValue;
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
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Bag Count',
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 37, 37, 37),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
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
                                  initialValue: wasteEntries[index]["bagCount"]
                                      ?.toString(),
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
                                      return 'Enter valid number';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 56, 56, 56),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color(0xFF5FAD46),
                                ),
                                onPressed: () => _removeWasteEntry(index),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 10),
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
                            backgroundColor: Color(0xFF5FAD46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 150),
                      Container(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(
                            'Update Request',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5FAD46),
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
