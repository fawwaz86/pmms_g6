import 'package:flutter/material.dart';

class ListKpiPage extends StatelessWidget {
  const ListKpiPage({super.key});


// Test KPI for branching
// Test to merge this branch with main 
// Check for pull, merege conflict, etc.

  @override
  Widget build(BuildContext context) {
    // Dummy KPI data
    final List<Map<String, String>> kpiList = [
      {"title": "Increase Sales", "target": "10%"},
      {"title": "Customer Feedback", "target": "90% positive"},
      {"title": "Reduce Complaints", "target": "5 per month"},
    ];

    return Scaffold(
      appBar: AppBar(
        // AppBar for ListKpiPage
        title: const Text('List of KPIs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: kpiList.length,
          itemBuilder: (context, index) {
            final kpi = kpiList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(kpi["title"] ?? ""),
                subtitle: Text("Target: ${kpi["target"]}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Here you can navigate to KPI details page later
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on ${kpi["title"]}')),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
