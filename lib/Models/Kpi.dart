import 'package:cloud_firestore/cloud_firestore.dart';

class Kpi {
  final String docId; // 🔹 Firestore document ID
  final String kpiTitle;
  final int assignActID;
  final String? kpiDescription;
  final String kpiCategory;
  final int kpiYear;
  final int preacherID;
  final int kpiTarget;
  final String kpiUnitOfMeasure;
  final String kpiIndicator;
  final String? kpiRemarks;
  final int staffID;
  final DateTime kpiCreatedDate;

  Kpi({
    required this.docId,
    required this.kpiTitle,
    required this.assignActID,
    this.kpiDescription,
    required this.kpiCategory,
    required this.kpiYear,
    required this.preacherID,
    required this.kpiTarget,
    required this.kpiUnitOfMeasure,
    required this.kpiIndicator,
    this.kpiRemarks,
    required this.staffID,
    required this.kpiCreatedDate,
  });

  // Convert object → Firestore map
  Map<String, dynamic> toMap() {
    return {
      'kpiTitle': kpiTitle,
      'assignActID': assignActID,
      'kpiDescription': kpiDescription,
      'kpiCategory': kpiCategory,
      'kpiYear': kpiYear,
      'preacherID': preacherID,
      'kpiTarget': kpiTarget,
      'kpiUnitOfMeasure': kpiUnitOfMeasure,
      'kpiIndicator': kpiIndicator,
      'kpiRemarks': kpiRemarks,
      'staffID': staffID,
      'kpiCreatedDate': kpiCreatedDate.toIso8601String(),
    };
  }

  // Convert Firestore → object
  factory Kpi.fromMap(Map<String, dynamic> map, String docId) {
    return Kpi(
      docId: docId,
      kpiTitle: map['kpiTitle'] ?? '',
      assignActID: (map['assignActID'] as num?)?.toInt() ?? 0,
      kpiDescription: map['kpiDescription'],
      kpiCategory: map['kpiCategory'] ?? '',
      kpiYear: (map['kpiYear'] as num?)?.toInt() ?? 0,
      preacherID: (map['preacherID'] as num?)?.toInt() ?? 0,
      kpiTarget: (map['kpiTarget'] as num?)?.toInt() ?? 0,
      kpiUnitOfMeasure: map['kpiUnitOfMeasure'] ?? '',
      kpiIndicator: map['kpiIndicator'] ?? '',
      kpiRemarks: map['kpiRemarks'],
      staffID: (map['staffID'] as num?)?.toInt() ?? 0,
      kpiCreatedDate: map['kpiCreatedDate'] is String
          ? DateTime.parse(map['kpiCreatedDate'])
          : (map['kpiCreatedDate'] as Timestamp).toDate(),
    );
  }
}
