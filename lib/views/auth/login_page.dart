import 'package:carpooling/themes/costum_reusable.dart';
import 'package:carpooling/widgets/main_navigator.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart';

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
                    suffixIcon: IconButton( // The eye icon button
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    final errorMessage = await AuthService.login(
                      emailController.text.trim(), // Trim whitespace
                      passwordController.text.trim(), // Trim whitespace
                    );
                    setState(() => _isLoading = false);
                    if (errorMessage == null) {
                      // Login successful — navigate to home
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MainNavigator()),
                      );
                    } else {
                      // Show error
                      showErrorSnackbar(context, errorMessage);
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