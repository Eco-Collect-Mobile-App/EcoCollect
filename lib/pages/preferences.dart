import 'package:flutter/material.dart';

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
              onPressed: () {
                // You can navigate back or handle goal saving here
                Navigator.pop(context, selectedGoals);
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
}
