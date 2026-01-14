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
    final userDoc =
        await _db.collection('users').doc(currentUser!.uid).get();

    if (!userDoc.exists) return null;

    return userDoc.data()?['role'];
  } catch (e) {
    debugPrint('Error getting user role: $e');
    return null;
  }
}

  // 🔹 GET USER DETAILS - PROPERLY FIXED
  static Future<Map<String, dynamic>?> getUserDetails() async {
  if (currentUser == null) return null;

  try {
    final role = await getUserRole();

    if (role == 'staff' || role == 'admin') {
      final doc =
          await _db.collection('users').doc(currentUser!.uid).get();
      return doc.data();
    }

    if (role == 'preacher') {
      final snapshot = await _db
          .collection('registrations')
          .where('userId', isEqualTo: currentUser!.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
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

  static Future<List<Map<String, String>>> getAllPreachers() async {
  try {
    final snapshot = await _db
        .collection('registrations')
        .get();  // ✅ Remove the role filter since registrations don't have 'role'

    final List<Map<String, String>> preachers = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // ✅ Changed 'userId' to 'authUid'
      if (data['authUid'] != null && data['preacherName'] != null) {
        preachers.add({
          'id': data['authUid'],  // ✅ Use authUid instead of userId
          'name': data['preacherName'],
        });
      }
    }

    debugPrint('Loaded preachers: $preachers');
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