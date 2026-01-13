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

  // Controllers
  final _nameController = TextEditingController();
  final _icController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _institutionController = TextEditingController();
  final _fieldController = TextEditingController();
  final _areaController = TextEditingController();
  final _mosqueController = TextEditingController();

  String _gender = 'Male';
  String _nationality = 'Malaysian';
  String _qualification = 'Bachelor Degree';
  DateTime? _dob;

  bool _loaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _institutionController.dispose();
    _fieldController.dispose();
    _areaController.dispose();
    _mosqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Preacher Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: RegistrationController.getRegistrationByDocId(widget.docId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Registration not found'));
          }

          final data = snapshot.data!.data()!;

          // Load data ONCE
          if (!_loaded) {
            _nameController.text = data['preacherName'] ?? '';
            _icController.text = data['preacherIC'] ?? '';
            _phoneController.text = data['preacherNumber'] ?? '';
            _emailController.text = data['preacherEmail'] ?? '';
            _institutionController.text = data['institutionName'] ?? '';
            _fieldController.text = data['preacherField'] ?? '';
            _areaController.text = data['area'] ?? '';
            _mosqueController.text = data['mosque'] ?? '';

            _gender = data['preacherGender'] ?? 'Male';
            _nationality = data['preacherNationality'] ?? 'Malaysian';
            _qualification = data['qualification'] ?? 'Bachelor Degree';
            _dob = (data['preacherDOB'] as Timestamp?)?.toDate();

            _loaded = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _textField(_nameController, 'Preacher Name'),
                  _textField(_icController, 'IC / Passport'),
                  _dropdown('Gender', _gender, ['Male', 'Female'],
                      (v) => setState(() => _gender = v)),
                  _datePicker(),
                  _dropdown(
                    'Nationality',
                    _nationality,
                    ['Malaysian', 'Indonesian', 'Thai', 'Bruneian', 'Other'],
                    (v) => setState(() => _nationality = v),
                  ),
                  _textField(
                    _phoneController,
                    'Phone Number',
                    keyboard: TextInputType.phone,
                  ),
                  _textField(
                    _emailController,
                    'Email',
                    keyboard: TextInputType.emailAddress,
                  ),
                  _dropdown(
                    'Qualification',
                    _qualification,
                    ['Diploma', 'Bachelor Degree', 'Master Degree', 'PhD'],
                    (v) => setState(() => _qualification = v),
                  ),
                  _textField(_institutionController, 'Institution'),
                  _textField(_fieldController, 'Preaching Field'),
                  _textField(_areaController, 'Area'),
                  _textField(_mosqueController, 'Mosque'),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _update,
                      child: const Text('Save Changes'),
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

  // ---------------- Widgets ----------------

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) =>
            v == null || v.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
          border: const OutlineInputBorder(),
        ),
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(),
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

  // ---------------- Logic ----------------

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _dob = date);
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate() || _dob == null) return;

    await RegistrationController.updateRegistration(
      widget.docId,
      {
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
        'area': _areaController.text,
        'mosque': _mosqueController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preacher updated successfully')),
      );
    }
  }
}
