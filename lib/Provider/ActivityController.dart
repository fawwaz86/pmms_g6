// lib/Controllers/activity_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Domain/activity.dart';

class ActivityController {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'activities';

  // 🔹 GET CURRENT USER
  static User? get currentUser => _auth.currentUser;

  // 🔹 GET USER ROLE - PROPERLY FIXED
  static Future<String?> getUserRole() async {
    if (currentUser == null) return null;

    try {
      // Check users collection and READ THE ROLE FIELD
      final userDoc = await _db.collection('users').doc(currentUser!.uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        final role = userDoc.data()!['role'];
        debugPrint('✅ User role from users collection: $role');
        return role; // Return the actual role (staff, admin, or preacher)
      }

      // Fallback: Check registrations collection
      final preacherQuery = await _db
          .collection('registrations')
          .where('authUid', isEqualTo: currentUser!.uid)
          .limit(1)
          .get();
      
      if (preacherQuery.docs.isNotEmpty) {
        debugPrint('✅ User is PREACHER (from registrations)');
        return 'preacher';
      }

      debugPrint('❌ User role not found');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user role: $e');
      return null;
    }
  }

  // 🔹 GET USER DETAILS - PROPERLY FIXED
  static Future<Map<String, dynamic>?> getUserDetails() async {
    if (currentUser == null) return null;

    try {
      // First check users collection
      final userDoc = await _db.collection('users').doc(currentUser!.uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        final role = data['role'];
        
        // If it's a preacher in users collection, also get registration details
        if (role == 'preacher') {
          final regQuery = await _db
              .collection('registrations')
              .where('authUid', isEqualTo: currentUser!.uid)
              .limit(1)
              .get();
          
          if (regQuery.docs.isNotEmpty) {
            // Merge both data sources
            return {
              ...data,
              ...regQuery.docs.first.data(),
            };
          }
        }
        
        return data;
      }

      // Fallback: Check registrations only
      final preacherQuery = await _db
          .collection('registrations')
          .where('authUid', isEqualTo: currentUser!.uid)
          .limit(1)
          .get();
      
      if (preacherQuery.docs.isNotEmpty) {
        return preacherQuery.docs.first.data();
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

  // 🔹 READ ACTIVITIES BY PREACHER (real-time stream) - FIXED
  static Stream<QuerySnapshot<Map<String, dynamic>>> getActivitiesByPreacher(
    String authUid,  // This is the Firebase Auth UID
  ) async* {
    // First, find the preacher's registration document ID
    final preacherQuery = await _db
        .collection('registrations')
        .where('authUid', isEqualTo: authUid)
        .limit(1)
        .get();
    
    if (preacherQuery.docs.isEmpty) {
      debugPrint('❌ No preacher found with authUid: $authUid');
      // Return empty stream if preacher not found
      yield* Stream.value(
        await _db.collection(_collection).where('assignedPreacherId', isEqualTo: 'no-match').get()
      ).asBroadcastStream();
      return;
    }
    
    final preacherId = preacherQuery.docs.first.id;
    debugPrint('✅ Found preacher ID: $preacherId for authUid: $authUid');
    
    // Now query activities with the correct preacher ID
    yield* _db
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

  // 🔹 GET ALL PREACHERS
  static Future<List<Map<String, String>>> getAllPreachers() async {
    try {
      final snapshot = await _db.collection('registrations').get();
      
      debugPrint('📊 Total preachers found: ${snapshot.docs.length}');
      
      final List<Map<String, String>> preachers = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        preachers.add({
          'id': doc.id,
          'name': data['preacherName']?.toString() ?? 'Unknown',
        });
      }
      
      debugPrint('✅ Preachers loaded: ${preachers.length}');
      return preachers;
    } catch (e) {
      debugPrint('❌ Error getting preachers: $e');
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