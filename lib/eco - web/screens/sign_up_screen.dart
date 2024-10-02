import 'package:eco_collect/eco%20-%20web/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text;
                String password = _passwordController.text;

                var user = await _authService.signUpWithEmailAndPassword(
                    email, password);

                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  // Handle error
                }
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
