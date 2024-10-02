import 'package:eco_collect/user_management/services/auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthServices _auth = AuthServices();
  String? name, email, nic, phone, addressNo, street, city;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      Map<String, dynamic>? userData = await _auth.getUserData(uid);

      if (userData != null) {
        setState(() {
          name = userData['name'];
          email = userData['email'];
          nic = userData['nic'];
          phone = userData['phone'];
          addressNo = userData['addressNo'];
          street = userData['street'];
          city = userData['city'];
        });
      }
    }
  }

  Future<void> _deleteProfile() async {
    print("Profile deleted");
  }

  Future<void> _updateProfile() async {
    print("Profile update");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0Xff27AE60),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(const Color(0Xff27AE60)),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
            child: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: email == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display Profile Image
                  Center(
                    child: Image.asset(
                      "assets/images/man.png",
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Name: $name',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: $email',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'NIC: $nic',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Phone: $phone',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Address: $addressNo, $street, $city',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),

                  // Update Profile Button
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Delete Profile Button
                  ElevatedButton(
                    onPressed: _deleteProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Delete Profile',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
