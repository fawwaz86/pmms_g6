import 'package:flutter/material.dart';

class ListKpiPage extends StatefulWidget {
  const ListKpiPage({super.key});

  @override
  State<ListKpiPage> createState() => _ListKpiPageState();
}

class _ListKpiPageState extends State<ListKpiPage> {
  // Example KPI list
  final List<String> _kpiList = [
    'Increase sales by 10%',
    'Customer satisfaction 90%',
    'Reduce support tickets by 20%',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage KPI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _kpiList.isEmpty
            ? const Center(
                child: Text('No KPIs found', style: TextStyle(fontSize: 18)),
              )
            : ListView.builder(
                itemCount: _kpiList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(_kpiList[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _kpiList.removeAt(index); // remove KPI
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new KPI
        },
        child: const Icon(Icons.add),
        tooltip: 'Add KPI',
      ),
    );
  }
}
