import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:eco_collect/user_management/models/UserModel.dart'; // Ensure the correct import path

class Trucks extends StatelessWidget {
  const Trucks({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the UserModel from the provider
    final user = Provider.of<UserModel?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF27AE60), // Green color for the background
        title: const Text(
          'Locate a truck', // Title of the header
          style: TextStyle(
            fontWeight: FontWeight.bold, // Bold font weight
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification,
                color: Colors.white), // Notification icon
            onPressed: () {
              // Add your notification button action here
            },
          ),
          const SizedBox(
              width:
                  20), // Add spacing between the notification icon and the edge
        ],
      ),
      body: Center(
        child: user != null
            ? Text('User UID: ${user.uid}') // Display the UID
            : const Text('No user logged in'), // Display a message if no user
      ),
    );
  }
}
