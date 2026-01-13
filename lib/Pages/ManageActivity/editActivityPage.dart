// lib/Pages/ManageActivity/editActivityPage.dart

import 'package:flutter/material.dart';
import '../../Models/activity.dart';

class EditActivityPage extends StatefulWidget {
  final Activity activity;

  const EditActivityPage({
    super.key,
    required this.activity,
  });

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  DateTime? _selectedDate;
  String? _selectedPreacherId;
  ActivityStatus? _selectedStatus;
  bool _isSaving = false;

  // TODO: Fetch from API
  final List<Map<String, String>> _preachers = [
    {'id': 'P001', 'name': 'Ustaz Ahmad bin Abdullah'},
    {'id': 'P002', 'name': 'Ustazah Fatimah binti Hassan'},
    {'id': 'P003', 'name': 'Ustaz Muhammad bin Ibrahim'},
    {'id': 'P004', 'name': 'Ustazah Aisha binti Yusof'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity.title);
    _descriptionController = TextEditingController(text: widget.activity.description);
    _locationController = TextEditingController(text: widget.activity.location);
    _notesController = TextEditingController(text: widget.activity.notes ?? '');
    _selectedDate = widget.activity.scheduledDate;
    _selectedPreacherId = widget.activity.assignedPreacherId;
    _selectedStatus = widget.activity.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a scheduled date')),
      );
      return;
    }

    if (_selectedPreacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a preacher')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    // Create updated activity object
    final preacher = _preachers.firstWhere(
      (p) => p['id'] == _selectedPreacherId,
    );

    final updatedActivity = widget.activity.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      scheduledDate: _selectedDate!,
      assignedPreacherId: _selectedPreacherId!,
      assignedPreacherName: preacher['name']!,
      status: _selectedStatus!,
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, updatedActivity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Activity'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Activity ID Card
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.tag, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Activity ID: ${widget.activity.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title *',
                hintText: 'Enter activity title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter activity title';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter activity description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter activity description';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Location Field
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'Enter activity location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Scheduled Date *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Preacher Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPreacherId,
              decoration: const InputDecoration(
                labelText: 'Assign to Preacher *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _preachers.map((preacher) {
                return DropdownMenuItem<String>(
                  value: preacher['id'],
                  child: Text(preacher['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPreacherId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a preacher';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            DropdownButtonFormField<ActivityStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: ActivityStatus.values.map((status) {
                return DropdownMenuItem<ActivityStatus>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a status';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes Field (Optional)
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Enter any additional notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Completion Info (if completed)
            if (widget.activity.status == ActivityStatus.completed) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Completed Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (widget.activity.completedDate != null)
                        Text(
                          'Completed: ${_formatDateTime(widget.activity.completedDate!)}',
                          style: TextStyle(fontSize: 12, color: Colors.green[700]),
                        ),
                      if (widget.activity.completedLatitude != null && 
                          widget.activity.completedLongitude != null)
                        Text(
                          'Location: ${widget.activity.completedLatitude}, ${widget.activity.completedLongitude}',
                          style: TextStyle(fontSize: 12, color: Colors.green[700]),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Update Button
            ElevatedButton(
              onPressed: _isSaving ? null : _updateActivity,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Update Activity',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return Colors.orange;
      case ActivityStatus.inProgress:
        return Colors.blue;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}