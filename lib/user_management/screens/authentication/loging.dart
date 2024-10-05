import 'package:eco_collect/user_management/cocnstants/colors.dart';
import 'package:eco_collect/user_management/cocnstants/discription.dart';
import 'package:eco_collect/user_management/cocnstants/styles.dart';
import 'package:eco_collect/user_management/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:eco_collect/user_management/screens/authentication/register.dart';

class Sign_In extends StatefulWidget {
  final Function toggle;
  const Sign_In({Key? key, required this.toggle}) : super(key: key);

  @override
  State<Sign_In> createState() => _Sign_InState();
}

class _Sign_InState extends State<Sign_In> {
  final AuthServices _auth = AuthServices();
  bool _obscurePassword = true;

  //form key
  final _formKey = GlobalKey<FormState>();
  //email password state
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title: const Text("SIGN IN"),
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
                "assets/images/icon.png",
                height: 200,
              )),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        //email
                        TextFormField(
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0)),
                          decoration: const InputDecoration(
                            hintText: "E-mail or Username",
                          ),
                          validator: (val) => val?.isEmpty == true
                              ? "Enter the valid username or email"
                              : null,
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                        ),
                        //password
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          decoration: InputDecoration(
                            hintText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText:
                              _obscurePassword, // Hide or show the password
                          validator: (val) => val != null && val.length < 6
                              ? "Enter a valid password"
                              : null,
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        //google
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        ),
                        //google
                        const Text("Loging with social accounts",
                            style: descriptionStyle),
                        GestureDetector(
                          //sign in with google
                          onTap: () {},
                          child: Center(
                              child: Image.asset(
                            "assets/images/google.png",
                            height: 50,
                          )),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        //register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Do not have account",
                                style: descriptionStyle),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              //go to the registr page
                              onTap: () {
                                widget.toggle();
                              },
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                    color: mainBlue,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //button
                        GestureDetector(
                          //method fro loging user
                          onTap: () async {
                            dynamic result = await _auth
                                .signInUsingEmailAndPassword(email, password);
                            if (result == null) {
                              setState(() {
                                error = "User not found";
                              });
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
                                child: const Text(
                              "LOG IN",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.w500),
                            )),
                          ),
                        )
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
