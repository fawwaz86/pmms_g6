// lib/Pages/ManageKpi/viewKpiPage.dart

import 'package:flutter/material.dart';
import '../../Provider/KpiController.dart';
import '../../Domain/Kpi.dart';

class ViewKpiPage extends StatefulWidget {
  final String docId;

  const ViewKpiPage({super.key, required this.docId});

  @override
  State<ViewKpiPage> createState() => _ViewKpiPageState();
}

class _ViewKpiPageState extends State<ViewKpiPage> {
  final KpiController _controller = KpiController();
  Kpi? kpiDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKpi();
  }

  Future<void> _loadKpi() async {
    final data = await _controller.getKpiDetails(widget.docId);
    setState(() {
      kpiDetails = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View KPI Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kpiDetails == null
              ? const Center(child: Text('KPI not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader("Basic Data"),
                      _buildReadOnlyField('KPI Title', kpiDetails!.kpiTitle),
                      _buildReadOnlyField('Category', kpiDetails!.kpiCategory),
                      _buildReadOnlyField('Reporting Year', kpiDetails!.kpiYear.toString()),

                      _sectionHeader("Target Metrics"),
                      _buildReadOnlyField('Target Quantity', kpiDetails!.kpiTarget.toString()),
                      _buildReadOnlyField('Unit', kpiDetails!.kpiUnitOfMeasure),
                      _buildReadOnlyField('Indicator', kpiDetails!.kpiIndicator),

                      _sectionHeader("Linking & Audit"),
                      _buildReadOnlyField('Preacher ID', kpiDetails!.preacherID.toString()),
                      _buildReadOnlyField('Activity ID', kpiDetails!.assignActID.toString()),
                      _buildReadOnlyField('Staff ID', kpiDetails!.staffID.toString()),

                      _sectionHeader("Optional Notes"),
                      _buildReadOnlyField('Description', kpiDetails!.kpiDescription ?? '-'),
                      _buildReadOnlyField('Internal Remarks', kpiDetails!.kpiRemarks ?? '-'),

                      _sectionHeader("Created Date"),
                      _buildReadOnlyField(
                        'Created On',
                        '${kpiDetails!.kpiCreatedDate!.day.toString().padLeft(2, '0')}/'
                        '${kpiDetails!.kpiCreatedDate!.month.toString().padLeft(2, '0')}/'
                        '${kpiDetails!.kpiCreatedDate!.year} '
                        '${kpiDetails!.kpiCreatedDate!.hour.toString().padLeft(2, '0')}:'
                        '${kpiDetails!.kpiCreatedDate!.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
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

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
