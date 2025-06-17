import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // sign up
  static Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'passenger',
          'status': 'active',
          'createdAt': Timestamp.now(),
        });
        await OneSignal.login(user.uid);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during signUp: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error during signUp: $e');
      return false;
    }
  }

  static Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      User? user = userCredential.user;
      if (user != null) {
        await OneSignal.login(user.uid);
      }

      return userCredential; // Return the UserCredential on success
    } on FirebaseAuthException catch (e) {
      // Re-throw the FirebaseAuthException so LoginPage can catch it
      // and display the specific error message.
      rethrow;
    } catch (e) {
      // For any other unexpected errors, re-throw a custom exception
      // or a generic message.
      print("AuthService: An unknown error occurred during login: $e");
      rethrow;
    }
  }

  // log out
  static Future<void> signOut() async {
    await _auth.signOut();
    OneSignal.logout();
  }
}
