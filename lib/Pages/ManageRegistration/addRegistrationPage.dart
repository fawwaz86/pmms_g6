import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pmms_g6/Provider/RegistrationController.dart';

class AddRegistrationPage extends StatefulWidget {
  const AddRegistrationPage({Key? key}) : super(key: key);

  @override
  State<AddRegistrationPage> createState() => _AddRegistrationPageState();
}

class _AddRegistrationPageState extends State<AddRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _icController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _institutionController = TextEditingController();
  final _fieldController = TextEditingController();

  String _gender = 'Male';
  String _nationality = 'Malaysian';
  String _qualification = 'Bachelor Degree';
  DateTime? _dob;

  bool _loading = false;

  final _nationalities = [
    'Malaysian',
    'Indonesian',
    'Thai',
    'Bruneian',
    'Other',
  ];

  final _qualifications = [
    'Diploma',
    'Bachelor Degree',
    'Master Degree',
    'PhD',
    'Others',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _institutionController.dispose();
    _fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Preacher')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_nameController, 'Preacher Name'),
              _field(_icController, 'IC / Passport'),
              _dropdown('Gender', _gender, ['Male', 'Female'],
                  (v) => setState(() => _gender = v)),
              _datePicker(),
              _dropdown('Nationality', _nationality, _nationalities,
                  (v) => setState(() => _nationality = v)),
              _field(_phoneController, 'Phone Number',
                  keyboard: TextInputType.phone),
              _field(_emailController, 'Email',
                  keyboard: TextInputType.emailAddress),
              _dropdown('Qualification', _qualification, _qualifications,
                  (v) => setState(() => _qualification = v)),
              _field(_institutionController, 'Institution'),
              _field(_fieldController, 'Preaching Field'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Registration'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: _pickDate,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            _dob == null
                ? 'Select date'
                : _dob!.toLocal().toString().split(' ')[0],
          ),
        ),
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _dob = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _dob == null) return;

    setState(() => _loading = true);

    try {
      // 🔐 SECONDARY AUTH (DO NOT LOG OUT STAFF)
      final secondaryApp = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // CREATE PREACHER AUTH ACCOUNT
      final userCred =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: 'Temp@12345',
      );

      final uid = userCred.user!.uid;

      // SAVE REGISTRATION (OPTIONAL – FOR ADMIN RECORD)
      await RegistrationController.addRegistration({
        'authUid': uid,
        'preacherName': _nameController.text,
        'preacherIC': _icController.text,
        'preacherGender': _gender,
        'preacherDOB': _dob,
        'preacherNationality': _nationality,
        'preacherNumber': _phoneController.text,
        'preacherEmail': _emailController.text,
        'qualification': _qualification,
        'institutionName': _institutionController.text,
        'preacherField': _fieldController.text,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 🔑 SAVE FULL PROFILE INTO USERS COLLECTION
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'role': 'preacher',
        'status': 'active',

        'preacherIC': _icController.text,
        'preacherGender': _gender,
        'preacherDOB': _dob,
        'preacherNationality': _nationality,
        'preacherNumber': _phoneController.text,
        'qualification': _qualification,
        'institutionName': _institutionController.text,
        'preacherField': _fieldController.text,

        'createdAt': FieldValue.serverTimestamp(),
      });

      // SEND RESET PASSWORD EMAIL
      await secondaryAuth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Preacher registered. Password reset email sent.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
}
