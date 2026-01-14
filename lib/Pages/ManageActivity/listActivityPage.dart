// lib/Pages/ManageActivity/listActivityPage.dart

import 'package:flutter/material.dart';
import '../../Domain/activity.dart';
import 'addActivityPage.dart';
import 'editActivityPage.dart';
import 'activityDetailPage.dart';

class ListActivityPage extends StatefulWidget {
  final String userRole; // 'staff' or 'preacher'
  final String userId;

  const ListActivityPage({
    super.key,
    required this.userRole,
    required this.userId,
  });

  @override
  State<ListActivityPage> createState() => _ListActivityPageState();
}

class _ListActivityPageState extends State<ListActivityPage> {
  List<Activity> activities = [];
  List<Activity> filteredActivities = [];
  String searchQuery = '';
  ActivityStatus? filterStatus;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      isLoading = true;
    });

    // TODO: Replace with actual API call
    // For now, using dummy data
    await Future.delayed(const Duration(seconds: 1));
    
    activities = _getDummyActivities();
    _applyFilters();

    setState(() {
      isLoading = false;
    });
  }

  void _applyFilters() {
    filteredActivities = activities.where((activity) {
      // Filter by user role
      if (widget.userRole == 'preacher' && 
          activity.assignedPreacherId != widget.userId) {
        return false;
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!activity.title.toLowerCase().contains(query) &&
            !activity.location.toLowerCase().contains(query) &&
            !activity.assignedPreacherName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by status
      if (filterStatus != null && activity.status != filterStatus) {
        return false;
      }

      return true;
    }).toList();

    // Sort by scheduled date
    filteredActivities.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      _applyFilters();
    });
  }

  void _onFilterChanged(ActivityStatus? status) {
    setState(() {
      filterStatus = status;
      _applyFilters();
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
      // TODO: Call API to delete activity
      setState(() {
        activities.removeWhere((a) => a.id == activity.id);
        _applyFilters();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userRole == 'staff' 
            ? 'Manage Activities' 
            : 'My Activities'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : _buildActivityList(),
          ),
        ],
      ),
      floatingActionButton: widget.userRole == 'staff'
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
    return RefreshIndicator(
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = filteredActivities[index];
          return _buildActivityCard(activity);
        },
      ),
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
              if (widget.userRole == 'staff') ...[
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
                  if (widget.userRole == 'staff') ...[
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
                  ] else if (widget.userRole == 'preacher' && 
                             activity.status != ActivityStatus.completed) ...[
                    ElevatedButton.icon(
                      onPressed: () => _markAsCompleted(activity),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
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
            'No activities found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          if (widget.userRole == 'staff')
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityPage(userId: widget.userId),
      ),
    ).then((_) => _loadActivities());
  }

  void _navigateToEditActivity(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditActivityPage(activity: activity),
      ),
    ).then((_) => _loadActivities());
  }

  void _navigateToActivityDetail(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailPage(
          activity: activity,
          userRole: widget.userRole,
        ),
      ),
    ).then((result) {
      if (result != null) {
        _loadActivities();
      }
    });
  }

  Future<void> _markAsCompleted(Activity activity) async {
    // Navigate to detail page which handles GPS verification
    _navigateToActivityDetail(activity);
  }

  // Dummy data for testing
  List<Activity> _getDummyActivities() {
    return [
      Activity(
        id: '1',
        title: 'Ceramah Agama - Kampung Sungai',
        description: 'Mengadakan ceramah agama kepada penduduk kampung',
        location: 'Kampung Sungai Lembing, Pahang',
        scheduledDate: DateTime.now().add(const Duration(days: 2)),
        assignedPreacherId: 'P001',
        assignedPreacherName: 'Ustaz Ahmad bin Abdullah',
        status: ActivityStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        createdBy: 'Officer 1',
      ),
      Activity(
        id: '2',
        title: 'Program Dakwah Orang Asli',
        description: 'Program dakwah dan bantuan kepada masyarakat Orang Asli',
        location: 'Pos Betau, Cameron Highlands',
        scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
        assignedPreacherId: 'P002',
        assignedPreacherName: 'Ustazah Fatimah binti Hassan',
        status: ActivityStatus.completed,
        completedDate: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        createdBy: 'Officer 2',
      ),
      Activity(
        id: '3',
        title: 'Kelas Pengajian Al-Quran',
        description: 'Kelas pengajian dan tafsir Al-Quran',
        location: 'Masjid Kampung Pulau',
        scheduledDate: DateTime.now(),
        assignedPreacherId: 'P001',
        assignedPreacherName: 'Ustaz Ahmad bin Abdullah',
        status: ActivityStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        createdBy: 'Officer 1',
      ),
    ];
  }
}