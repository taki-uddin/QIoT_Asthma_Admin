class MedicationCatalogItem {
  final String id;
  final String name;
  final List<String> strengths;
  final bool allowCustomStrength;
  final bool variableDose;

  const MedicationCatalogItem({
    required this.id,
    required this.name,
    this.strengths = const [],
    this.allowCustomStrength = false,
    this.variableDose = false,
  });

  factory MedicationCatalogItem.fromJson(Map<String, dynamic> json) {
    return MedicationCatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      strengths: (json['strengths'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      allowCustomStrength: json['allowCustomStrength'] == true,
      variableDose: json['variableDose'] == true,
    );
  }
}

class MedicationCatalog {
  final String version;
  final List<MedicationCatalogItem> preventerInhalers;
  final List<MedicationCatalogItem> relieverInhalers;
  final List<MedicationCatalogItem> oralMedications;

  const MedicationCatalog({
    required this.version,
    required this.preventerInhalers,
    required this.relieverInhalers,
    required this.oralMedications,
  });

  factory MedicationCatalog.fromJson(Map<String, dynamic> json) {
    List<MedicationCatalogItem> parseList(String key) {
      return (json[key] as List<dynamic>? ?? [])
          .map((e) => MedicationCatalogItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return MedicationCatalog(
      version: json['version']?.toString() ?? '1.0.0',
      preventerInhalers: parseList('preventerInhalers'),
      relieverInhalers: parseList('relieverInhalers'),
      oralMedications: parseList('oralMedications'),
    );
  }

  List<MedicationCatalogItem> itemsForCategory(String category) {
    switch (category) {
      case 'preventer_inhaler':
        return preventerInhalers;
      case 'reliever_inhaler':
        return relieverInhalers;
      case 'oral':
        return oralMedications;
      default:
        return const [];
    }
  }
}

class UserMedication {
  final String category;
  final String catalogId;
  final String name;
  final String strength;
  final int? puffsPerDose;
  final int? dosesPerDay;
  final double? doseMg;
  final String frequency;

  const UserMedication({
    required this.category,
    required this.catalogId,
    required this.name,
    this.strength = '',
    this.puffsPerDose,
    this.dosesPerDay,
    this.doseMg,
    this.frequency = '',
  });

  factory UserMedication.fromJson(Map<String, dynamic> json) {
    return UserMedication(
      category: json['category']?.toString() ?? '',
      catalogId: json['catalogId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      strength: json['strength']?.toString() ?? '',
      puffsPerDose: _parseInt(json['puffsPerDose']),
      dosesPerDay: _parseInt(json['dosesPerDay']),
      doseMg: _parseDouble(json['doseMg']),
      frequency: json['frequency']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'category': category,
      'catalogId': catalogId,
      'name': name,
      'strength': strength,
      'frequency': frequency,
    };
    if (puffsPerDose != null) map['puffsPerDose'] = puffsPerDose;
    if (dosesPerDay != null) map['dosesPerDay'] = dosesPerDay;
    if (doseMg != null) map['doseMg'] = doseMg;
    return map;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
