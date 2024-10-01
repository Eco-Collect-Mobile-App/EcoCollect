import 'package:eco_collect/user_management/cocnstants/colors.dart';
import 'package:eco_collect/user_management/cocnstants/discription.dart';
import 'package:eco_collect/user_management/cocnstants/styles.dart';
import 'package:eco_collect/user_management/services/auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function toggle;
  const Register({Key? key, required this.toggle}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthServices _auth = AuthServices();

  //form key
  final _formKey = GlobalKey<FormState>();
  //email, password, phone, and address state
  String name = "";
  String email = "";
  String nic = "";
  String password = "";
  String phone = "";
  String addressNo = "";
  String street = "";
  String city = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title: const Text("REGISTER"),
        elevation: 0,
        backgroundColor: const Color(0XffE7EBE8),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 10),
          child: Column(
            children: [
              const Text(
                description,
                style: descriptionStyle,
              ),
              Center(
                child: Image.asset(
                  "assets/images/ecologo2.png",
                  height: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      //name field
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: TextInputDecorarion.copyWith(
                          hintText: "Name",
                        ),
                        validator: (val) =>
                            val!.isEmpty ? "Please Enter your name" : null,
                        onChanged: (val) {
                          setState(() {
                            name = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      //email field
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: TextInputDecorarion.copyWith(
                          hintText: "Email",
                        ),
                        validator: (val) => val!.isEmpty
                            ? "Enter a valid username or email"
                            : null,
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: TextInputDecorarion.copyWith(
                          hintText: "NIC",
                        ),
                        validator: (val) =>
                            val!.isEmpty ? "Enter valid NIC" : null,
                        onChanged: (val) {
                          setState(() {
                            nic = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      //password field
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: TextInputDecorarion.copyWith(
                          hintText: "Password",
                        ),
                        validator: (val) => val!.length < 6
                            ? "Enter a password 6+ chars long"
                            : null,
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      //phone number field
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: TextInputDecorarion.copyWith(
                          hintText: "Phone Number",
                        ),
                        validator: (val) =>
                            val!.isEmpty ? "Enter a valid phone number" : null,
                        onChanged: (val) {
                          setState(() {
                            phone = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      //address fields (No, Street, City)
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: TextInputDecorarion.copyWith(
                          hintText: "Address No.",
                        ),
                        validator: (val) => val!.isEmpty
                            ? "Enter a valid address number"
                            : null,
                        onChanged: (val) {
                          setState(() {
                            addressNo = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: TextInputDecorarion.copyWith(
                          hintText: "Street",
                        ),
                        validator: (val) =>
                            val!.isEmpty ? "Enter a valid street" : null,
                        onChanged: (val) {
                          setState(() {
                            street = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: TextInputDecorarion.copyWith(
                          hintText: "City",
                        ),
                        validator: (val) =>
                            val!.isEmpty ? "Enter a valid city" : null,
                        onChanged: (val) {
                          setState(() {
                            city = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      //error text
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),

                      //switch to login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: descriptionStyle,
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              widget.toggle();
                            },
                            child: const Text(
                              "LOGIN",
                              style: TextStyle(
                                color: mainBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      //button
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            dynamic result =
                                await _auth.registerWithEmailAndPassword(
                                    name,
                                    email,
                                    nic,
                                    password,
                                    phone,
                                    addressNo,
                                    street,
                                    city);
                            if (result == null) {
                              setState(() {
                                error = "Please enter a valid email";
                              });
                            }
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 200,
                          decoration: BoxDecoration(
                            color: const Color(0Xff5FAD46),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 2, color: mainYellow),
                          ),
                          child: const Center(
                            child: Text(
                              "REGISTER",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
