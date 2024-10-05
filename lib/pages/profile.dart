import 'package:eco_collect/user_management/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:eco_collect/user_management/screens/home/update.dart'; // Import the update page

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

  // Function to handle delete profile
  Future<void> _deleteProfile(BuildContext context) async {
    String? password = await _showPasswordConfirmationDialog(context);

    if (password != null) {
      // Authenticate the user with their password
      bool isPasswordCorrect = await _auth.reauthenticateUser(password);

      if (isPasswordCorrect) {
        // Delete the user profile
        await _auth.deleteUser();

        // Navigate to the login page after deletion
        Navigator.pop(context, true);
      } else {
        // Show error message if password is incorrect
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect password!')),
        );
      }
    }
  }

  // Show a dialog to confirm the password
  Future<String?> _showPasswordConfirmationDialog(BuildContext context) async {
    String? password;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter your password to delete profile'),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            onChanged: (value) {
              password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(password);
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title:
            const Text('User Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0Xff27AE60),
        actions: [
          // Logout button
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(const Color(0Xff27AE60)),
            ),
            onPressed: () async {
              await _auth.signOut(); // Logout functionality
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
                  Center(
                    child: Image.asset("assets/images/man.png", height: 150),
                  ),
                  const SizedBox(height: 30),
                  Text('Name: $name',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Email: $email',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('NIC: $nic',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Phone: $phone', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Address: $addressNo, $street, $city',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to the UpdateProfile page and wait for result
                      bool? updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProfile(
                            userData: {
                              'name': name,
                              'email': email,
                              'nic': nic,
                              'phone': phone,
                              'addressNo': addressNo,
                              'street': street,
                              'city': city,
                            },
                          ),
                        ),
                      );

                      // If the profile was updated, reload the data
                      if (updated == true) {
                        _loadUserData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Update Profile',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  // Delete Profile Button
                  ElevatedButton(
                    onPressed: () {
                      _deleteProfile(context); // Call delete function
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Delete Profile',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
