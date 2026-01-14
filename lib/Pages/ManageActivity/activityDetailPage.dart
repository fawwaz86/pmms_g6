import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Domain/activity.dart';
import '../../Provider/ActivityController.dart';

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
  late Activity _currentActivity;

  @override
  void initState() {
    super.initState();
    _currentActivity = widget.activity;
  }

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
            _buildStatusBadge(),
            const SizedBox(height: 20),
            Text(
              _currentActivity.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailCard(
              icon: Icons.description,
              title: 'Description',
              content: _currentActivity.description,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              icon: Icons.location_on,
              title: 'Location',
              content: _currentActivity.location,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              icon: Icons.calendar_today,
              title: 'Scheduled Date',
              content: _formatDate(_currentActivity.scheduledDate),
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              icon: Icons.person,
              title: 'Assigned Preacher',
              content: _currentActivity.assignedPreacherName,
            ),
            const SizedBox(height: 12),
            if (_currentActivity.notes != null && 
                _currentActivity.notes!.isNotEmpty) ...[
              _buildDetailCard(
                icon: Icons.note,
                title: 'Notes',
                content: _currentActivity.notes!,
              ),
              const SizedBox(height: 12),
            ],
            if (_currentActivity.status == ActivityStatus.completed) ...[
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
            const Divider(height: 32),
            _buildCreatedByInfo(),
            const SizedBox(height: 24),
            if (widget.userRole == 'preacher' && 
                _currentActivity.status != ActivityStatus.completed &&
                _currentActivity.status != ActivityStatus.cancelled)
              _buildPreacherActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor(_currentActivity.status);
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
            _getStatusIcon(_currentActivity.status),
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _currentActivity.status.displayName,
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
            if (_currentActivity.completedDate != null) ...[
              _buildInfoRow(
                'Date & Time',
                _formatDateTime(_currentActivity.completedDate!),
              ),
              const SizedBox(height: 8),
            ],
            if (_currentActivity.completedLatitude != null &&
                _currentActivity.completedLongitude != null) ...[
              _buildInfoRow(
                'GPS Location',
                '${_currentActivity.completedLatitude!.toStringAsFixed(6)}, ${_currentActivity.completedLongitude!.toStringAsFixed(6)}',
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _openInMaps(
                  _currentActivity.completedLatitude!,
                  _currentActivity.completedLongitude!,
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
              _currentActivity.createdBy,
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              'Created On',
              _formatDateTime(_currentActivity.createdAt),
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
    setState(() => _isProcessing = true);

    try {
      // Check location permission
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) {
          throw Exception('Location permission denied');
        }
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
                  'Lat: ${position.latitude.toStringAsFixed(6)}\nLong: ${position.longitude.toStringAsFixed(6)}',
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
          // Using static method from Controller
          final success = await ActivityController.markActivityCompleted(
            docId: _currentActivity.id,
            latitude: position.latitude,
            longitude: position.longitude,
          );

          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity marked as completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else {
              throw Exception('Failed to update activity');
            }
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
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _openInMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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