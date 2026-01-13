import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationController {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'registrations';

  // 🔹 CREATE
  static Future<void> addRegistration(Map<String, dynamic> data) async {
    await _db.collection(_collection).add({
      ...data,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  // 🔹 READ (real-time stream)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllRegistrations() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🔹 GET SINGLE (NON-NULLABLE)
  static Future<DocumentSnapshot<Map<String, dynamic>>> 
      getRegistrationByDocId(String docId) {
    return _db
        .collection(_collection)
        .doc(docId)
        .get();
  }

  // 🔹 UPDATE
  static Future<void> updateRegistration(
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(_collection).doc(docId).update(data);
  }

  // 🔹 DELETE
  static Future<void> deleteRegistration(String docId) async {
    await _db.collection(_collection).doc(docId).delete();
  }
}
