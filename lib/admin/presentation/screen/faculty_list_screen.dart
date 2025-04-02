import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scheduler/common/theme/app_theme.dart';

class FacultyListScreen extends StatefulWidget {
  const FacultyListScreen({super.key});

  @override
  State<FacultyListScreen> createState() => _FacultyListScreenState();
}

class _FacultyListScreenState extends State<FacultyListScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  // Add search query state
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter faculty list based on search query
  List<QueryDocumentSnapshot> _filterFaculty(List<QueryDocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final email = data['email'] as String? ?? '';
      return email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Management'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Faculty Members',
                  style: context.textStyles.heading2.textPrimary,
                ),
                ElevatedButton.icon(
                  onPressed: _showAddFacultyDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Faculty',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your faculty members, departments, and specializations',
              style: context.textStyles.body2.textSecondary,
            ),
            const SizedBox(height: 24),

            // Search bar with updated functionality
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Stream builder for faculty list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('user_records')
                        .where('role', isEqualTo: 'faculty')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading data: ${snapshot.error}',
                        style: context.textStyles.body1.textSecondary,
                      ),
                    );
                  }

                  // Get all faculty and filter based on search
                  final allFacultyDocs = snapshot.data?.docs ?? [];
                  final facultyDocs = _filterFaculty(allFacultyDocs);

                  if (facultyDocs.isEmpty) {
                    // Show empty state with contextual message
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: primaryColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No faculty members found'
                                : 'No faculty members match the search criteria',
                            style: context.textStyles.body1.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Add faculty members to get started'
                                : 'Try a different search query',
                            style: context.textStyles.caption1.textSecondary,
                          ),
                        ],
                      ),
                    );
                  }

                  // Display filtered faculty list
                  return ListView.builder(
                    itemCount: facultyDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          facultyDocs[index].data() as Map<String, dynamic>;
                      final email = data['email'] as String? ?? 'No email';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Icon(Icons.person, color: primaryColor),
                          ),
                          title: Text(email),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show dialog to add a new faculty member
  void _showAddFacultyDialog() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Faculty'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the email address for the faculty member.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'faculty@bisu.edu.ph',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      if (!value.toLowerCase().endsWith('@bisu.edu.ph')) {
                        return 'Email must be a valid @bisu.edu.ph address';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : TextButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final email = emailController.text.trim();
                        await _addFacultyMember(email);
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                    ),
                    child: const Text('Add'),
                  ),
            ],
          ),
    );
  }

  // Add faculty member to Firestore
  Future<void> _addFacultyMember(String email) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if a user with this email already exists in the user_records collection
      final existingUser =
          await _firestore
              .collection('user_records')
              .where('email', isEqualTo: email)
              .get();

      if (existingUser.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User with this email already exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Add to Firestore with email and role
      final data = {'email': email, 'role': 'faculty'};

      await _firestore.collection('user_records').add(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding faculty: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
