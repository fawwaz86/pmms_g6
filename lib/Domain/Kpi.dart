import 'package:cloud_firestore/cloud_firestore.dart';

class Kpi {
  final String docId; // Firestore document ID
  final String kpiTitle;
  final int assignActID;
  final String? kpiDescription; // optional
  final String kpiCategory;
  final int kpiYear;
  final int preacherID;
  final int kpiTarget;
  final String kpiUnitOfMeasure;
  final String kpiIndicator;
  final String? kpiRemarks; // optional
  final dynamic staffID; // number OR string UID
  final DateTime? kpiCreatedDate; // optional, auto-generated

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
    this.kpiCreatedDate,
  });

  // Convert object → Firestore map
  Map<String, dynamic> toMap() {
    return {
      'kpiTitle': kpiTitle,
      'assignActID': assignActID,
      'kpiDescription': kpiDescription?.isEmpty == true ? null : kpiDescription,
      'kpiCategory': kpiCategory,
      'kpiYear': kpiYear,
      'preacherID': preacherID,
      'kpiTarget': kpiTarget,
      'kpiUnitOfMeasure': kpiUnitOfMeasure,
      'kpiIndicator': kpiIndicator,
      'kpiRemarks': kpiRemarks?.isEmpty == true ? null : kpiRemarks,
      'staffID': staffID,
      'kpiCreatedDate': FieldValue.serverTimestamp(),
    };
  }

  // Convert Firestore → object safely
  factory Kpi.fromMap(Map<String, dynamic> map, String docId) {
    int parseNum(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    dynamic parseStaffID(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return value;
      return null;
    }

    return Kpi(
      docId: docId,
      kpiTitle: map['kpiTitle'] ?? '',
      assignActID: parseNum(map['assignActID']),
      kpiDescription: map['kpiDescription'],
      kpiCategory: map['kpiCategory'] ?? '',
      kpiYear: parseNum(map['kpiYear']),
      preacherID: parseNum(map['preacherID']),
      kpiTarget: parseNum(map['kpiTarget']),
      kpiUnitOfMeasure: map['kpiUnitOfMeasure'] ?? '',
      kpiIndicator: map['kpiIndicator'] ?? '',
      kpiRemarks: map['kpiRemarks'],
      staffID: parseStaffID(map['staffID']),
      kpiCreatedDate: map['kpiCreatedDate'] == null
          ? null
          : (map['kpiCreatedDate'] is String
              ? DateTime.tryParse(map['kpiCreatedDate'])
              : (map['kpiCreatedDate'] as Timestamp).toDate()),
    );
  }
}
