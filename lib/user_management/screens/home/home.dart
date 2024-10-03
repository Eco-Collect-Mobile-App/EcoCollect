import 'package:eco_collect/user_management/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:eco_collect/user_management/screens/home/profile.dart'; // Import the Profile widget
import 'package:eco_collect/pages/trucks.dart'; // Import the Trucks widget
import 'package:eco_collect/pages/pickupRequest.dart'; // Import the PickupRequestPage widget

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Create an instance of AuthServices
  final AuthServices _auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: const Color(0Xff27AE60),
        actions: [
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                Color(0Xff27AE60),
              ),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
            child: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const Text(
                "HOME",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 30),
              // Display the user's UID
              FutureBuilder<String?>(
                future: _auth
                    .getUserUid(), // Use the method that returns Future<String?>
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    return Text(
                      'User UID: ${snapshot.data}',
                      style: TextStyle(fontSize: 18),
                    );
                  } else {
                    return Text('No user logged in');
                  }
                },
              ),
              const SizedBox(height: 60),
              Center(
                child: Image.asset(
                  "assets/images/man.png",
                  height: 200,
                ),
              ),
              // Add a button to navigate to the profile page
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile()), // Correct usage
                  );
                },
                child: const Text("Go to Profile"),
              ),
              const SizedBox(height: 20), // Add spacing between buttons
              // Add a new button to navigate to the Trucks page
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Trucks page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Trucks()), // Correct usage
                  );
                },
                child: const Text("Go to Trucks"),
              ),
              const SizedBox(height: 20), // Add spacing between buttons
              // Add a new button to navigate to the Pickup Requests page
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Pickup Request page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PickupRequest()), // Navigate to PickupRequestPage
                  );
                },
                child: const Text("Pickup Requests"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
