import 'package:carpooling/themes/costum_reusable.dart';
import 'package:carpooling/widgets/main_navigator.dart';
import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'auth_service.dart'; // auth logic

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isLoading = false; // loading flag

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
                  TextField( 
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Full Name',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Phone Number',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Email Address',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Password',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      labelText: 'Confirm Password',
                      border: roundedInputBorder(14.0),
                      enabledBorder: roundedInputBorder(14.0),
                      focusedBorder: roundedInputBorder(14.0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (formKey.currentState!.validate()) {
                        if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
                          showErrorSnackbar(context, 'Password doesnt match');
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
                      }},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
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
