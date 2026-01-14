import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'editProfilePage.dart';

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  // 🔗 JOIN users + registrations
  Future<Map<String, dynamic>> _getProfileData(String uid) async {
    final firestore = FirebaseFirestore.instance;

    // users/{uid}
    final userDoc = await firestore.collection('users').doc(uid).get();

    // registrations where userId == uid
final regSnap = await firestore
    .collection('registrations')
    .where('authUid', isEqualTo: uid)
    .limit(1)
    .get();


    return {
      'user': userDoc.data(),
      'registration':
          regSnap.docs.isNotEmpty ? regSnap.docs.first.data() : null,
    };
  }

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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getProfileData(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['user'] == null) {
            return const Center(child: Text('Profile not found'));
          }

          final user = snapshot.data!['user'] as Map<String, dynamic>;
          final reg =
              snapshot.data!['registration'] as Map<String, dynamic>?;

          final role = user['role'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== USER DATA =====
              _info('Full Name', user['name']),
              _info('Email', user['email']),
              _info('Role', role),

              if (role == 'preacher') ...[
                _info('Status', user['status']),
              ],

              const SizedBox(height: 24),

              // ===== REGISTRATION DATA =====
              if (role == 'preacher' && reg != null) ...[
                const Text(
                  'Preacher Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _info('IC / Passport', reg['preacherIC']),
                _info('Gender', reg['preacherGender']),
                _info(
                  'Date of Birth',
                  (reg['preacherDOB'] as Timestamp)
                      .toDate()
                      .toString()
                      .split(' ')[0],
                ),
                _info('Nationality', reg['preacherNationality']),
                _info('Phone Number', reg['preacherNumber']),
                _info('Qualification', reg['qualification']),
                _info('Institution', reg['institutionName']),
                _info('Preaching Field', reg['preacherField']),
              ],

              const SizedBox(height: 24),

              // ✏️ EDIT PROFILE
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
