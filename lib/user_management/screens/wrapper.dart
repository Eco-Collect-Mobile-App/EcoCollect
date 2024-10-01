import 'package:eco_collect/user_management/models/UserModel.dart';
import 'package:eco_collect/user_management/screens/authentication/authenticate.dart';
import 'package:eco_collect/user_management/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_collect/user_management/screens/authentication/loging.dart';
import 'package:eco_collect/user_management/screens/authentication/register.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
