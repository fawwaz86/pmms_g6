import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pmms_g6/Provider/RegistrationController.dart';

import 'addRegistrationPage.dart';
import 'registrationDetailPage.dart';
import 'editRegistrationPage.dart';

class ListRegistrationPage extends StatelessWidget {
  final String mode; // staffApproval | preacherManagement | preacherView

  const ListRegistrationPage({
    Key? key,
    required this.mode,
  }) : super(key: key);

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == 'staffApproval'
              ? 'Approve Staff Registration'
              : 'Preacher Registration',
        ),
      ),

      // ✅ STAFF ONLY → REGISTER PREACHER
      floatingActionButton: mode == 'preacherManagement'
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.person_add),
              label: const Text('Register Preacher'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddRegistrationPage(),
                  ),
                );
              },
            )
          : null,

      body: StreamBuilder<QuerySnapshot>(
        stream: mode == 'staffApproval'
            // ================= ADMIN =================
            ? FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'staff')
                .where('status', isEqualTo: 'pending')
                .snapshots()

            // ================= STAFF / ADMIN =================
            : RegistrationController.getAllRegistrations(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                mode == 'staffApproval'
                    ? 'No pending staff approvals'
                    : 'No preacher registrations found',
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = mode == 'staffApproval'
                  ? data['name'] ?? 'No name'
                  : data['preacherName'] ?? 'No name';

              final email = mode == 'staffApproval'
                  ? data['email'] ?? ''
                  : data['preacherEmail'] ?? '';

              final date = _formatDate(data['createdAt']);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      const SizedBox(height: 4),
                      Text(
                        'Registered on: $date',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  // ================= ACTIONS =================
                  trailing: mode == 'staffApproval'
                      // -------- ADMIN APPROVE STAFF --------
                      ? ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .update({'status': 'approved'});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Staff approved successfully'),
                              ),
                            );
                          },
                          child: const Text('Approve'),
                        )

                      // -------- STAFF MANAGE PREACHER --------
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ViewRegistrationPage(docId: doc.id),
                                  ),
                                );
                              },
                            ),
                            if (mode == 'preacherManagement') ...[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditRegistrationPage(docId: doc.id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _confirmDelete(context, doc.id),
                              ),
                            ],
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= DELETE CONFIRM =================

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this registration?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await RegistrationController.deleteRegistration(docId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
