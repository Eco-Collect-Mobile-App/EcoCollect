import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/user_management/models/UserModel.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const String apiKey =
    'AIzaSyA4U0iw952xWyUvk7_iwGjwccO2HLvFUDk'; // Gemini API key

class UserGoals extends StatefulWidget {
  @override
  _UserGoalsState createState() => _UserGoalsState();
}

class _UserGoalsState extends State<UserGoals> {
  // List of predefined goals
  final List<String> predefinedGoals = [
    'Reduce Plastic Waste',
    'Compost More',
    'Recycle More',
    'Reduce Carbon Footprint',
    'Support Local Products',
    'Use Renewable Energy',
  ];

  // To keep track of selected goals and dynamically added custom goals
  List<String> allGoals = [];
  List<String> selectedGoals = [];
  String customGoal = '';

  @override
  void initState() {
    super.initState();
    // Initialize allGoals with predefinedGoals
    allGoals = List.from(predefinedGoals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Goals',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF27AE60), // Green color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select the goals you want to focus on:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Row for TextField and Plus Icon Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Add Your Goals',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        customGoal = value;
                      });
                    },
                  ),
                ),

                const SizedBox(
                    width: 10), // Spacing between TextField and button

                // Container to set the background color of the IconButton with rounded corners
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF5FAD46), // Set the background color
                    borderRadius: BorderRadius.circular(
                        8), // Adjust the radius for rounded corners
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add,
                        color: Colors.white), // White plus icon
                    onPressed: () {
                      if (customGoal.isNotEmpty &&
                          !allGoals.contains(customGoal)) {
                        setState(() {
                          // Add the custom goal to the list of selectable goals
                          allGoals.add(customGoal);
                          selectedGoals
                              .add(customGoal); // Automatically select it
                          customGoal = ''; // Clear the input after adding
                        });
                      }
                    },
                    tooltip: 'Add Goal', // Tooltip for the button
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Display goals using FilterChips (both predefined and custom)
            Wrap(
              spacing: 10.0, // Space between chips
              children: allGoals.map((goal) {
                return FilterChip(
                  label: Text(goal),
                  selected: selectedGoals.contains(goal),
                  selectedColor: Colors.green.withOpacity(0.5),
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.grey.shade200,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedGoals.add(goal);
                      } else {
                        selectedGoals.remove(goal);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Button to generate the plan
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5FAD46),
              ),
              onPressed: () async {
                // Call the generate plan method when the button is pressed
                await generatePlan(selectedGoals);
              },
              child: const Text(
                'Generate Plan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to generate the personalized waste management plan
  Future<void> generatePlan(List<String> selectedGoals) async {
    try {
      if (selectedGoals.isEmpty) {
        print("No goals selected.");
        return;
      }

      // Fetch user from the Provider (assuming it's available globally)
      final user = Provider.of<UserModel?>(context, listen: false);
      final String? uid = user?.uid;

      if (uid == null) {
        print("No user found.");
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(), // Loading spinner
              SizedBox(width: 20), // Spacing between spinner and text
              Text("Generating your plan..."), // Loading text
            ],
          ),
        ),
      );

      // Fetch pickup records for the past 7 days
      DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("wasteData")
          .where('userId', isEqualTo: uid)
          .where('pickupDate',
              isGreaterThanOrEqualTo:
                  DateFormat('yyyy-MM-dd').format(sevenDaysAgo))
          .get();

      List<String> pickupRecords = [];

      // Format the pickup records into a readable string
      for (var doc in querySnapshot.docs) {
        String pickupDate = doc['pickupDate'];
        List wasteEntries = doc['wasteEntries'];

        for (var entry in wasteEntries) {
          String wasteType = entry['wasteType'];
          int bagCount = int.tryParse(entry['bagCount'].toString()) ??
              0; // Handle non-integer values
          var weight = entry['weight'] != null
              ? entry['weight'].toString()
              : 'N/A'; // Ensure weight is a string
          pickupRecords.add(
              'Date: $pickupDate, Waste Type: $wasteType, Bag Count: $bagCount, Weight: $weight');
        }
      }

      // Construct the prompt with both goals and pickup records
      String goalsString = selectedGoals.join(', ');
      String recordsString = pickupRecords.isNotEmpty
          ? pickupRecords.join('; ')
          : 'No recent pickup records found.';

      String prompt =
          "Based on the following environmental goals: $goalsString and the user's past 7 days of waste collection: $recordsString, please generate a personalized waste management plan.";

      // Log the prompt to the console
      print("Prompt sent to Gemini API: $prompt");

      // Create the generative model with your API key
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // Update to the appropriate model name
        apiKey: apiKey,
      );

      // Generate the response using the prompt
      final response = await model.generateContent([Content.text(prompt)]);

      // Handle the response (printing for now, but you can navigate to a new screen to display)
      String generatedPlan = response.text ?? 'No plan was generated.';

      // Save the plan to Firestore
      await FirebaseFirestore.instance.collection('savedPlans').add({
        'userId': uid,
        'plan': generatedPlan,
        'dateGenerated': DateTime.now(),
      });

      print("Plan saved to Firestore.");

      // Dismiss the loading dialog
      Navigator.of(context).pop(); // Dismiss the loading dialog

      // Navigate to the GeneratedPlanScreen to display the generated plan
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedPlanScreen(plan: generatedPlan),
        ),
      );
    } catch (e) {
      print("Error generating plan: $e");
      Navigator.of(context).pop(); // Dismiss the loading dialog on error
    }
  }
}

// Separate screen to display the generated planclass GeneratedPlanScreen extends StatelessWidget
class GeneratedPlanScreen extends StatelessWidget {
  final String plan;

  GeneratedPlanScreen({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Personalized Plan',
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () {
                _downloadPDF(plan); // Trigger the PDF download
              },
              tooltip: 'Download PDF',
            ),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60), // Green color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(plan, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // Method to generate and download the PDF
  Future<void> _downloadPDF(String plan) async {
    final pdf = pw.Document();

    // Create the PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Text(
              plan,
              style: pw.TextStyle(fontSize: 14),
            ),
          );
        },
      ),
    );

    // Download the generated PDF using the Printing package
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
