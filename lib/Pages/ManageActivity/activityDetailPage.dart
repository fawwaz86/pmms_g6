// lib/Pages/ManageActivity/activityDetailPage.dart

import 'package:flutter/material.dart';
import '../../Models/activity.dart';
// For GPS functionality, you'll need to add to pubspec.yaml:
// geolocator: ^10.1.0
// permission_handler: ^11.0.1

class ActivityDetailPage extends StatefulWidget {
  final Activity activity;
  final String userRole;

  const ActivityDetailPage({
    super.key,
    required this.activity,
    required this.userRole,
  });

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusBadge(),
            const SizedBox(height: 20),

            // Activity Title
            Text(
              widget.activity.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Activity Details Card
            _buildDetailCard(
              icon: Icons.description,
              title: 'Description',
              content: widget.activity.description,
            ),
            const SizedBox(height: 12),

            _buildDetailCard(
              icon: Icons.location_on,
              title: 'Location',
              content: widget.activity.location,
            ),
            const SizedBox(height: 12),

            _buildDetailCard(
              icon: Icons.calendar_today,
              title: 'Scheduled Date',
              content: _formatDate(widget.activity.scheduledDate),
            ),
            const SizedBox(height: 12),

            _buildDetailCard(
              icon: Icons.person,
              title: 'Assigned Preacher',
              content: widget.activity.assignedPreacherName,
            ),
            const SizedBox(height: 12),

            if (widget.activity.notes != null && 
                widget.activity.notes!.isNotEmpty) ...[
              _buildDetailCard(
                icon: Icons.note,
                title: 'Notes',
                content: widget.activity.notes!,
              ),
              const SizedBox(height: 12),
            ],

            // Completion Information
            if (widget.activity.status == ActivityStatus.completed) ...[
              const Divider(height: 32),
              const Text(
                'Completion Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildCompletionInfo(),
              const SizedBox(height: 12),
            ],

            // Created By Information
            const Divider(height: 32),
            _buildCreatedByInfo(),
            const SizedBox(height: 24),

            // Action Buttons for Preacher
            if (widget.userRole == 'preacher' && 
                widget.activity.status != ActivityStatus.completed &&
                widget.activity.status != ActivityStatus.cancelled)
              _buildPreacherActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor(widget.activity.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(widget.activity.status),
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.activity.status.displayName,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionInfo() {
    return Card(
      color: Colors.green[50],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (widget.activity.completedDate != null) ...[
              _buildInfoRow(
                'Date & Time',
                _formatDateTime(widget.activity.completedDate!),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.activity.completedLatitude != null &&
                widget.activity.completedLongitude != null) ...[
              _buildInfoRow(
                'GPS Location',
                '${widget.activity.completedLatitude!.toStringAsFixed(6)}, ${widget.activity.completedLongitude!.toStringAsFixed(6)}',
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _openInMaps(
                  widget.activity.completedLatitude!,
                  widget.activity.completedLongitude!,
                ),
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedByInfo() {
    return Card(
      color: Colors.grey[50],
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Created By',
              widget.activity.createdBy,
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              'Created On',
              _formatDateTime(widget.activity.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPreacherActions() {
    return Column(
      children: [
        const Divider(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _markAsCompleted,
            icon: const Icon(Icons.check_circle, size: 24),
            label: const Text(
              'Mark as Completed with GPS Verification',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your GPS location will be verified when you mark this activity as completed.',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markAsCompleted() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: Implement GPS location verification
      // This requires adding the geolocator package
      // Example:
      // Position position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );

      // Simulate GPS check
      await Future.delayed(const Duration(seconds: 2));

      // For now, using dummy GPS coordinates
      final double latitude = 3.5896 + (DateTime.now().millisecond / 10000);
      final double longitude = 103.3893 + (DateTime.now().millisecond / 10000);

      if (mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Completion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('GPS Location verified:'),
                const SizedBox(height: 8),
                Text(
                  'Lat: ${latitude.toStringAsFixed(6)}\nLong: ${longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Mark this activity as completed?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          // TODO: Call API to update activity status with GPS coordinates
          final updatedActivity = widget.activity.copyWith(
            status: ActivityStatus.completed,
            completedDate: DateTime.now(),
            completedLatitude: latitude,
            completedLongitude: longitude,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Activity marked as completed successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Return to previous screen
            Navigator.pop(context, updatedActivity);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _openInMaps(double latitude, double longitude) {
    // TODO: Implement opening in maps app
    // You can use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening location: $latitude, $longitude'),
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

  IconData _getStatusIcon(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.pending:
        return Icons.schedule;
      case ActivityStatus.inProgress:
        return Icons.play_arrow;
      case ActivityStatus.completed:
        return Icons.check_circle;
      case ActivityStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}