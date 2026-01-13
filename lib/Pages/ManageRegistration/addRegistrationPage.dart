import 'package:flutter/material.dart';
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

  final List<String> _nationalities = [
    'Malaysian',
    'Indonesian',
    'Thai',
    'Bruneian',
    'Other',
  ];

  final List<String> _qualifications = [
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
      appBar: AppBar(
        title: const Text('Register Preacher'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(
                controller: _nameController,
                label: 'Preacher Name',
                hint: 'Full name',
              ),
              _buildField(
                controller: _icController,
                label: 'IC / Passport',
                hint: '900101-10-1234',
              ),
              _buildDropdown(
                label: 'Gender',
                value: _gender,
                items: const ['Male', 'Female'],
                onChanged: (v) => setState(() => _gender = v),
              ),
              _buildDatePicker(),
              _buildDropdown(
                label: 'Nationality',
                value: _nationality,
                items: _nationalities,
                onChanged: (v) => setState(() => _nationality = v),
              ),
              _buildField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '0123456789',
                keyboardType: TextInputType.phone,
              ),
              _buildField(
                controller: _emailController,
                label: 'Email',
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildDropdown(
                label: 'Qualification',
                value: _qualification,
                items: _qualifications,
                onChanged: (v) => setState(() => _qualification = v),
              ),
              _buildField(
                controller: _institutionController,
                label: 'Institution',
                hint: 'University / College',
              ),
              _buildField(
                controller: _fieldController,
                label: 'Preaching Field',
                hint: 'Aqidah, Fiqh, Dakwah',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: submit,
                  child: const Text(
                    'Submit Registration',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Widgets ----------------

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (v) =>
            v == null || v.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _buildDatePicker() {
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

  // ---------------- Logic ----------------

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _dob = date);
  }

  Future<void> submit() async {
  if (_formKey.currentState!.validate() && _dob != null) {
    try {
      await RegistrationController.addRegistration({
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
      });

      debugPrint('✅ Registration submitted successfully');

      Navigator.pop(context);
    } catch (e) {
      debugPrint('❌ ERROR submitting registration: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } else {
    debugPrint('❌ Form invalid or DOB not selected');
  }
  }
}
