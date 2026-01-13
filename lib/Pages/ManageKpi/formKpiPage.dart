// lib/Pages/ManageKpi/formKpiPage.dart

import 'package:flutter/material.dart';
import '../../Provider/KpiController.dart';

class FormKpiPage extends StatefulWidget {
  final Map<String, dynamic>? kpiData;
  final String? docId; 

  const FormKpiPage({super.key, this.kpiData, this.docId});

  @override
  State<FormKpiPage> createState() => _FormKpiPageState();
}

class _FormKpiPageState extends State<FormKpiPage> {
  final _formKey = GlobalKey<FormState>();
  final KpiController _controller = KpiController();

  // Controllers for all mandatory fields per Data Dictionary Section 2.2.5
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
    
    // Foreign Keys & Audit IDs (NOT NULL)
    _preacherIdController = TextEditingController(text: data?['preacherID']?.toString() ?? '');
    _assignActIdController = TextEditingController(text: data?['assignActID']?.toString() ?? '');
    _staffIdController = TextEditingController(text: data?['staffID']?.toString() ?? '1'); 
  }

  @override
  void dispose() {
    // Prevent memory leaks
    for (var controller in [
      _titleController, _descController, _targetController, _unitController,
      _indicatorController, _yearController, _categoryController, _remarksController,
      _preacherIdController, _assignActIdController, _staffIdController
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitKpi() async {
    if (_formKey.currentState!.validate()) {
      // Create data map matching the Kpi model requirements
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
      if (widget.docId == null) {
        success = await _controller.createKpi(kpiData);
      } else {
        success = await _controller.updateKpi(widget.docId!, kpiData);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KPI saved successfully')),
          );
          Navigator.pop(context, true); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission failed. Check validation console.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? 'Add New KPI' : 'Edit KPI Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              _buildTextField(_categoryController, 'Category (e.g., Education)', true),
              _buildTextField(_yearController, 'Reporting Year', true, isNumber: true),
              
              const SizedBox(height: 15),
              _sectionHeader("Target Metrics"),
              _buildTextField(_targetController, 'Target Quantity', true, isNumber: true),
              _buildTextField(_unitController, 'Unit (e.g., People, Sessions)', true),
              _buildTextField(_indicatorController, 'Indicator Name', true),
              
              const SizedBox(height: 15),
              _sectionHeader("Linking & Audit"),
              _buildTextField(_preacherIdController, 'Preacher ID', true, isNumber: true),
              _buildTextField(_assignActIdController, 'Activity ID', true, isNumber: true),
              _buildTextField(_staffIdController, 'Staff ID (Your ID)', true, isNumber: true),

              const SizedBox(height: 15),
              _sectionHeader("Optional Notes"),
              _buildTextField(_descController, 'Description', false, maxLines: 2),
              _buildTextField(_remarksController, 'Internal Remarks', false, maxLines: 2),
              
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitKpi,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('SUBMIT TO DATABASE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancel and Return'),
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Divider(),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool required, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label, 
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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