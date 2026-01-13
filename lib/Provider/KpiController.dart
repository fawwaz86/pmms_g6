// lib/Provider/KpiController.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Kpi.dart';

class KpiController {
  // Middleware: communication with Firebase database collection 'kpis'
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('kpis');

  /// Algorithm: getAllKpi()
  /// Return all KPI records from the database to populate the listKpiPage.
  Future<List<Kpi>> getAllKpi() async {
    try {
      final snapshot = await _db.get();
      return snapshot.docs.map((doc) {
        return Kpi.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('GetAllKpi error: $e');
      return [];
    }
  }

  /// Algorithm: getKpiDetails(kpiID)
  /// Retrieve full details of the selected KPI item based on the Firestore docId.
  Future<Kpi?> getKpiDetails(String kpiID) async {
    try {
      final doc = await _db.doc(kpiID).get();
      if (doc.exists) {
        return Kpi.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print('GetKpiDetails error: $e');
      return null;
    }
  }

  /// Algorithm: createKpi(kpiData)
  /// If kpiData is valid Then insert new KPI record into database.
  Future<bool> createKpi(Map<String, dynamic> kpiData) async {
    if (_isKpiDataValid(kpiData)) {
      try {
        // Automatically append creation date per Data Dictionary requirements
        kpiData['kpiCreatedDate'] = DateTime.now().toIso8601String();
        
        await _db.add(kpiData);
        return true;
      } catch (e) {
        print('CreateKpi error: $e');
        return false;
      }
    }
    return false; // Returns false if validation fails
  }

  /// Algorithm: updateKpi(kpiID, updatedData)
  /// If updatedData is valid Then update existing KPI record in database.
  Future<bool> updateKpi(String kpiID, Map<String, dynamic> updatedData) async {
    if (_isKpiDataValid(updatedData)) {
      try {
        await _db.doc(kpiID).update(updatedData);
        return true;
      } catch (e) {
        print('UpdateKpi error: $e');
        return false;
      }
    }
    return false;
  }

  /// Algorithm: deleteKpi(kpiID)
  /// Remove selected KPI from database and return success status.
  Future<bool> deleteKpi(String kpiID) async {
    try {
      await _db.doc(kpiID).delete();
      return true; // deleteStatus = true
    } catch (e) {
      print('DeleteKpi error: $e');
      return false; // deleteStatus = false
    }
  }

  /// Internal Validation logic based on SDD Section 2.2.5
  /// Checks mandatory fields (NOT NULL) before processing database actions.
  bool _isKpiDataValid(Map<String, dynamic> data) {
  final mandatoryFields = [
    'kpiTitle', 'kpiCategory', 'kpiYear', 
    'kpiTarget', 'kpiUnitOfMeasure', 'kpiIndicator', 'staffID'
  ];

  for (var field in mandatoryFields) {
    if (data[field] == null || data[field].toString().trim().isEmpty) {
      // THIS WILL SHOW IN YOUR CONSOLE
      print('❌ VALIDATION FAILED: The field "$field" is null or empty!');
      return false;
    }
  }
  return true;
}
}