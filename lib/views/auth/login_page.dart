import 'package:carpooling/themes/costum_reusable.dart';
import 'package:carpooling/widgets/main_navigator.dart'; // For regular users
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart'; // Your AuthService
import '../admin/admin_dashboard_page.dart'; // Import the AdminDashboardPage
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase User
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false; // loading flag
  bool _isPasswordVisible = false; // New state variable for password visibility

  // Declare controllers as StatefulWidget members so they persist
  // and are disposed correctly.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up memory
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- New method to check user role ---
  Future<String?> _getUserRole(User? user) async {
    if (user == null) return null;
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        // Assuming 'role' is a field in your user document in Firestore
        return (userDoc.data() as Map<String, dynamic>)['role'] as String?;
      }
      return null; // User document not found or no role field
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }
  // --- End new method ---

  // --- Modified method for Forgot Password Dialog ---
  void _showForgotPasswordDialog(BuildContext context) {
    // Pre-populate the reset email field with the current email controller's text
    final TextEditingController resetEmailController =
        TextEditingController(text: emailController.text.trim());

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Reset Password'),
              onPressed: () async {
                String email = resetEmailController.text.trim();
                if (email.isEmpty) {
                  showErrorSnackbar(context, "Please enter your email address.");
                  return;
                }
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.of(dialogContext).pop();
                  showSuccessSnackbar(context, "Password reset email sent to $email. Check your inbox.");
                } on FirebaseAuthException catch (e) {
                  showErrorSnackbar(context, e.message ?? "Failed to send reset email.");
                } catch (e) {
                  showErrorSnackbar(context, "An unexpected error occurred.");
                  print("Forgot password error: $e");
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      resetEmailController.dispose(); // Dispose the controller after the dialog is closed
    });
  }
  // --- End modified method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                SvgPicture.asset(
                  'assets/images/login.svg',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Login to continue your carpool journey'),
                const SizedBox(height: 32),
                // Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress, // Added keyboard type
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    labelText: 'Email Address', // Changed label to be more descriptive
                    border: roundedInputBorder(14.0),
                    enabledBorder: roundedInputBorder(14.0),
                    focusedBorder: roundedInputBorder(14.0),
                  ),
                ),
                const SizedBox(height: 16),
                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible, // Toggles based on state
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    labelText: 'Password',
                    border: roundedInputBorder(14.0),
                    enabledBorder: roundedInputBorder(14.0),
                    focusedBorder: roundedInputBorder(14.0),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Added some space
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue), // You can customize the color
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Adjusted space to account for the new button
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);

                    // --- Modified Login Logic ---
                    // Assuming AuthService.login now returns a UserCredential or null
                    UserCredential? userCredential;
                    String? errorMessage;
                    try {
                      userCredential = (await AuthService.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      ));
                      if (userCredential == null) {
                        errorMessage = "Invalid credentials. Please try again.";
                      }
                    } on FirebaseAuthException catch (e) {
                      errorMessage = e.message; // Use Firebase's error message
                    } catch (e) {
                      errorMessage = "An unexpected error occurred.";
                      print("Login error: $e"); // Log for debugging
                    }

                    setState(() => _isLoading = false);

                    if (userCredential != null && userCredential.user != null) {
                      // Login successful, now check the user's role
                      final String? userRole = await _getUserRole(userCredential.user);

                      if (userRole == 'admin') {
                        // Navigate to Admin Dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                        );
                      } else {
                        // Navigate to Main Navigator for regular users
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => MainNavigator()),
                        );
                      }
                    } else {
                      // Show error if login failed
                      showErrorSnackbar(context, errorMessage ?? "Login failed.");
                    }
                    // --- End Modified Login Logic ---
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()), // Use const for stateless widgets
                    );
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}