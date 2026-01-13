import 'package:flutter/material.dart';
import '../../Provider/KpiController.dart';
import '../../Models/Kpi.dart';

class ViewKpiPage extends StatefulWidget {
  // Use Firestore document ID
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
    _displayKpi();
  }

  // ✅ Call getKpiDetails instead of getKpiById
  Future<void> _displayKpi() async {
    final data = await _controller.getKpiDetails(widget.docId);

    setState(() {
      kpiDetails = data;
      isLoading = false;
    });
  }

  void _navBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View KPI Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navBack,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kpiDetails == null
              ? const Center(child: Text('KPI details not found'))
              : _buildDetailsList(),
    );
  }

  Widget _buildDetailsList() {
    final kpi = kpiDetails!;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildInfoTile('Title', kpi.kpiTitle),
        _buildInfoTile('Category', kpi.kpiCategory),
        _buildInfoTile('Year', kpi.kpiYear.toString()),
        _buildInfoTile('Target', '${kpi.kpiTarget} ${kpi.kpiUnitOfMeasure}'),
        _buildInfoTile('Indicator', kpi.kpiIndicator),
        _buildInfoTile('Description', kpi.kpiDescription ?? '-'),
        _buildInfoTile('Remarks', kpi.kpiRemarks ?? '-'),
        _buildInfoTile('Assigned Preacher ID', kpi.preacherID.toString()),
        _buildInfoTile('Staff ID', kpi.staffID.toString()),
        _buildInfoTile(
          'Created Date',
          kpi.kpiCreatedDate.toLocal().toString(),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }
}
