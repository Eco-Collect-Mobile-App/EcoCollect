import 'package:flutter/material.dart';
import 'package:eco_collect/service/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';

// complaintsForm widget represents the main form screen for submitting complaints
class ComplaintsForm extends StatefulWidget {
  const ComplaintsForm({super.key});

  @override
  State<ComplaintsForm> createState() => _ComplaintsFormState();
}

// The state for the ComplaintsForm widget
class _ComplaintsFormState extends State<ComplaintsForm> {

  // Controllers for various form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController describeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  String? issueType = 'Select Issue Type'; // Holds the selected complaint type

  // Dropdown options for complaint types
  List<String> issueTypes = [
    'Select Issue Type',
    'Missed collection',
    'Late collection',
    'Improper waste handling',
    'Damaged property',
    'Rude behavior',
    'Other',
  ];

  String issueDescription = ''; // Holds the complaint description

  DateTime? selectedDate; // Holds the selected date
  String formattedDate = "Select Date"; // Holds the formatted date string
  String? currentUserId; // Holds the current user's ID

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // Fetch the current user ID when the form initializes
  }

  // Fetch the current user ID and set email using Firebase authentication
  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser; 
    setState(() {
      currentUserId = user?.uid; // Set the user ID
      emailController.text = user?.email ?? ''; // Set the user email
    });
  }

  // Function to open the date picker and set the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), // Earliest date the user can pick
      lastDate: DateTime.now(),  // Latest date the user can pick
    );

    // If a date is selected, update the selectedDate and format the string
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!); // Format the date
        dateController.text = formattedDate; // Set the selected date in the controller
      });
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
              child: Text(
                "Complaints Form",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.notifications, color: Colors.white)
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Submit your complaint and we’ll get back to you as soon as possible to address the issue.",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),

              // Contact Name input field
              const Text(
                "Contact Name",
                style: TextStyle(
                    color: Color.fromARGB(182, 0, 0, 0),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),

              // Contact Email input field
              const Text(
                "Contact Email",
                style: TextStyle(
                    color: Color.fromARGB(182, 0, 0, 0),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),

              // Complaint Type dropdown
              const Text(
                "Type of complaint",
                style: TextStyle(
                  color: Color.fromARGB(182, 0, 0, 0),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  value: issueType, // Set the initial value
                  items: issueTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      issueType = newValue; // Update the selected value
                      typeController.text = newValue!; // Manually set the selected value in typeController
                    });
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // Describe the Issue input field
              const Text(
                "Describe the Issue",
                style: TextStyle(
                  color: Color.fromARGB(182, 0, 0, 0),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller : describeController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Please describe the issue in detail...",
                    hintStyle: TextStyle(color: Colors.grey,),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Store the description input
                      issueDescription = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // Location input field
              const Text(
                "Location",
                style: TextStyle(
                    color: Color.fromARGB(182, 0, 0, 0),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller : locationController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),

              // Date Picker
              const Text(
                "Date",
                style: TextStyle(
                    color: Color.fromARGB(182, 0, 0, 0),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5.0),
              GestureDetector(
                onTap: () => _selectDate(context), // Opens the date picker
                child: Container(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateController.text.isEmpty ? "Select Date" : dateController.text, // Display the selected date from the controller
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today), 
                        onPressed: () => _selectDate(context), // Triggers date picker
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Submit Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5FAD46),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        typeController.text.isEmpty ||
                        describeController.text.isEmpty ||
                        locationController.text.isEmpty ||
                        dateController.text.isEmpty) {
                      // Show toast if any field is empty
                      Fluttertoast.showToast(
                        msg: "Please fill all the fields.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      return;
                    }

                    String complaintId = 'com${randomAlphaNumeric(3).padLeft(3, '0')}'; // Custom ID generation logic
                    // Call the method to save complaint in the database
                    Map<String, dynamic> complaintsInfoMap = {
                      "userId": currentUserId,
                      "Id": complaintId,
                      "Name": nameController.text,
                      "Email": emailController.text,
                      "Type": typeController.text,
                      "Description": describeController.text,
                      "Location": locationController.text,
                      "Date": dateController.text,
                      "Status": "pending"
                    };

                    try {
                      await DatabaseMethods().addComplaintsDetails(complaintsInfoMap, complaintId);
                      Fluttertoast.showToast(
                        msg: "Complaint submitted successfully!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );

                      // Clear all fields
                      nameController.clear();
                      emailController.clear();
                      typeController.clear();
                      describeController.clear();
                      locationController.clear();
                      dateController.clear();
                      setState(() {
                        issueType = 'Select Issue Type';
                        formattedDate = "Select Date";
                        selectedDate = null;
                      });
                      
                    } catch (error) {
                      // Show success toast
                      Fluttertoast.showToast(
                        msg: "Error submitting complaint. Please try again.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },

                  child: const Text("Submit Complaint", style: TextStyle(
                  color: Colors.white, 
                  fontSize: 18.0, 
                  fontWeight: FontWeight.bold),),
                ),
              ),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}
