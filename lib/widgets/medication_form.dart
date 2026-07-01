import 'package:flutter/material.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/models/medication/medication_models.dart';

class MedicationForm extends StatefulWidget {
  final MedicationCatalog catalog;
  final bool showOralSection;
  final bool showDeviceId;
  final TextEditingController? deviceIdController;
  final List<Map<String, dynamic>>? initialMedications;

  const MedicationForm({
    super.key,
    required this.catalog,
    this.showOralSection = true,
    this.showDeviceId = true,
    this.deviceIdController,
    this.initialMedications,
  });

  @override
  MedicationFormState createState() => MedicationFormState();
}

class _InhalerDraft {
  String? catalogId;
  String? strength;
  int? puffsPerDose;
  int? dosesPerDay;
  final TextEditingController customStrengthController =
      TextEditingController();
}

class _OralDraft {
  String? catalogId;
  String? strength;
  double? doseMg;
  String frequency;
  final TextEditingController doseMgController = TextEditingController();
  final TextEditingController customStrengthController =
      TextEditingController();

  _OralDraft({this.frequency = 'once_daily'});
}

class MedicationFormState extends State<MedicationForm> {
  final _preventer = _InhalerDraft();
  final _reliever = _InhalerDraft();
  final List<_OralDraft> _oralMeds = [];

  static const _puffOptions = [1, 2, 3, 4, 5, 6, 8, 10];
  static const _dosesPerDayOptions = [1, 2];

  static const _labelStyle = TextStyle(color: WebColors.primaryBlue, fontSize: 14);
  static const _sectionStyle = TextStyle(
    color: WebColors.primaryBlueText,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    _preventer.catalogId = _defaultCatalogId('preventer_inhaler');
    _reliever.catalogId = _defaultCatalogId('reliever_inhaler');
    _preventer.puffsPerDose = 2;
    _reliever.puffsPerDose = 2;
    _preventer.dosesPerDay = 2;
    _syncStrengthDefaults(_preventer, 'preventer_inhaler');
    _syncStrengthDefaults(_reliever, 'reliever_inhaler');
    if (widget.initialMedications != null) {
      _applyMedications(widget.initialMedications!);
    }
  }

  @override
  void dispose() {
    _preventer.customStrengthController.dispose();
    _reliever.customStrengthController.dispose();
    for (final oral in _oralMeds) {
      oral.doseMgController.dispose();
      oral.customStrengthController.dispose();
    }
    super.dispose();
  }

  String? _defaultCatalogId(String category) {
    final items = widget.catalog.itemsForCategory(category);
    if (items.isEmpty) return null;
    if (category == 'reliever_inhaler') {
      return items.any((i) => i.id == 'salbutamol')
          ? 'salbutamol'
          : items.first.id;
    }
    return items.first.id;
  }

  MedicationCatalogItem? _item(String category, String? catalogId) {
    if (catalogId == null) return null;
    for (final item in widget.catalog.itemsForCategory(category)) {
      if (item.id == catalogId) return item;
    }
    return null;
  }

  void _syncStrengthDefaults(_InhalerDraft draft, String category) {
    final item = _item(category, draft.catalogId);
    if (item == null) return;
    if (item.strengths.isNotEmpty) {
      draft.strength = item.strengths.first;
    } else {
      draft.strength = '';
    }
  }

  void _applyInhalerDraft(
    _InhalerDraft draft,
    UserMedication med,
    String category,
  ) {
    if (med.catalogId.isNotEmpty) {
      draft.catalogId = med.catalogId;
    }
    draft.puffsPerDose = med.puffsPerDose ?? draft.puffsPerDose;
    if (category == 'preventer_inhaler') {
      draft.dosesPerDay = med.dosesPerDay ?? draft.dosesPerDay;
    }
    final item = _item(category, draft.catalogId);
    if (med.strength.isNotEmpty) {
      if (item != null && item.strengths.contains(med.strength)) {
        draft.strength = med.strength;
      } else {
        draft.customStrengthController.text = med.strength;
      }
    } else {
      _syncStrengthDefaults(draft, category);
    }
  }

  void _applyMedications(List<Map<String, dynamic>> raw) {
    final meds = raw
        .map((e) => UserMedication.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.category.isNotEmpty)
        .toList();

    _oralMeds.clear();
    for (final med in meds) {
      switch (med.category) {
        case 'preventer_inhaler':
          _applyInhalerDraft(_preventer, med, 'preventer_inhaler');
        case 'reliever_inhaler':
          _applyInhalerDraft(_reliever, med, 'reliever_inhaler');
        case 'oral':
          final draft = _OralDraft(
            frequency:
                med.frequency.isNotEmpty ? med.frequency : 'once_daily',
          );
          draft.catalogId = med.catalogId.isNotEmpty
              ? med.catalogId
              : (widget.catalog.oralMedications.isNotEmpty
                  ? widget.catalog.oralMedications.first.id
                  : null);
          final item = _item('oral', draft.catalogId);
          if (med.doseMg != null) {
            draft.doseMg = med.doseMg;
            draft.doseMgController.text = med.doseMg.toString();
          }
          if (med.strength.isNotEmpty) {
            if (item != null && item.strengths.contains(med.strength)) {
              draft.strength = med.strength;
            } else {
              draft.customStrengthController.text = med.strength;
            }
          }
          _oralMeds.add(draft);
      }
    }
  }

  String? validate() {
    if (_preventer.catalogId == null || _preventer.puffsPerDose == null) {
      return 'Please complete preventer inhaler details';
    }
    if (_reliever.catalogId == null || _reliever.puffsPerDose == null) {
      return 'Please complete reliever inhaler details';
    }
    final preventerItem = _item('preventer_inhaler', _preventer.catalogId)!;
    final relieverItem = _item('reliever_inhaler', _reliever.catalogId)!;
    if (preventerItem.allowCustomStrength &&
        _preventer.customStrengthController.text.trim().isEmpty &&
        preventerItem.strengths.isEmpty) {
      return 'Enter preventer strength';
    }
    if (relieverItem.allowCustomStrength &&
        _reliever.customStrengthController.text.trim().isEmpty &&
        relieverItem.strengths.isEmpty) {
      return 'Enter reliever strength';
    }
    return null;
  }

  List<Map<String, dynamic>> buildPayload() {
    final meds = <Map<String, dynamic>>[
      _inhalerPayload(_preventer, 'preventer_inhaler'),
      _inhalerPayload(_reliever, 'reliever_inhaler'),
    ];
    for (final oral in _oralMeds) {
      final item = _item('oral', oral.catalogId);
      if (item == null) continue;
      final payload = UserMedication(
        category: 'oral',
        catalogId: item.id,
        name: item.name,
        strength: item.variableDose
            ? ''
            : (oral.strength ?? oral.customStrengthController.text.trim()),
        doseMg: item.variableDose
            ? double.tryParse(oral.doseMgController.text.trim())
            : null,
        frequency: oral.frequency,
      );
      meds.add(payload.toJson());
    }
    return meds;
  }

  Map<String, dynamic> _inhalerPayload(_InhalerDraft draft, String category) {
    final item = _item(category, draft.catalogId)!;
    final strength = item.strengths.isNotEmpty
        ? (draft.strength ?? item.strengths.first)
        : draft.customStrengthController.text.trim();
    return UserMedication(
      category: category,
      catalogId: item.id,
      name: item.name,
      strength: strength,
      puffsPerDose: draft.puffsPerDose,
      dosesPerDay: category == 'preventer_inhaler' ? draft.dosesPerDay : null,
    ).toJson();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Preventer inhaler (daily)'),
        _inhalerSection(
          category: 'preventer_inhaler',
          draft: _preventer,
          showDosesPerDay: true,
        ),
        const SizedBox(height: 20),
        _sectionTitle('Reliever inhaler (as needed)'),
        _inhalerSection(
          category: 'reliever_inhaler',
          draft: _reliever,
          showDosesPerDay: false,
        ),
        if (widget.showOralSection) ...[
          const SizedBox(height: 20),
          _sectionTitle('Other tablets (optional)'),
          ..._oralMeds.asMap().entries.map(
                (entry) => _oralSection(entry.value, entry.key),
              ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  final draft = _OralDraft();
                  draft.catalogId = widget.catalog.oralMedications.isNotEmpty
                      ? widget.catalog.oralMedications.first.id
                      : null;
                  _oralMeds.add(draft);
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add tablet'),
            ),
          ),
        ],
        if (widget.showDeviceId && widget.deviceIdController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.deviceIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'QIoT Device ID (optional)',
              labelStyle: _labelStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: _sectionStyle),
    );
  }

  Widget _inhalerSection({
    required String category,
    required _InhalerDraft draft,
    required bool showDosesPerDay,
  }) {
    final items = widget.catalog.itemsForCategory(category);
    final selected = _item(category, draft.catalogId);
    final strengths = selected?.strengths ?? [];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: draft.catalogId,
          decoration: InputDecoration(
            labelText: 'Medicine',
            labelStyle: _labelStyle,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items
              .map((i) => DropdownMenuItem(value: i.id, child: Text(i.name)))
              .toList(),
          onChanged: (value) {
            setState(() {
              draft.catalogId = value;
              _syncStrengthDefaults(draft, category);
            });
          },
        ),
        const SizedBox(height: 12),
        if (strengths.isNotEmpty)
          DropdownButtonFormField<String>(
            value: draft.strength,
            decoration: InputDecoration(
              labelText: 'Strength',
              labelStyle: _labelStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: strengths
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) => setState(() => draft.strength = value),
          )
        else if (selected?.allowCustomStrength == true)
          TextFormField(
            controller: draft.customStrengthController,
            decoration: InputDecoration(
              labelText: 'Strength',
              labelStyle: _labelStyle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: draft.puffsPerDose,
                decoration: InputDecoration(
                  labelText: 'Puffs per dose',
                  labelStyle: _labelStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _puffOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text('$p')))
                    .toList(),
                onChanged: (value) =>
                    setState(() => draft.puffsPerDose = value),
              ),
            ),
            if (showDosesPerDay) ...[
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: draft.dosesPerDay,
                  decoration: InputDecoration(
                    labelText: 'Times per day',
                    labelStyle: _labelStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _dosesPerDayOptions
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => draft.dosesPerDay = value),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _oralSection(_OralDraft draft, int index) {
    final items = widget.catalog.oralMedications;
    final selected = _item('oral', draft.catalogId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: draft.catalogId,
                    decoration: InputDecoration(
                      labelText: 'Tablet',
                      labelStyle: _labelStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: items
                        .map((i) => DropdownMenuItem(
                              value: i.id,
                              child: Text(i.name),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => draft.catalogId = value),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _oralMeds.removeAt(index)),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (selected?.variableDose == true) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: draft.doseMgController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Dose (mg)',
                  labelStyle: _labelStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ] else if ((selected?.strengths ?? []).isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: draft.strength,
                decoration: InputDecoration(
                  labelText: 'Strength',
                  labelStyle: _labelStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: selected!.strengths
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => draft.strength = value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
