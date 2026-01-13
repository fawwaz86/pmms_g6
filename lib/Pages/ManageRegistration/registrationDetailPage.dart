import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pmms_g6/Provider/RegistrationController.dart';

class ViewRegistrationPage extends StatelessWidget {
  final String docId;

  const ViewRegistrationPage({
    super.key,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Registration')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: RegistrationController.getRegistrationByDocId(docId),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error or no data
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Registration not found'));
          }

          final data = snapshot.data!.data()!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _info('Name', data['preacherName']),
                _info('IC / Passport', data['preacherIC']),
                _info('Gender', data['preacherGender']),
                _info(
                  'Date of Birth',
                  (data['preacherDOB'] as Timestamp)
                      .toDate()
                      .toString()
                      .split(' ')[0],
                ),
                _info('Nationality', data['preacherNationality']),
                _info('Phone', data['preacherNumber']),
                _info('Email', data['preacherEmail']),
                _info('Qualification', data['qualification']),
                _info('Institution', data['institutionName']),
                _info('Field', data['preacherField']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
