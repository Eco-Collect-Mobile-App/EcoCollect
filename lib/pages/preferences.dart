import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/user_management/models/UserModel.dart';

const String apiKey =
    'AIzaSyA4U0iw952xWyUvk7_iwGjwccO2HLvFUDk'; //gemini API key

class UserGoals extends StatefulWidget {
  @override
  _UserGoalsState createState() => _UserGoalsState();
}

class _UserGoalsState extends State<UserGoals> {
  // List of predefined goals
  final List<String> goals = [
    'Reduce Plastic Waste',
    'Compost More',
    'Recycle More',
    'Use Less Water',
    'Reduce Carbon Footprint',
    'Support Local Products',
    'Use Renewable Energy',
  ];

  // To keep track of selected goals
  List<String> selectedGoals = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Goals'),
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
            Wrap(
              spacing: 10.0, // Space between chips
              children: goals.map((goal) {
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
              ),
              onPressed: () async {
                // Call the generate plan method when the button is pressed
                await generatePlan(selectedGoals);
              },
              child: const Text(
                'Generate Plan',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
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
          int bagCount = entry['bagCount'];
          var weight = entry['weight'] ?? 'N/A';
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

      // Navigate to the GeneratedPlanScreen to display the generated plan
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedPlanScreen(plan: generatedPlan),
        ),
      );
    } catch (e) {
      print("Error generating plan: $e");
    }
  }
}

// Separate screen to display the generated plan
class GeneratedPlanScreen extends StatelessWidget {
  final String plan;

  GeneratedPlanScreen({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Personalized Plan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            const Color(0xFF27AE60), // Add green color to the header
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(plan, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
