import 'package:carpooling/themes/costum_reusable.dart';
import 'package:carpooling/widgets/main_navigator.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart'; // auth logic

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  
  final String _privacyPolicyUrl = 'https://chingooocarpooling-privacy.netlify.app/'; 
  final String _appTermsUrl = 'https://chingooocarpooling-terms.netlify.app/';   



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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $urlString');
      // Optional: Show a user-friendly error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the policy page. Please check your internet connection.')),
      );
    }
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
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Phone Number
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email Address
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password
                  TextFormField(
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
                    validator: (value) {
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
                      if (formKey.currentState!.validate()) {
                        if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
                          showErrorSnackbar(context, 'Passwords do not match');
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
                  const SizedBox(height: 24), // Added some spacing before the footer
                  // --- Footer Section ---
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "By clicking '",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: const TextStyle(
                            color: Colors.blue, // Make 'Sign Up' a different color to indicate it's clickable in context
                            fontWeight: FontWeight.bold,
                          ),
                          // You can add a tap gesture recognizer here if 'Sign Up' needs a special action
                          // other than submitting the form. For this context, it just refers to the button.
                        ),
                        TextSpan(
                          text: "' you agree on ",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _launchUrl(_privacyPolicyUrl);
                            },
                        ),
                        TextSpan(
                          text: " and ",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        TextSpan(
                          text: "App Terms",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _launchUrl(_appTermsUrl);
                            },
                        ),
                        TextSpan(
                          text: ".",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

