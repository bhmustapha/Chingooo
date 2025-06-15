import 'package:carpooling/themes/costum_reusable.dart';
import 'package:carpooling/widgets/main_navigator.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart'; // auth logic

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isLoading = false; // loading flag

  // Declare controllers as StatefulWidget members so they persist
  // and are disposed correctly.
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up memory
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  SvgPicture.asset(
                    'assets/images/signup.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  // Full Name
                  TextFormField( // Changed from TextField to TextFormField
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Full Name',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                    validator: (value) { // Validator for Full Name
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 16),
                  // Phone Number
                  TextFormField( // Changed from TextField to TextFormField
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Phone Number',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                    validator: (value) { // Validator for Phone Number
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      // Optional: Add regex for phone number format validation if needed
                      // Example: if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) { return 'Enter a valid 10-digit phone number'; }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email Address
                  TextFormField( // Changed from TextField to TextFormField
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Email Address',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                    validator: (value) { // Validator for Email
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      // Optional: Basic email format validation
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password
                  TextFormField( // Changed from TextField to TextFormField
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Password',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                    validator: (value) { // Validator for Password
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) { // Example: Minimum 6 characters
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password
                  TextFormField( // Changed from TextField to TextFormField
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Confirm Password',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                    validator: (value) { // Validator for Confirm Password
                      if (value == null || value.trim().isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value.trim() != passwordController.text.trim()) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      // Validate all form fields first
                      if (formKey.currentState!.validate()) {
                        // The confirm password check is now also handled by its validator,
                        // but keeping a separate check here for immediate feedback is fine too,
                        // though the validator will also catch it.
                        if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
                          showErrorSnackbar(context, 'Passwords do not match'); // This is now redundant if validator is comprehensive
                          return;
                        }

                        setState(() => _isLoading = true);

                        bool success = await AuthService.signUp(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          phone: phoneController.text.trim(),
                        );

                        setState(() => _isLoading = false);

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => MainNavigator()),
                          );
                        } else {
                          showErrorSnackbar(context, 'Sign up failed');
                        }
                      }
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
                        : const Text('Sign Up'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}