import 'package:carpooling/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:io';
import '../../themes/costum_reusable.dart'; // Assuming roundedInputBorder is here
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

   Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
        dobController.text = data['birthdate'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
      }
    } catch (e) {
      print("Error loading profile data: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      
      // Upload to Firebase Storage
      final user = FirebaseAuth.instance.currentUser;
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user!.uid}.jpg');

      await storageRef.putFile(_imageFile!);
      final downloadURL = await storageRef.getDownloadURL();

       // Save URL to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'imageUrl': downloadURL});
    }    
    } catch (e) {
      showErrorSnackbar(context, "Failed to pick image.");
    }
  }

  Future<void> _selectDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': nameController.text,
          'birthdate': dobController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          
        });

        showSuccessSnackbar(context, 'Profile updated!');
        Navigator.pop(context, true);
      } catch (e) {
        showErrorSnackbar(context,'Failed to update profile.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : null,
                          child:
                              _imageFile == null
                                  ? Icon(LucideIcons.camera, size: 40)
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          labelText: 'Name',
                          border: roundedInputBorder(30.0),
                          enabledBorder: roundedInputBorder(30.0),
                          focusedBorder: roundedInputBorder(30.0),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter your name'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth
                      TextFormField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          labelText: 'Date of Birth',
                          border: roundedInputBorder(30.0),
                          enabledBorder: roundedInputBorder(30.0),
                          focusedBorder: roundedInputBorder(30.0),
                        ),
                        onTap: _selectDateOfBirth,
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please select your date of birth'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          labelText: 'Email',
                          border: roundedInputBorder(30.0),
                          enabledBorder: roundedInputBorder(30.0),
                          focusedBorder: roundedInputBorder(30.0),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter your email'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          labelText: 'Phone Number',
                          border: roundedInputBorder(30.0),
                          enabledBorder: roundedInputBorder(30.0),
                          focusedBorder: roundedInputBorder(30.0),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter your phone number'
                                    : null,
                      ),
                      const SizedBox(height: 32,),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
