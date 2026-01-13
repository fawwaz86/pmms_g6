import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/activity.dart';


class ActivityController {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'activities';

  // 🔹 GET CURRENT USER
  static User? get currentUser => _auth.currentUser;

  // 🔹 GET USER ROLE - UPDATED TO READ ROLE FIELD
  static Future<String?> getUserRole() async {
    if (currentUser == null) {
      debugPrint('❌ No current user');
      return null;
    }

    try {
      final uid = currentUser!.uid;
      debugPrint('🔍 Checking role for user: $uid');
      
      // Check users collection first (contains both staff and preachers)
      final userDoc = await _db.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        final data = userDoc.data();
        debugPrint('📋 Found in users collection');
        
        // ✅ Read the role field from the document
        if (data != null && data.containsKey('role')) {
          final role = data['role'] as String;
          debugPrint('✅ User role from users collection: $role');
          return role; // Returns 'staff' or 'preacher' based on the field
        }
        
        // Fallback: if no role field, assume staff
        debugPrint('⚠️ No role field found in users collection, defaulting to staff');
        return 'staff';
      }

      // If not in users collection, check registrations (legacy preacher data)
      final preacherDoc = await _db.collection('registrations').doc(uid).get();
      debugPrint('📋 Registrations collection check: exists=${preacherDoc.exists}');
      
      if (preacherDoc.exists) {
        debugPrint('✅ User found in registrations collection (legacy preacher)');
        return 'preacher';
      }

      debugPrint('❌ User not found in any collection');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user role: $e');
      return null;
    }
  }

  // 🔹 GET USER DETAILS - UPDATED
  static Future<Map<String, dynamic>?> getUserDetails() async {
    if (currentUser == null) return null;

    try {
      final uid = currentUser!.uid;
      final role = await getUserRole();
      
      debugPrint('🔍 Getting user details for: $uid (role: $role)');
      
      // Get from users collection (for both staff and preachers with role field)
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        debugPrint('✅ User details found in users collection');
        return userDoc.data();
      }
      
      // Fallback: check registrations for legacy preacher data
      if (role == 'preacher') {
        final preacherDoc = await _db.collection('registrations').doc(uid).get();
        if (preacherDoc.exists) {
          debugPrint('✅ User details found in registrations collection');
          return preacherDoc.data();
        }
      }

      debugPrint('❌ No user details found');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user details: $e');
      return null;
    }
  }

  // 🔹 MIGRATE ACTIVITY PREACHER IDS (One-time migration)
  static Future<Map<String, dynamic>> migrateActivityPreacherIds() async {
    int totalActivities = 0;
    int migratedActivities = 0;
    int skippedActivities = 0;
    int failedActivities = 0;
    List<String> errors = [];

    try {
      debugPrint('🔄 Starting migration of activity preacher IDs...');
      
      // Step 1: Get all activities
      final activitiesSnapshot = await _db.collection('activities').get();
      totalActivities = activitiesSnapshot.docs.length;
      debugPrint('📊 Found $totalActivities total activities');

      // Step 2: Build a mapping of registration doc IDs to Auth UIDs
      Map<String, String> registrationIdToAuthUid = {};
      
      final registrationsSnapshot = await _db.collection('registrations').get();
      for (var regDoc in registrationsSnapshot.docs) {
        final regData = regDoc.data();
        
        // Try to find the Auth UID in the registration document
        String? authUid;
        
        // Check common field names for Auth UID
        if (regData.containsKey('uid')) {
          authUid = regData['uid'];
        } else if (regData.containsKey('userId')) {
          authUid = regData['userId'];
        } else if (regData.containsKey('authId')) {
          authUid = regData['authId'];
        }
        
        if (authUid != null) {
          registrationIdToAuthUid[regDoc.id] = authUid;
          debugPrint('   📝 Mapped registration ${regDoc.id} → Auth UID: $authUid');
        } else {
          debugPrint('   ⚠️ No Auth UID found for registration ${regDoc.id}');
        }
      }

      // Step 3: Process each activity
      for (var activityDoc in activitiesSnapshot.docs) {
        try {
          final data = activityDoc.data();
          final oldPreacherId = data['assignedPreacherId'];
          
          if (oldPreacherId == null || oldPreacherId.isEmpty) {
            debugPrint('⏭️ Activity ${activityDoc.id}: No preacher assigned, skipping');
            skippedActivities++;
            continue;
          }

          // Check if this ID exists in users collection (already correct)
          final userDoc = await _db.collection('users').doc(oldPreacherId).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            if (userData != null && userData['role'] == 'preacher') {
              debugPrint('✅ Activity ${activityDoc.id}: Already using correct Auth UID');
              skippedActivities++;
              continue;
            }
          }

          // Check if this is a registration document ID that needs migration
          if (registrationIdToAuthUid.containsKey(oldPreacherId)) {
            final newAuthUid = registrationIdToAuthUid[oldPreacherId]!;
            
            await activityDoc.reference.update({
              'assignedPreacherId': newAuthUid,
            });
            
            debugPrint('✅ Migrated activity ${activityDoc.id}:');
            debugPrint('   Old: $oldPreacherId → New: $newAuthUid');
            debugPrint('   Activity: ${data['title']}');
            migratedActivities++;
          } else {
            // Check if the old ID exists in registrations but has no mapping
            final regDoc = await _db.collection('registrations').doc(oldPreacherId).get();
            if (regDoc.exists) {
              debugPrint('⚠️ Activity ${activityDoc.id}: Registration doc exists but no Auth UID mapping');
              errors.add('Activity "${data['title']}" (${activityDoc.id}): Registration $oldPreacherId has no Auth UID');
              failedActivities++;
            } else {
              debugPrint('⚠️ Activity ${activityDoc.id}: Unknown preacher ID format: $oldPreacherId');
              skippedActivities++;
            }
          }
        } catch (e) {
          debugPrint('❌ Error processing activity ${activityDoc.id}: $e');
          errors.add('Activity ${activityDoc.id}: $e');
          failedActivities++;
        }
      }

      debugPrint('');
      debugPrint('📊 MIGRATION SUMMARY:');
      debugPrint('   Total Activities: $totalActivities');
      debugPrint('   ✅ Migrated: $migratedActivities');
      debugPrint('   ⏭️ Skipped (already correct): $skippedActivities');
      debugPrint('   ❌ Failed: $failedActivities');
      
      if (errors.isNotEmpty) {
        debugPrint('');
        debugPrint('⚠️ ERRORS:');
        for (var error in errors) {
          debugPrint('   - $error');
        }
      }

      return {
        'success': true,
        'totalActivities': totalActivities,
        'migrated': migratedActivities,
        'skipped': skippedActivities,
        'failed': failedActivities,
        'errors': errors,
      };
    } catch (e) {
      debugPrint('❌ Migration failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // 🔹 CREATE ACTIVITY
  static Future<String?> addActivity(Activity activity) async {
    try {
      final docRef = await _db.collection(_collection).add({
        ...activity.toMap(),
        'createdAt': Timestamp.now(),
      });
      debugPrint('✅ Activity created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error adding activity: $e');
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
    debugPrint('🔍 Fetching activities for preacher: $preacherId');
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
      debugPrint('✅ Activity updated: $docId');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating activity: $e');
      return false;
    }
  }

  // 🔹 DELETE ACTIVITY
  static Future<bool> deleteActivity(String docId) async {
    try {
      await _db.collection(_collection).doc(docId).delete();
      debugPrint('✅ Activity deleted: $docId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting activity: $e');
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
      debugPrint('✅ Activity marked as completed: $docId');
      return true;
    } catch (e) {
      debugPrint('❌ Error marking activity as completed: $e');
      return false;
    }
  }

  // 🔹 GET ALL PREACHERS - FROM BOTH USERS AND REGISTRATIONS
  static Future<List<Map<String, String>>> getAllPreachers() async {
    try {
      final List<Map<String, String>> preachers = [];
      
      // 1️⃣ Get preachers from USERS collection (where role = 'preacher')
      final usersSnapshot = await _db.collection('users').get();
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        // Only add if role is 'preacher'
        if (data['role'] == 'preacher') {
          preachers.add({
            'id': doc.id, // ✅ This is the Auth UID
            'name': data['name']?.toString() ?? 
                    data['email']?.toString() ?? 
                    'Unknown',
          });
          debugPrint('   ✅ Found preacher in users: ${doc.id} - ${data['name']}');
        }
      }
      
      // 2️⃣ Also get from registrations collection (legacy preachers)
      final registrationsSnapshot = await _db.collection('registrations').get();
      
      for (var doc in registrationsSnapshot.docs) {
        final data = doc.data();
        
        // Try to get the Auth UID from the registration document
        String authUid = doc.id; // Default to document ID
        
        if (data.containsKey('uid') && data['uid'] != null) {
          authUid = data['uid'].toString();
        } else if (data.containsKey('userId') && data['userId'] != null) {
          authUid = data['userId'].toString();
        } else if (data.containsKey('authId') && data['authId'] != null) {
          authUid = data['authId'].toString();
        } else {
          debugPrint('   ⚠️ No Auth UID field in registration ${doc.id}, using doc ID');
        }
        
        // Check if this preacher is not already in the list
        if (!preachers.any((p) => p['id'] == authUid)) {
          preachers.add({
            'id': authUid,
            'name': data['preacherName']?.toString() ?? 
                    data['name']?.toString() ?? 
                    'Unknown',
          });
          debugPrint('   ✅ Found preacher in registrations: $authUid - ${data['preacherName']}');
        }
      }
      
      debugPrint('✅ Total preachers found: ${preachers.length}');
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
        debugPrint('❌ Error converting document ${doc.id} to Activity: $e');
        // Skip this document and continue with others
      }
    }
    
    return activities;
  }
}

// Helper to use debugPrint
void debugPrint(String message) {
  assert(() {
    print(message);
    return true;
  }());
}