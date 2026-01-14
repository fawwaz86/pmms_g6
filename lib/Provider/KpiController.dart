import 'package:cloud_firestore/cloud_firestore.dart';
import '../Domain/Kpi.dart';

class KpiController {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('kpis');

  /// Get all KPIs
  /// - Admin / Staff → getAllKpi()
  /// - Preacher → getAllKpi(preacherID: X)
  Future<List<Kpi>> getAllKpi({int? preacherID}) async {
    try {
      Query query = _db;

      // 🔐 Filter by preacherID if provided
      if (preacherID != null) {
        query = query.where('preacherID', isEqualTo: preacherID);
      }

      final snapshot = await query.get();

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

  /// Validation
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

      if (data[field] is String && data[field].trim().isEmpty) {
        print('❌ VALIDATION FAILED: "$field" is empty');
        return false;
      }
    }
    return true;
  }
}
