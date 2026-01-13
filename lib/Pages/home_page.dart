import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your pages
import 'ManageKpi/listKpiPage.dart';
import 'ManageActivity/listActivityPage.dart';
import 'ManageRegistration/listRegistrationPage.dart';
import 'ManageUserProfile/viewProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userRole = '';
  String userName = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      userRole = doc['role']; // 'staff' or 'preacher'
      userName = doc['name'];
      userId = uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (userRole.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preacher Monitoring Management System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= USER INFO =================
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      userRole == 'admin'
                          ? Icons.security
                          : userRole == 'staff'
                              ? Icons.admin_panel_settings
                              : Icons.person,
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
                      userRole == 'admin'
                          ? 'System Admin'
                          : userRole == 'staff'
                              ? 'MUIP Officer'
                              : 'Preacher',
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

            // ================= DASHBOARD =================
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ================= MODULES =================
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // ACTIVITIES
                  _buildModuleCard(
                    context,
                    title: 'Activities',
                    icon: Icons.event_note,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListActivityPage(
                            userRole: userRole,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),

                  // KPI
                  _buildModuleCard(
                    context,
                    title: 'Manage KPI',
                    icon: Icons.assessment,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListKpiPage(),
                        ),
                      );
                    },
                  ),

                  // ================= ADMIN =================
                  if (userRole == 'admin') ...[
                    _buildModuleCard(
                      context,
                      title: 'Staff Approval',
                      icon: Icons.verified_user,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListRegistrationPage(
                              mode: 'staffApproval',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context,
                      title: 'View Preachers',
                      icon: Icons.record_voice_over,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListRegistrationPage(
                              mode: 'preacherView',
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // ================= STAFF =================
                  if (userRole == 'staff')
                    _buildModuleCard(
                      context,
                      title: 'Manage Preachers',
                      icon: Icons.manage_accounts,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListRegistrationPage(
                              mode: 'preacherManagement',
                            ),
                          ),
                        );
                      },
                    ),

                  // ================= PROFILE =================
                  if (userRole == 'staff' || userRole == 'preacher')
                    _buildModuleCard(
                      context,
                      title: 'My Profile',
                      icon: Icons.person,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ViewProfilePage(),
                          ),
                        );
                      },
                    ),

                  // REPORTS
                  _buildModuleCard(
                    context,
                    title: 'Reports',
                    icon: Icons.description,
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Module coming soon'),
                        ),
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

  // ================= CARD BUILDER =================
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
          padding: const EdgeInsets.all(16),
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
