import 'package:chargingtime/pages/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<void> saveUserLoggedInStatus(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<bool> getUserLoggedInStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> removeUserLoggedInStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }

  // Sign up with email & password
  Future<String?> signupUser(String email, String password, String name, String location) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Add user information to Firestore
      await _db.collection('users').doc(user!.uid).set({
        'name': name,
        'location': location,
        'email': email,
      });
      await loginUser(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return e.toString();
    }
  }

  // Sign in with email & password
  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await saveUserLoggedInStatus(true);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);

    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Sign out
  Future<void> logout() async {
    try{
      await _auth.signOut();
    }catch (e) {
      print('Error during logout: $e');
    } finally {
      await removeUserLoggedInStatus();
    }

  }


  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please enable it in the Firebase console.';
      default:
        return 'An unknown error occurred.';
    }
  }
  static Future<bool> isLoggedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

}
