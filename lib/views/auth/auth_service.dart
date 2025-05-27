import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// sign up
  static Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
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
          'phone': phone ?? '',
          'createdAt': Timestamp.now(),
        });
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

  // login
  static Future<String?> login(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return null; // success
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Login failed: ${e.message}';
    }
  } catch (e) {
    return 'An unknown error occurred.';
  }
}
// log out
 static Future<void> signOut() async {
    await _auth.signOut();
  }
}
