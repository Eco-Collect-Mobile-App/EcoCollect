import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_collect/user_management/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  //firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //create a user from firebase user with uid
  UserModel? _userWithFirebaeUserUid(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // create the stram for checking the auth cahnges in the user
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userWithFirebaeUserUid);
  }

  //register using email and password
  // Register using email and password and save additional details
  Future registerWithEmailAndPassword(
      String name,
      String email,
      String nic,
      String password,
      String phone,
      String addressNo,
      String street,
      String city) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Save additional user details in Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'nic': nic,
        'phone': phone,
        'addressNo': addressNo,
        'street': street,
        'city': city,
      });

      return _userWithFirebaeUserUid(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  // Getter for current user
  User? get currentUser {
    return _auth.currentUser;
  }

  //sign in using email and password

  Future signInUsingEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userWithFirebaeUserUid(user);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  //sign in using gmail

  // Get the current user's email
  String? getCurrentUserEmail() {
    User? user = _auth.currentUser;
    return user?.email;
  }

  // Method to get UID as Future
  Future<String?> getUserUid() async {
    return _auth.currentUser?.uid;
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (err) {
      print(err.toString());
      return null;
    }
  }
}
