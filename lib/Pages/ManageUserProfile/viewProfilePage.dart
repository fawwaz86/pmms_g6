import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'editProfilePage.dart';

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: 'Change Password',
            onPressed: () async {
              final email = FirebaseAuth.instance.currentUser!.email;
              if (email != null) {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = data['role'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _info('Full Name', data['name']),
              _info('Email', data['email']),
              _info('Role', role),

              if (role == 'preacher') ...[
                _info('Status', data['status']),
              ],

              const SizedBox(height: 24),

              // ✏️ EDIT BUTTON (PREACHER ONLY)
              if (role == 'preacher')
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const EditProfilePage(),
    ),
  );
},

                ),
            ],
          );
        },
      ),
    );
  }

  Widget _info(String label, dynamic value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value?.toString() ?? '-'),
      ),
    );
  }
}
