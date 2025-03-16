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
      final universityId = data['universityId'] as String? ?? '';
      return universityId.contains(_searchQuery);
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
                hintText: 'Search by university ID',
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
                      final facultyId =
                          data['universityId'] as String? ?? 'Unknown ID';

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
                          title: Text('University ID: $facultyId'),
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
    final universityIdController = TextEditingController();
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
                    'Enter the 6-digit university ID number for the faculty member.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: universityIdController,
                    decoration: const InputDecoration(
                      labelText: 'University ID',
                      hintText: 'Enter 6-digit ID',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a university ID';
                      }
                      if (value.length != 6) {
                        return 'ID must be exactly 6 digits';
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
                        final universityId = universityIdController.text;
                        await _addFacultyMember(universityId);
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
  Future<void> _addFacultyMember(String universityId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if a user with this ID already exists in the user_records collection
      final existingUser =
          await _firestore
              .collection('user_records')
              .where('universityId', isEqualTo: universityId)
              .get();

      if (existingUser.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User with this ID already exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Add to Firestore with only universityId and role
      await _firestore.collection('user_records').add({
        'universityId': universityId,
        'role': 'faculty',
      });

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
