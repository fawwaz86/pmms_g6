import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Domain/Kpi.dart';
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

  String? userRole;
  int? preacherID; // Needed for filtering

  bool isLoading = true; // show loading while fetching data

  @override
  void initState() {
    super.initState();
    _loadUserAndKpi();
  }

  /// Load user role AND KPI list correctly
  Future<void> _loadUserAndKpi() async {
    setState(() {
      isLoading = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final userData = userDoc.data();
      if (userData == null) {
        print('❌ User document not found!');
        return;
      }

      userRole = userData['role'];

      if (userRole == 'preacher') {
        preacherID = userData['preacherID'];
        if (preacherID == null) {
          print('❌ preacherID missing in users doc');
          kpiList = [];
        } else {
          kpiList = await _controller.getAllKpi(preacherID: preacherID);
        }
      } else {
        // Staff or Admin → load all KPIs
        kpiList = await _controller.getAllKpi();
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user & KPI: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          kpiList = [];
        });
      }
    }
  }

  /// Delete KPI
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
      if (success) _loadUserAndKpi();
    }
  }

  /// Edit KPI
  void _editKpi(Kpi kpi) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormKpiPage(
          kpiData: kpi.toMap(),
          docId: kpi.docId,
        ),
      ),
    );
    _loadUserAndKpi();
  }

  /// View KPI
  void _viewKpi(Kpi kpi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewKpiPage(docId: kpi.docId),
      ),
    );
  }

  /// Add KPI
  void _addKpi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormKpiPage()),
    );
    _loadUserAndKpi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KPI List')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kpiList.isEmpty
              ? const Center(child: Text('No KPI records found'))
              : ListView.builder(
                  itemCount: kpiList.length,
                  itemBuilder: (context, index) {
                    final kpi = kpiList[index];
                    return ListTile(
                      title: Text(kpi.kpiTitle),
                      subtitle: Text(
                          'Preacher ID: ${kpi.preacherID}\nYear: ${kpi.kpiYear}'),
                      trailing: (userRole == 'staff' || userRole == 'admin')
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editKpi(kpi),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteKpi(kpi.docId),
                                ),
                              ],
                            )
                          : null,
                      onTap: () => _viewKpi(kpi),
                    );
                  },
                ),
      floatingActionButton: (userRole == 'staff' || userRole == 'admin')
          ? FloatingActionButton.extended(
              onPressed: _addKpi,
              icon: const Icon(Icons.add),
              label: const Text('Add KPI'),
            )
          : null,
    );
  }
}
