import 'package:carpooling/views/admin/users/user_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedRoleFilter; // Null for 'All Roles'
  String? _selectedStatusFilter; // Null for 'All Statuses'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Management",
          style: TextStyle( fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Add New User",
            onPressed: () {
              // TODO: Implement "Add New User" functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Add New User functionality not yet implemented")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name, email, or phone...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Filter Role",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                      value: _selectedRoleFilter,
                      hint: const Text("All Roles"),
                      items: const [
                        DropdownMenuItem(value: null, child: Text("All Roles")),
                        DropdownMenuItem(value: 'passenger', child: Text("Passenger")),
                        DropdownMenuItem(value: 'driver', child: Text("Driver")),
                        DropdownMenuItem(value: 'admin', child: Text("Admin")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleFilter = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Filter Status",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                      value: _selectedStatusFilter,
                      hint: const Text("All Statuses"),
                      items: const [
                        DropdownMenuItem(value: null, child: Text("All Statuses")),
                        DropdownMenuItem(value: 'active', child: Text("Active")),
                        DropdownMenuItem(value: 'suspended', child: Text("Suspended")),
                        DropdownMenuItem(value: 'pending_verification', child: Text("Pending Verification")),
                        DropdownMenuItem(value: 'inactive', child: Text("Inactive")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatusFilter = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                // Apply filters
                final allUsers = snapshot.data!.docs;
                final filteredUsers = allUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] as String? ?? '').toLowerCase();
                  final email = (data['email'] as String? ?? '').toLowerCase();
                  final phone = (data['phone'] as String? ?? '').toLowerCase();
                  final role = (data['role'] as String? ?? '').toLowerCase();
                  final status = (data['status'] as String? ?? '').toLowerCase();

                  final matchesSearch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery.toLowerCase()) ||
                      email.contains(_searchQuery.toLowerCase()) ||
                      phone.contains(_searchQuery.toLowerCase());

                  final matchesRole = _selectedRoleFilter == null || role == _selectedRoleFilter;
                  final matchesStatus = _selectedStatusFilter == null || status == _selectedStatusFilter;

                  return matchesSearch && matchesRole && matchesStatus;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No users found matching your criteria.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = filteredUsers[index];
                    final userData = userDoc.data() as Map<String, dynamic>;

                    final String name = userData['name'] ?? 'N/A';
                    final String email = userData['email'] ?? 'N/A';
                    final String role = userData['role'] ?? 'N/A';
                    final String status = userData['status'] ?? 'N/A';
                    final Timestamp? registrationTimestamp = userData['createdAt'];
                    final String registrationDate = registrationTimestamp != null
                        ? DateFormat('MMM dd, yyyy').format(registrationTimestamp.toDate())
                        : 'N/A';

                    // Determine status color
                    Color statusColor;
                    switch (status.toLowerCase()) {
                      case 'active':
                        statusColor = Colors.green;
                        break;
                      case 'suspended':
                        statusColor = Colors.red;
                        break;
                      case 'pending_verification':
                        statusColor = Colors.orange;
                        break;
                      case 'inactive':
                        statusColor = Colors.grey;
                        break;
                      default:
                        statusColor = Colors.blueGrey;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailPage(userId: userDoc.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blueGrey.shade100,
                                
                                child:Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                                        style: const TextStyle(fontSize: 24, color: Colors.blueAccent),
                                      )
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Role: $role',
                                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            status.replaceAll('_', ' '), // Format status for display
                                            style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Joined: $registrationDate',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}