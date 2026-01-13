// lib/Pages/ManageKpi/formKpiPage.dart

import 'package:flutter/material.dart';
import '../../Provider/KpiController.dart';

class FormKpiPage extends StatefulWidget {
  final Map<String, dynamic>? kpiData; // Existing KPI data for edit
  final String? docId;                  // Firestore document ID for edit

  const FormKpiPage({super.key, this.kpiData, this.docId});

  @override
  State<FormKpiPage> createState() => _FormKpiPageState();
}

class _FormKpiPageState extends State<FormKpiPage> {
  final _formKey = GlobalKey<FormState>();
  final KpiController _controller = KpiController();

  // Controllers for all fields
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _targetController;
  late TextEditingController _unitController;
  late TextEditingController _indicatorController;
  late TextEditingController _yearController;
  late TextEditingController _categoryController;
  late TextEditingController _remarksController;
  late TextEditingController _preacherIdController;
  late TextEditingController _assignActIdController;
  late TextEditingController _staffIdController;

  bool get isEditMode => widget.docId != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final data = widget.kpiData;
    _titleController = TextEditingController(text: data?['kpiTitle'] ?? '');
    _descController = TextEditingController(text: data?['kpiDescription'] ?? '');
    _targetController = TextEditingController(text: data?['kpiTarget']?.toString() ?? '');
    _unitController = TextEditingController(text: data?['kpiUnitOfMeasure'] ?? '');
    _indicatorController = TextEditingController(text: data?['kpiIndicator'] ?? '');
    _yearController = TextEditingController(text: data?['kpiYear']?.toString() ?? '');
    _categoryController = TextEditingController(text: data?['kpiCategory'] ?? '');
    _remarksController = TextEditingController(text: data?['kpiRemarks'] ?? '');
    _preacherIdController = TextEditingController(text: data?['preacherID']?.toString() ?? '');
    _assignActIdController = TextEditingController(text: data?['assignActID']?.toString() ?? '');
    _staffIdController = TextEditingController(text: data?['staffID']?.toString() ?? '1');
  }

  @override
  void dispose() {
    for (var c in [
      _titleController, _descController, _targetController, _unitController,
      _indicatorController, _yearController, _categoryController, _remarksController,
      _preacherIdController, _assignActIdController, _staffIdController
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submitKpi() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> kpiData = {
      'kpiTitle': _titleController.text.trim(),
      'kpiDescription': _descController.text.trim(),
      'kpiCategory': _categoryController.text.trim(),
      'kpiYear': int.tryParse(_yearController.text),
      'kpiTarget': int.tryParse(_targetController.text),
      'kpiUnitOfMeasure': _unitController.text.trim(),
      'kpiIndicator': _indicatorController.text.trim(),
      'kpiRemarks': _remarksController.text.trim(),
      'staffID': int.tryParse(_staffIdController.text),
      'preacherID': int.tryParse(_preacherIdController.text),
      'assignActID': int.tryParse(_assignActIdController.text),
    };

    bool success;
    if (isEditMode) {
      // Edit mode
      success = await _controller.updateKpi(widget.docId!, kpiData);
    } else {
      // Add mode
      success = await _controller.createKpi(kpiData);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'KPI saved successfully'
            : 'Submission failed. Check validation console.'),
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit KPI Details' : 'Add New KPI'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader("Basic Data"),
              _buildTextField(_titleController, 'KPI Title', true),
              _buildTextField(_categoryController, 'Category', true),
              _buildTextField(_yearController, 'Reporting Year', true, isNumber: true),

              _sectionHeader("Target Metrics"),
              _buildTextField(_targetController, 'Target Quantity', true, isNumber: true),
              _buildTextField(_unitController, 'Unit', true),
              _buildTextField(_indicatorController, 'Indicator', true),

              _sectionHeader("Linking & Audit"),
              _buildTextField(_preacherIdController, 'Preacher ID', true, isNumber: true),
              _buildTextField(_assignActIdController, 'Activity ID', true, isNumber: true),
              _buildTextField(_staffIdController, 'Staff ID', true, isNumber: true),

              _sectionHeader("Optional Notes"),
              _buildTextField(_descController, 'Description', false, maxLines: 2),
              _buildTextField(_remarksController, 'Internal Remarks', false, maxLines: 2),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitKpi,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: Text(
                  isEditMode ? 'UPDATE KPI' : 'ADD KPI',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Divider(),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return 'This field is required';
          if (isNumber && v != null && v.isNotEmpty && int.tryParse(v) == null) {
            return 'Numeric value required';
          }
          return null;
        },
      ),
    );
  }
}
