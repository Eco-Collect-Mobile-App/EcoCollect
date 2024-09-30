import 'package:eco_collect/user_management/models/UserModel.dart';
import 'package:eco_collect/user_management/screens/authentication/authenticate.dart';
import 'package:eco_collect/user_management/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_collect/user_management/screens/authentication/loging.dart';
import 'package:eco_collect/user_management/screens/authentication/register.dart';
import 'package:eco_collect/pages/dashboard.dart';
import 'package:eco_collect/navigation_menu.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    // Return either Authenticate or the main app with NavigationMenu
    if (user == null) {
      return Authenticate(); // Redirect to authentication flow
    } else {
      return NavigationMenu(); // Redirect to main app with NavigationMenu
    }
  }
}
