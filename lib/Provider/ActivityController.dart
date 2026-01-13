// lib/Provider/ActivityController.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/activity.dart';

class ActivityController {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'activities';

  // 🔹 GET CURRENT USER
  static User? get currentUser => _auth.currentUser;

  // 🔹 GET USER ROLE
  static Future<String?> getUserRole() async {
    if (currentUser == null) return null;

    try {
      // Check if user is staff
      final staffDoc = await _db.collection('users').doc(currentUser!.uid).get();
      if (staffDoc.exists) return 'staff';

      // Check if user is preacher - FIXED: registrations (plural)
      final preacherDoc = await _db.collection('registrations').doc(currentUser!.uid).get();
      if (preacherDoc.exists) return 'preacher';

      return null;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  // 🔹 GET USER DETAILS
  static Future<Map<String, dynamic>?> getUserDetails() async {
    if (currentUser == null) return null;

    try {
      final role = await getUserRole();
      
      if (role == 'staff') {
        final doc = await _db.collection('users').doc(currentUser!.uid).get();
        return doc.data();
      } else if (role == 'preacher') {
        // FIXED: registrations (plural)
        final doc = await _db.collection('registrations').doc(currentUser!.uid).get();
        return doc.data();
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user details: $e');
      return null;
    }
  }

  // 🔹 CREATE ACTIVITY
  static Future<String?> addActivity(Activity activity) async {
    try {
      final docRef = await _db.collection(_collection).add({
        ...activity.toMap(),
        'createdAt': Timestamp.now(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding activity: $e');
      return null;
    }
  }

  // 🔹 READ ALL ACTIVITIES (real-time stream)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllActivities() {
    return _db
        .collection(_collection)
        .orderBy('scheduledDate', descending: true)
        .snapshots();
  }

  // 🔹 READ ACTIVITIES BY PREACHER (real-time stream)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getActivitiesByPreacher(
    String preacherId,
  ) {
    return _db
        .collection(_collection)
        .where('assignedPreacherId', isEqualTo: preacherId)
        .orderBy('scheduledDate', descending: true)
        .snapshots();
  }

  // 🔹 GET SINGLE ACTIVITY
  static Future<DocumentSnapshot<Map<String, dynamic>>> getActivityByDocId(
    String docId,
  ) {
    return _db.collection(_collection).doc(docId).get();
  }

  // 🔹 UPDATE ACTIVITY
  static Future<bool> updateActivity(
    String docId,
    Activity activity,
  ) async {
    try {
      await _db.collection(_collection).doc(docId).update(activity.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating activity: $e');
      return false;
    }
  }

  // 🔹 DELETE ACTIVITY
  static Future<bool> deleteActivity(String docId) async {
    try {
      await _db.collection(_collection).doc(docId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting activity: $e');
      return false;
    }
  }

  // 🔹 MARK AS COMPLETED
  static Future<bool> markActivityCompleted({
    required String docId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _db.collection(_collection).doc(docId).update({
        'status': 'completed',
        'completedDate': Timestamp.now(),
        'completedLatitude': latitude,
        'completedLongitude': longitude,
      });
      return true;
    } catch (e) {
      debugPrint('Error marking activity as completed: $e');
      return false;
    }
  }

  // 🔹 GET ALL PREACHERS - FIXED: registrations (plural)
  static Future<List<Map<String, String>>> getAllPreachers() async {
    try {
      // FIXED: registrations (plural)
      final snapshot = await _db.collection('registrations').get();
      
      final List<Map<String, String>> preachers = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        preachers.add({
          'id': doc.id,
          'name': data['preacherName']?.toString() ?? 'Unknown',
        });
      }
      
      debugPrint('Found ${preachers.length} preachers: $preachers');
      return preachers;
    } catch (e) {
      debugPrint('Error getting preachers: $e');
      return [];
    }
  }

  // 🔹 CONVERT QuerySnapshot TO List<Activity>
  static List<Activity> convertToActivityList(QuerySnapshot snapshot) {
    final List<Activity> activities = [];
    
    for (var doc in snapshot.docs) {
      try {
        final activity = Activity.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>
        );
        activities.add(activity);
      } catch (e) {
        debugPrint('Error converting document ${doc.id} to Activity: $e');
        // Skip this document and continue with others
      }
    }
    
    return activities;
  }
}

// Helper to use debugPrint instead of print
void debugPrint(String message) {
  assert(() {
    print(message);
    return true;
  }());
}