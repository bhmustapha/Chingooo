import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get _currentUser => _auth.currentUser;

  // Reference to the emergency contacts subcollection for the current user
  CollectionReference<Map<String, dynamic>>? _contactsCollection;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _contactsCollection = _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('emergency_contacts');
    }
  }

  // --- Add/Edit Contact Dialog ---
  Future<void> _showAddEditContactDialog({DocumentSnapshot? contactDoc}) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    bool isEditing = contactDoc != null;
    String dialogTitle = isEditing ? 'Edit Contact' : 'Add New Contact';
    String confirmButtonText = isEditing ? 'Update' : 'Add';

    if (isEditing) {
      nameController.text = contactDoc['name'] ?? '';
      phoneController.text = contactDoc['phone'] ?? '';
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration:  InputDecoration(labelText: 'Name',border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration:  InputDecoration(labelText: 'Phone Number',border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    // Simple regex for phone number validation (can be more robust)
                    if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final String name = nameController.text.trim();
                final String phoneNumber = phoneController.text.trim();

                try {
                  if (isEditing) {
                    await _contactsCollection!.doc(contactDoc.id).update({
                      'name': name,
                      'phone': phoneNumber,
                    });
                    _showSnackBar('Contact updated successfully!');
                  } else {
                    await _contactsCollection!.add({
                      'name': name,
                      'phone': phoneNumber,
                      'timestamp': FieldValue.serverTimestamp(), // Optional: for ordering
                    });
                    _showSnackBar('Contact added successfully!');
                  }
                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  _showSnackBar('Failed to save contact: $e', isError: true);
                  print('Error saving contact: $e');
                }
              }
            },
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );
  }

  // --- Delete Contact Confirmation ---
  Future<void> _deleteContact(String docId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this emergency contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _contactsCollection!.doc(docId).delete();
        _showSnackBar('Contact deleted successfully!');
      } catch (e) {
        _showSnackBar('Failed to delete contact: $e', isError: true);
        print('Error deleting contact: $e');
      }
    }
  }

  // --- Utility for SnackBar messages ---
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Emergency Contacts'), elevation: 0,),
        body: const Center(
          child: Text('You must be logged in to manage emergency contacts.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _contactsCollection?.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No emergency contacts added yet.\nTap the + button to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final contacts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final data = contact.data() as Map<String, dynamic>;
              final String name = data['name'] ?? 'No Name';
              final String phoneNumber = data['phone'] ?? 'No Phone';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(phoneNumber, style: const TextStyle(fontSize: 16)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _showAddEditContactDialog(contactDoc: contact),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteContact(contact.id),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Optional: What happens when the user taps on a contact?
                    // E.g., directly make a call or show contact details.
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        onPressed: () => _showAddEditContactDialog(),
        tooltip: 'Add New Contact',
        child: const Icon(Icons.add),
      ),
    );
  }
}