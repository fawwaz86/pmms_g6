import 'package:flutter/material.dart';
import '../../Models/Kpi.dart';
import '../../Provider/KpiController.dart';
import 'formKpiPage.dart';
import 'viewKpiPage.dart';

class ListKpiPage extends StatefulWidget {
  const ListKpiPage({super.key});

  @override
  State<ListKpiPage> createState() => _ListKpiPageState();
}

class _ListKpiPageState extends State<ListKpiPage> {
  final KpiController _controller = KpiController();
  List<Kpi> kpiList = [];

  @override
  void initState() {
    super.initState();
    _loadKpiList();
  }

  void _loadKpiList() async {
    final list = await _controller.getAllKpi();
    setState(() {
      kpiList = list;
    });
  }

  // Delete KPI
  void _deleteKpi(String docId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this KPI record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await _controller.deleteKpi(docId);
      if (success) _loadKpiList(); // Refresh list
    }
  }

  // Edit KPI
  void _editKpi(Kpi kpi) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormKpiPage(
          kpiData: kpi.toMap(),
          docId: kpi.docId, // <-- Add this line
        ),
      ),
    );
    _loadKpiList();
  }

  // View KPI
  void _viewKpi(Kpi kpi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewKpiPage(
          docId: kpi.docId, // ✅ pass the required docId
        ),
      ),
    );
  }

  // Add KPI
  void _addKpi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FormKpiPage(),
      ),
    );
    _loadKpiList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KPI List')),
      body: kpiList.isEmpty
          ? const Center(child: Text('No KPI records found'))
          : ListView.builder(
              itemCount: kpiList.length,
              itemBuilder: (context, index) {
                final kpi = kpiList[index];
                return ListTile(
                  title: Text(kpi.kpiTitle),
                  subtitle: Text(
                      'Preacher ID: ${kpi.preacherID}\nYear: ${kpi.kpiYear}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Shrinks the row
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editKpi(kpi),
                        tooltip: 'Edit KPI',
                      ),
                      const SizedBox(width: 8), // Spacing between icons
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteKpi(kpi.docId),
                        tooltip: 'Delete KPI',
                      ),
                    ],
                  ),
                  onTap: () => _viewKpi(kpi), // Tap navigates to view page
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addKpi,
        icon: const Icon(Icons.add),
        label: const Text('Add KPI'),
      ),
    );
  }
}
