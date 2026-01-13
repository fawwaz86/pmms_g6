import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pmms_g6/Provider/RegistrationController.dart';

class EditRegistrationPage extends StatefulWidget {
  final String docId;

  const EditRegistrationPage({
    super.key,
    required this.docId,
  });

  @override
  State<EditRegistrationPage> createState() => _EditRegistrationPageState();
}

class _EditRegistrationPageState extends State<EditRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Registration')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: RegistrationController.getRegistrationByDocId(widget.docId),
        builder: (context, snapshot) {
          // 🔹 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔹 Not found
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Registration not found'));
          }

          final data = snapshot.data!.data()!;

          // 🔹 Set initial value once
          _nameController.text = data['preacherName'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Preacher Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _update(),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    await RegistrationController.updateRegistration(
      widget.docId,
      {
        'preacherName': _nameController.text,
      },
    );

    if (mounted) Navigator.pop(context);
  }
}
