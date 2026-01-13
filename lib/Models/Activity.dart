// lib/Models/activity.dart

class Activity {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime scheduledDate;
  final String assignedPreacherId;
  final String assignedPreacherName;
  final ActivityStatus status;
  final DateTime? completedDate;
  final double? completedLatitude;
  final double? completedLongitude;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.scheduledDate,
    required this.assignedPreacherId,
    required this.assignedPreacherName,
    required this.status,
    this.completedDate,
    this.completedLatitude,
    this.completedLongitude,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  // Convert Activity to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'scheduledDate': scheduledDate.toIso8601String(),
      'assignedPreacherId': assignedPreacherId,
      'assignedPreacherName': assignedPreacherName,
      'status': status.toString(),
      'completedDate': completedDate?.toIso8601String(),
      'completedLatitude': completedLatitude,
      'completedLongitude': completedLongitude,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  // Create Activity from Map
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      scheduledDate: DateTime.parse(map['scheduledDate']),
      assignedPreacherId: map['assignedPreacherId'],
      assignedPreacherName: map['assignedPreacherName'],
      status: ActivityStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ActivityStatus.pending,
      ),
      completedDate: map['completedDate'] != null 
          ? DateTime.parse(map['completedDate']) 
          : null,
      completedLatitude: map['completedLatitude'],
      completedLongitude: map['completedLongitude'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
    );
  }

  // Create a copy with updated fields
  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? scheduledDate,
    String? assignedPreacherId,
    String? assignedPreacherName,
    ActivityStatus? status,
    DateTime? completedDate,
    double? completedLatitude,
    double? completedLongitude,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
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
      completedDate: completedDate ?? this.completedDate,
      completedLatitude: completedLatitude ?? this.completedLatitude,
      completedLongitude: completedLongitude ?? this.completedLongitude,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

enum ActivityStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

// Helper extension for status display
extension ActivityStatusExtension on ActivityStatus {
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
}