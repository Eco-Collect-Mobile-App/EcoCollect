import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditComplaintPage extends StatefulWidget {
  final String currentUserId;
  final String complaintId;
  final String name;
  final String email;
  final String date;
  final String description;
  final String location;
  final String status;

  EditComplaintPage({
    required this.currentUserId,
    required this.complaintId,
    required this.name,
    required this.email,
    required this.date,
    required this.description,
    required this.location,
    required this.status,
  });

  @override
  _EditComplaintPageState createState() => _EditComplaintPageState();
}

class _EditComplaintPageState extends State<EditComplaintPage> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Text controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late String _status;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the values passed from the previous page
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _dateController = TextEditingController(text: widget.date);
    _descriptionController = TextEditingController(text: widget.description);
    _locationController = TextEditingController(text: widget.location);
    _status = widget.status; // Set the initial status from the passed value
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources when page is destroyed
    _nameController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Function to handle the complaint update logic
  void _updateComplaint() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Fetch complaint data from Firestore to ensure correct user is editing it
    var complaintDoc = await FirebaseFirestore.instance
        .collection('Complaints')
        .doc(widget.complaintId)
        .get();

    // Check if the current user is the owner of the complaint
    String complaintUserId = complaintDoc.data()?['userId'];
    print("Checking user IDs: complaintUserId = $complaintUserId, currentUserId = ${widget.currentUserId}");

    // If the current user owns the complaint, allow the update
    if (complaintUserId.trim() == widget.currentUserId.trim()) {
      // Create a map of updated complaint data
      final updatedData = {
        'Name': _nameController.text,
        'Email': _emailController.text,
        'Date': _dateController.text,
        'Description': _descriptionController.text,
        'Location': _locationController.text,
        'Status': _status,
      };

      try {
        // Update the complaint in Firestore
        await FirebaseFirestore.instance
            .collection('Complaints')
            .doc(widget.complaintId)
            .update(updatedData);

        Navigator.pop(context, true); // Return true if update is successful
      } catch (e) {
        // Show error message if the update fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update complaint. Please try again.')),
        );
      }
    } else {
      // Show error if the user is not authorized to edit this complaint
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You are not authorized to edit this complaint.')),
      );
    }
  }
}

  // Function to handle date selection using a date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date is today
      firstDate: DateTime(2020), // Set the minimum selectable date
      lastDate: DateTime.now(), // Maximum selectable date is today
    );

    if (picked != null) {
      setState(() {
        // Format the selected date and display it in the date field
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
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
              // Title
              child: Text(
                "Edit Complaint",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.notifications, color: Colors.white) // Notification icon
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the form
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Update your complaint and we'll process the changes.",
                  style: TextStyle(fontSize: 18.0, color: Colors.black54),
                ),
                const SizedBox(height: 20.0),
                _buildTextField(_nameController, "Name"), // Name input field
                const SizedBox(height: 20.0),
                _buildTextField(_emailController, "Email"), // Email input field
                const SizedBox(height: 20.0),
                _buildDateField("Date", context), // Date picker field
                const SizedBox(height: 20.0),
                _buildTextField(_descriptionController, "Description",
                    maxLines: 4), // Description input field (multiline)
                const SizedBox(height: 20.0),
                _buildTextField(_locationController, "Location"), // Location input field
                const SizedBox(height: 30.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateComplaint, // Call update function on press
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5FAD46),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                    ),
                    child: const Text(
                      "Update Complaint",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build a text field
  Widget _buildTextField(TextEditingController controller, String labelText,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
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
            controller: controller,
            maxLines: maxLines,
            decoration: const InputDecoration(border: InputBorder.none),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $labelText'; // Validation message
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // Helper widget to build a date picker field
  Widget _buildDateField(String labelText, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
              color: Color.fromARGB(182, 0, 0, 0),
              fontSize: 20.0,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5.0),
        GestureDetector(
          onTap: () => _selectDate(context), // Open date picker on tap
          child: Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date controller
                Text(
                  _dateController.text.isEmpty
                      ? "Select Date"
                      : _dateController.text,
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
