import 'package:qiot_admin/models/medication/medication_models.dart';

class MedicationDisplayUtils {
  MedicationDisplayUtils._();

  static List<UserMedication> parseMedications(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => UserMedication.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.category.isNotEmpty)
        .toList();
  }

  static List<Map<String, dynamic>> parseMedicationMaps(dynamic raw) {
    return parseMedications(raw).map((m) => m.toJson()).toList();
  }
}
