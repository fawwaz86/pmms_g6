// lib/Models/activity.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ActivityStatus.pending:
        return 'Pending';
      case ActivityStatus.inProgress:
        return 'In Progress';
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Helper to get status from string
  static ActivityStatus fromString(String status) {
    return ActivityStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => ActivityStatus.pending,
    );
  }
}

class Activity {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime scheduledDate;
  final String assignedPreacherId;
  final String assignedPreacherName;
  final ActivityStatus status;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? completedDate;
  final double? completedLatitude;
  final double? completedLongitude;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.scheduledDate,
    required this.assignedPreacherId,
    required this.assignedPreacherName,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.createdBy,
    this.completedDate,
    this.completedLatitude,
    this.completedLongitude,
  });

  // Convert Activity to Map for Firebase (CREATE/UPDATE)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'assignedPreacherId': assignedPreacherId,
      'assignedPreacherName': assignedPreacherName,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'completedDate': completedDate != null 
          ? Timestamp.fromDate(completedDate!) 
          : null,
      'completedLatitude': completedLatitude,
      'completedLongitude': completedLongitude,
    };
  }

  // Create Activity from Firebase DocumentSnapshot
  factory Activity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    
    if (data == null) {
      throw Exception('Document data is null');
    }
    
    return Activity(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      scheduledDate: _parseTimestamp(data['scheduledDate']),
      assignedPreacherId: data['assignedPreacherId'] ?? '',
      assignedPreacherName: data['assignedPreacherName'] ?? '',
      status: ActivityStatus.fromString(data['status'] ?? 'pending'),
      notes: data['notes'],
      createdAt: _parseTimestamp(data['createdAt']),
      createdBy: data['createdBy'] ?? '',
      completedDate: data['completedDate'] != null 
          ? _parseTimestamp(data['completedDate']) 
          : null,
      completedLatitude: data['completedLatitude']?.toDouble(),
      completedLongitude: data['completedLongitude']?.toDouble(),
    );
  }

  // Helper method to parse Timestamp to DateTime
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    // If it's a string or other format, return current time as fallback
    return DateTime.now();
  }

  // Create Activity from Map (useful for local operations)
  factory Activity.fromMap(Map<String, dynamic> map, String id) {
    return Activity(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      scheduledDate: map['scheduledDate'] is Timestamp
          ? (map['scheduledDate'] as Timestamp).toDate()
          : DateTime.parse(map['scheduledDate']),
      assignedPreacherId: map['assignedPreacherId'] ?? '',
      assignedPreacherName: map['assignedPreacherName'] ?? '',
      status: ActivityStatus.fromString(map['status'] ?? 'pending'),
      notes: map['notes'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'] ?? '',
      completedDate: map['completedDate'] != null
          ? (map['completedDate'] is Timestamp
              ? (map['completedDate'] as Timestamp).toDate()
              : DateTime.parse(map['completedDate']))
          : null,
      completedLatitude: map['completedLatitude']?.toDouble(),
      completedLongitude: map['completedLongitude']?.toDouble(),
    );
  }

  // Copy with method for creating modified copies
  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? scheduledDate,
    String? assignedPreacherId,
    String? assignedPreacherName,
    ActivityStatus? status,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
    DateTime? completedDate,
    double? completedLatitude,
    double? completedLongitude,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      assignedPreacherId: assignedPreacherId ?? this.assignedPreacherId,
      assignedPreacherName: assignedPreacherName ?? this.assignedPreacherName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      completedDate: completedDate ?? this.completedDate,
      completedLatitude: completedLatitude ?? this.completedLatitude,
      completedLongitude: completedLongitude ?? this.completedLongitude,
    );
  }

  // Convert to JSON (useful for debugging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'scheduledDate': scheduledDate.toIso8601String(),
      'assignedPreacherId': assignedPreacherId,
      'assignedPreacherName': assignedPreacherName,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'completedDate': completedDate?.toIso8601String(),
      'completedLatitude': completedLatitude,
      'completedLongitude': completedLongitude,
    };
  }

  // String representation for debugging
  @override
  String toString() {
    return 'Activity(id: $id, title: $title, status: ${status.name}, '
        'scheduledDate: $scheduledDate)';
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Activity &&
        other.id == id &&
        other.title == title &&
        other.status == status;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ status.hashCode;

  // Helper methods for UI
  
  /// Check if activity is editable
  bool get isEditable {
    return status != ActivityStatus.completed && 
           status != ActivityStatus.cancelled;
  }

  /// Check if activity can be marked as completed
  bool get canBeCompleted {
    return status == ActivityStatus.pending || 
           status == ActivityStatus.inProgress;
  }

  /// Check if activity is overdue
  bool get isOverdue {
    if (status == ActivityStatus.completed || 
        status == ActivityStatus.cancelled) {
      return false;
    }
    return DateTime.now().isAfter(scheduledDate);
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case ActivityStatus.pending:
        return 'orange';
      case ActivityStatus.inProgress:
        return 'blue';
      case ActivityStatus.completed:
        return 'green';
      case ActivityStatus.cancelled:
        return 'red';
    }
  }

  /// Get formatted scheduled date
  String get formattedScheduledDate {
    return '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
  }

  /// Get formatted completed date
  String get formattedCompletedDate {
    if (completedDate == null) return 'N/A';
    return '${completedDate!.day}/${completedDate!.month}/${completedDate!.year} '
        'at ${completedDate!.hour}:${completedDate!.minute.toString().padLeft(2, '0')}';
  }

  /// Get GPS coordinates as string
  String get gpsCoordinates {
    if (completedLatitude == null || completedLongitude == null) {
      return 'N/A';
    }
    return '${completedLatitude!.toStringAsFixed(6)}, '
        '${completedLongitude!.toStringAsFixed(6)}';
  }
}