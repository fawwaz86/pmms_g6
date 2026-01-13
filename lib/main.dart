import 'package:flutter/material.dart';
// Import your pages
import 'Pages/ManageKpi/listKpiPage.dart';
import 'Pages/ManageActivity/listActivityPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMS Management System',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Preacher Monitoring Management System'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Simulating logged-in user

  String userRole = 'staff'; // Change to 'preacher' to test preacher view
  String userId = 'U001';
  String userName = 'Test Officer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // Role switcher for testing
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (String role) {
              setState(() {
                userRole = role;
                if (role == 'staff') {
                  userId = 'U001';
                  userName = 'Test Officer';
                } else {
                  userId = 'P001';
                  userName = 'Ustaz Ahmad';
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Switched to $role view')),
              );
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'staff',
                child: Text('Staff View'),
              ),
              const PopupMenuItem(
                value: 'preacher',
                child: Text('Preacher View'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      userRole == 'staff' ? Icons.admin_panel_settings : Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userRole == 'staff' ? 'MUIP Officer' : 'Preacher',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Dashboard Title
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Module Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildModuleCard(
                    context,
                    title: 'Activities',
                    icon: Icons.event_note,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListActivityPage(
                            userRole: userRole,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildModuleCard(
                    context,
                    title: 'Manage KPI',
                    icon: Icons.assessment,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListKpiPage(),
                        ),
                      );
                    },
                  ),
                  _buildModuleCard(
                    context,
                    title: 'User Management',
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Module coming soon')),
                      );
                    },
                  ),
                  _buildModuleCard(
                    context,
                    title: 'Reports',
                    icon: Icons.description,
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Module coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}