import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pmms_g6/Provider/RegistrationController.dart';

import 'addRegistrationPage.dart';
import 'registrationDetailPage.dart';
import 'editRegistrationPage.dart';

class ListRegistrationPage extends StatelessWidget {
  const ListRegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preacher Registration')),

      // ✅ BUTTON WITH TEXT
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Register Preacher'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRegistrationPage()),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: RegistrationController.getAllRegistrations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No preacher registrations found'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['preacherName'] ?? 'No name'),
                  subtitle: Text(data['preacherEmail'] ?? ''),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 👁 VIEW
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewRegistrationPage(
                                docId: doc.id,
                              ),
                            ),
                          );
                        },
                      ),

                      // ✏️ EDIT
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditRegistrationPage(
                                docId: doc.id,
                              ),
                            ),
                          );
                        },
                      ),

                      // 🗑 DELETE
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, doc.id),
                      ),
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
