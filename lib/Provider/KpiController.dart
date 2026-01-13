// lib/Provider/KpiController.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Kpi.dart';

class KpiController {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('kpis');

  /// Get all KPIs
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
      print('❌ GetAllKpi error: $e');
      return [];
    }
  }

  /// Get single KPI by ID
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
      print('❌ GetKpiDetails error: $e');
      return null;
    }
  }

  /// Create KPI
  Future<bool> createKpi(Map<String, dynamic> kpiData) async {
    if (!_isKpiDataValid(kpiData)) return false;

    try {
      kpiData['kpiCreatedDate'] = FieldValue.serverTimestamp();
      await _db.add(kpiData);
      return true;
    } catch (e) {
      print('❌ CreateKpi error: $e');
      return false;
    }
  }

  /// Update KPI
  Future<bool> updateKpi(String kpiID, Map<String, dynamic> updatedData) async {
    if (!_isKpiDataValid(updatedData)) return false;

    try {
      await _db.doc(kpiID).update(updatedData);
      return true;
    } catch (e) {
      print('❌ UpdateKpi error: $e');
      return false;
    }
  }

  /// Delete KPI
  Future<bool> deleteKpi(String kpiID) async {
    try {
      await _db.doc(kpiID).delete();
      return true;
    } catch (e) {
      print('❌ DeleteKpi error: $e');
      return false;
    }
  }

  /// ✅ SAFE validation for Firestore data
  bool _isKpiDataValid(Map<String, dynamic> data) {
    final mandatoryFields = [
      'kpiTitle',
      'kpiCategory',
      'kpiYear',
      'kpiTarget',
      'kpiUnitOfMeasure',
      'kpiIndicator',
      'staffID',
    ];

    for (var field in mandatoryFields) {
      if (!data.containsKey(field) || data[field] == null) {
        print('❌ VALIDATION FAILED: "$field" is missing or null');
        return false;
      }

      // Only trim if it's a String
      if (data[field] is String && data[field].trim().isEmpty) {
        print('❌ VALIDATION FAILED: "$field" is empty');
        return false;
      }
    }
    return true;
  }
}
