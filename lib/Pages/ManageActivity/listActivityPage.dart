// lib/Pages/ManageActivity/listActivityPage.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Models/activity.dart';
import '../../Provider/ActivityController.dart';
import 'addActivityPage.dart';
import 'editActivityPage.dart';
import 'activityDetailPage.dart';

class ListActivityPage extends StatefulWidget {
  const ListActivityPage({super.key});

  @override
  State<ListActivityPage> createState() => _ListActivityPageState();
}

class _ListActivityPageState extends State<ListActivityPage> {
  String? userRole;
  String? userId;
  String? userName;
  List<Activity> filteredActivities = [];
  String searchQuery = '';
  ActivityStatus? filterStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
  setState(() => isLoading = true);

  try {
    // DEBUG: Print current user info
    final currentUser = ActivityController.currentUser;
    print('🔍 DEBUG - Current User Auth UID: ${currentUser?.uid}');
    print('🔍 DEBUG - Current User Email: ${currentUser?.email}');
    
    // DEBUG: Check what's in the database
    final staffCheck = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    print('🔍 DEBUG - Is in users collection? ${staffCheck.exists}');
    if (staffCheck.exists) {
      print('🔍 DEBUG - Users doc data: ${staffCheck.data()}');
    }
    
    final preacherCheck = await FirebaseFirestore.instance
        .collection('registrations')
        .where('userId', isEqualTo: currentUser.uid)
        .get();
    print('🔍 DEBUG - Preacher query results: ${preacherCheck.docs.length}');
    if (preacherCheck.docs.isNotEmpty) {
      print('🔍 DEBUG - Registrations doc data: ${preacherCheck.docs.first.data()}');
    }
    
    // Also check by email as backup
    final preacherByEmail = await FirebaseFirestore.instance
        .collection('registrations')
        .where('preacherEmail', isEqualTo: currentUser.email)
        .get();
    print('🔍 DEBUG - Preacher by email results: ${preacherByEmail.docs.length}');
    if (preacherByEmail.docs.isNotEmpty) {
      print('🔍 DEBUG - Found by email: ${preacherByEmail.docs.first.data()}');
    }

    // Original code continues...
    userRole = await ActivityController.getUserRole();
    print('🔍 DEBUG - Detected Role: $userRole');
    
    userId = ActivityController.currentUser?.uid;

    final userDetails = await ActivityController.getUserDetails();
    if (userDetails != null) {
      if (userRole == 'staff') {
        userName = userDetails['name'] ?? userDetails['email'];
      } else if (userRole == 'preacher') {
        userName = userDetails['preacherName'] ?? userDetails['preacherEmail'];
      }
    }

    setState(() => isLoading = false);
  } catch (e) {
    print('❌ ERROR in _initializeUser: $e');
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }
}

  void _applyFilters(List<Activity> activities) {
    filteredActivities = activities.where((activity) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!activity.title.toLowerCase().contains(query) &&
            !activity.location.toLowerCase().contains(query) &&
            !activity.assignedPreacherName.toLowerCase().contains(query)) {
          return false;
        }
      }

      if (filterStatus != null && activity.status != filterStatus) {
        return false;
      }

      return true;
    }).toList();

    filteredActivities.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  void _onFilterChanged(ActivityStatus? status) {
    setState(() {
      filterStatus = status;
    });
  }

  Future<void> _deleteActivity(Activity activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${activity.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Using static method
      final success = await ActivityController.deleteActivity(activity.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'Activity deleted successfully' 
                : 'Failed to delete activity'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userRole == null || userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Unable to load user information'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(userRole == 'staff' ? 'Manage Activities' : 'My Activities'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // Using static methods (like your friend)
              stream: userRole == 'preacher'
                  ? ActivityController.getActivitiesByPreacher(userId!)
                  : ActivityController.getAllActivities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Convert QuerySnapshot to List<Activity>
                final allActivities = ActivityController.convertToActivityList(snapshot.data!);
                _applyFilters(allActivities);

                if (filteredActivities.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildActivityList();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: userRole == 'staff'
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddActivity,
              icon: const Icon(Icons.add),
              label: const Text('Add Activity'),
            )
          : null,
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search activities...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', ActivityStatus.pending),
                const SizedBox(width: 8),
                _buildFilterChip('In Progress', ActivityStatus.inProgress),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', ActivityStatus.completed),
                const SizedBox(width: 8),
                _buildFilterChip('Cancelled', ActivityStatus.cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ActivityStatus? status) {
    final isSelected = filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _onFilterChanged(selected ? status : null),
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        final activity = filteredActivities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final statusColor = _getStatusColor(activity.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToActivityDetail(activity),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activity.status.displayName,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      activity.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(activity.scheduledDate),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (userRole == 'staff') ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      activity.assignedPreacherName,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (userRole == 'staff') ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToEditActivity(activity),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteActivity(activity),
                      tooltip: 'Delete',
                    ),
                  ] else if (userRole == 'preacher' && 
                             activity.status != ActivityStatus.completed &&
                             activity.status != ActivityStatus.cancelled) ...[
                    TextButton.icon(
                      onPressed: () => _navigateToActivityDetail(activity),
                      icon: const Icon(Icons.remove_red_eye),
                      label: const Text('View Details'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty || filterStatus != null
                ? 'No activities match your filters'
                : 'No activities found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          if (userRole == 'staff' && searchQuery.isEmpty && filterStatus == null)
            TextButton(
              onPressed: _navigateToAddActivity,
              child: const Text('Add your first activity'),
            ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToAddActivity() {
    if (userId == null || userName == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityPage(userId: userName!),
      ),
    );
  }

  void _navigateToEditActivity(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditActivityPage(activity: activity),
      ),
    );
  }

  void _navigateToActivityDetail(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailPage(
          activity: activity,
          userRole: userRole!,
        ),
      ),
    );
  }
}