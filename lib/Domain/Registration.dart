import 'package:cloud_firestore/cloud_firestore.dart';

class Registration {
  final String id; // Firestore document ID

  // Preacher info
  final String preacherName;
  final String preacherIC;
  final String preacherGender;
  final DateTime preacherDOB;
  final String preacherNationality;
  final String preacherNumber;
  final String preacherEmail;
  final String qualification;
  final String institutionName;
  final String preacherField;

  // System fields
  final String status;           // pending | approved | rejected
  final String registeredBy;     // staff userId
  final String? userId;          // preacher userId (after approval)
  final DateTime createdAt;

  Registration({
    required this.id,
    required this.preacherName,
    required this.preacherIC,
    required this.preacherGender,
    required this.preacherDOB,
    required this.preacherNationality,
    required this.preacherNumber,
    required this.preacherEmail,
    required this.qualification,
    required this.institutionName,
    required this.preacherField,
    required this.status,
    required this.registeredBy,
    required this.createdAt,
    this.userId,
  });

  factory Registration.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Registration(
      id: doc.id,
      preacherName: data['preacherName'],
      preacherIC: data['preacherIC'],
      preacherGender: data['preacherGender'],
      preacherDOB: (data['preacherDOB'] as Timestamp).toDate(),
      preacherNationality: data['preacherNationality'],
      preacherNumber: data['preacherNumber'],
      preacherEmail: data['preacherEmail'],
      qualification: data['qualification'],
      institutionName: data['institutionName'],
      preacherField: data['preacherField'],
      status: data['status'],
      registeredBy: data['registeredBy'],
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'preacherName': preacherName,
      'preacherIC': preacherIC,
      'preacherGender': preacherGender,
      'preacherDOB': Timestamp.fromDate(preacherDOB),
      'preacherNationality': preacherNationality,
      'preacherNumber': preacherNumber,
      'preacherEmail': preacherEmail,
      'qualification': qualification,
      'institutionName': institutionName,
      'preacherField': preacherField,
      'status': status,
      'registeredBy': registeredBy,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
