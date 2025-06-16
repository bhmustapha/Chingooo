import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  // Function to re-authenticate the user
  Future<bool> _reauthenticateUser(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() {
        _errorMessage = 'User not logged in or no email found.';
      });
      return false;
    }

    // Prompt the user for their current password to re-authenticate
    final String? password = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController reauthPasswordController = TextEditingController();
        return AlertDialog(
          title: const Text('Re-authenticate to change password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Please enter your current password for ${user.email} to proceed. This is a security measure.'),
              const SizedBox(height: 16),
              TextField(
                controller: reauthPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(reauthPasswordController.text),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (password == null || password.isEmpty) {
      setState(() {
        _errorMessage = 'Re-authentication cancelled or password not provided.';
      });
      return false;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
      return true; // Re-authentication successful
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'wrong-password') {
        message = 'Invalid current password. Please try again.';
      } else if (e.code == 'user-not-found') {
        message = 'User not found. Please log in again.';
      } else {
        message = 'Re-authentication failed: ${e.message}';
      }
      setState(() {
        _errorMessage = message;
      });
      print('Re-authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred during re-authentication: $e';
      });
      print('Unexpected re-authentication error: $e');
      return false;
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'No user is currently logged in.';
        _isLoading = false;
      });
      return;
    }

    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;

    try {
      // First, re-authenticate the user if needed (handles 'requires-recent-login')
      await user.reauthenticateWithCredential(EmailAuthProvider.credential(
        email: user.email!, // Assuming user has an email
        password: currentPassword,
      ));

      // If re-authentication is successful, proceed to update the password
      await user.updatePassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        Navigator.of(context).pop(); // Go back to settings page
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'wrong-password') {
        message = 'Incorrect current password. Please try again.';
      } else if (e.code == 'weak-password') {
        message = 'The new password is too weak. Please choose a stronger one.';
      } else if (e.code == 'requires-recent-login') {
        // This case should ideally be handled by the reauthenticateWithCredential above,
        // but it's good to have a fallback or more explicit handling.
        // For 'requires-recent-login', the 'reauthenticateWithCredential' method is the correct way.
        // If it still reaches here, it means the credential used for reauth itself was too old or invalid.
        final reauthenticated = await _reauthenticateUser(context);
        if (reauthenticated) {
          // If re-authentication succeeded, try updating password again
          await _changePassword(); // Recursive call, but should resolve
          return;
        } else {
          message = 'Password change requires recent login. Please try again after re-authenticating.';
        }
      } else {
        message = 'Failed to change password: ${e.message}';
      }
      setState(() {
        _errorMessage = message;
      });
      print('Error changing password: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
      print('Unexpected error changing password: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update your account password. For security, you will need to enter your current password.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration:  InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration:  InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmNewPasswordController,
                obscureText: true,
                decoration:  InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),

                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 14,fontFamily: 'Poppins'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}