import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/utils/id_generator.dart';
import 'case_record_models.dart';

/// Supported dental notation numbering systems.
enum DentalNotation {
  /// FDI World Dental Federation two-digit notation (ISO 3950).
  /// Standard in India (Dental Council of India), UK, Canada, and Europe.
  /// Quadrants 1-4, teeth 1-8 (e.g., 11 to 48).
  fdi,

  /// Universal Numbering System (American Dental Association).
  /// Standard in the United States.
  /// Teeth 1 to 32 starting Upper Right Third Molar to Lower Right Third Molar.
  universal,
}

/// The 5 anatomical surfaces of a tooth.
enum ToothSurface {
  /// Occlusal (O) - Biting/chewing surface of premolars/molars (Incisal for anteriors).
  occlusal,

  /// Mesial (M) - Surface facing towards the dental midline.
  mesial,

  /// Distal (D) - Surface facing away from the dental midline.
  distal,

  /// Buccal / Facial (B) - Surface facing towards the cheeks/lips.
  buccal,

  /// Lingual / Palatal (L) - Surface facing towards the tongue/palate.
  lingual,
}

extension ToothSurfaceExtension on ToothSurface {
  String get code {
    switch (this) {
      case ToothSurface.occlusal:
        return 'O';
      case ToothSurface.mesial:
        return 'M';
      case ToothSurface.distal:
        return 'D';
      case ToothSurface.buccal:
        return 'B';
      case ToothSurface.lingual:
        return 'L';
    }
  }

  String get displayName {
    switch (this) {
      case ToothSurface.occlusal:
        return 'Occlusal / Incisal';
      case ToothSurface.mesial:
        return 'Mesial';
      case ToothSurface.distal:
        return 'Distal';
      case ToothSurface.buccal:
        return 'Buccal / Facial';
      case ToothSurface.lingual:
        return 'Lingual / Palatal';
    }
  }
}

/// Clinical condition / diagnosis of an individual tooth.
enum ToothCondition {
  /// Normal, healthy tooth with no apparent pathology.
  healthy,

  /// Dental caries / cavity on one or more surfaces.
  caries,

  /// Previously restored with filling (Composite, Amalgam, GIC).
  filled,

  /// Endodontically treated (Root Canal Treatment).
  rootCanal,

  /// Prosthetic full-coverage crown or bridge abutment.
  crown,

  /// Missing tooth (extracted, congenitally absent, or avulsed).
  missing,

  /// Dental implant fixture with or without crown.
  implant,

  /// Impacted or partially erupted tooth (common in 3rd molars).
  impacted,
}

extension ToothConditionExtension on ToothCondition {
  String get label {
    switch (this) {
      case ToothCondition.healthy:
        return 'Healthy / Intact';
      case ToothCondition.caries:
        return 'Caries / Cavity';
      case ToothCondition.filled:
        return 'Filled / Restored';
      case ToothCondition.rootCanal:
        return 'Root Canal (RCT)';
      case ToothCondition.crown:
        return 'Crown / Cap';
      case ToothCondition.missing:
        return 'Missing / Extracted';
      case ToothCondition.implant:
        return 'Dental Implant';
      case ToothCondition.impacted:
        return 'Impacted';
    }
  }

  String get shortCode {
    switch (this) {
      case ToothCondition.healthy:
        return 'H';
      case ToothCondition.caries:
        return 'CAR';
      case ToothCondition.filled:
        return 'FIL';
      case ToothCondition.rootCanal:
        return 'RCT';
      case ToothCondition.crown:
        return 'CRN';
      case ToothCondition.missing:
        return 'MIS';
      case ToothCondition.implant:
        return 'IMP';
      case ToothCondition.impacted:
        return 'PCT';
    }
  }

  IconData get icon {
    switch (this) {
      case ToothCondition.healthy:
        return Icons.check_circle_outline;
      case ToothCondition.caries:
        return Icons.warning_amber_rounded;
      case ToothCondition.filled:
        return Icons.brush_outlined;
      case ToothCondition.rootCanal:
        return Icons.flash_on_outlined;
      case ToothCondition.crown:
        return Icons.workspace_premium_outlined;
      case ToothCondition.missing:
        return Icons.close_outlined;
      case ToothCondition.implant:
        return Icons.hardware_outlined;
      case ToothCondition.impacted:
        return Icons.rotate_90_degrees_ccw_outlined;
    }
  }

  Color getBadgeColor(ColorScheme scheme) {
    switch (this) {
      case ToothCondition.healthy:
        return scheme.primary;
      case ToothCondition.caries:
        return scheme.error;
      case ToothCondition.filled:
        return scheme.secondary;
      case ToothCondition.rootCanal:
        return scheme.tertiary;
      case ToothCondition.crown:
        return scheme.primary;
      case ToothCondition.missing:
        return scheme.outline;
      case ToothCondition.implant:
        return scheme.tertiary;
      case ToothCondition.impacted:
        return scheme.error;
    }
  }

  Color getContainerColor(ColorScheme scheme) {
    switch (this) {
      case ToothCondition.healthy:
        return scheme.surfaceContainerHighest;
      case ToothCondition.caries:
        return scheme.errorContainer;
      case ToothCondition.filled:
        return scheme.secondaryContainer;
      case ToothCondition.rootCanal:
        return scheme.tertiaryContainer;
      case ToothCondition.crown:
        return scheme.primaryContainer;
      case ToothCondition.missing:
        return scheme.surfaceContainerHighest.withValues(alpha: 0.4);
      case ToothCondition.implant:
        return scheme.tertiaryContainer;
      case ToothCondition.impacted:
        return scheme.errorContainer.withValues(alpha: 0.5);
    }
  }
}

/// Helpers for tooth numbering, conversion, and anatomical names.
class DentalNotationUtils {
  const DentalNotationUtils._();

  /// FDI (11..48) to Universal Numbering (1..32) mapping table.
  static const Map<int, int> _fdiToUniversal = {
    // Quadrant 1: Maxillary Right (Patient's Right, FDI 18 down to 11)
    18: 1,
    17: 2,
    16: 3,
    15: 4,
    14: 5,
    13: 6,
    12: 7,
    11: 8,
    // Quadrant 2: Maxillary Left (Patient's Left, FDI 21 up to 28)
    21: 9,
    22: 10,
    23: 11,
    24: 12,
    25: 13,
    26: 14,
    27: 15,
    28: 16,
    // Quadrant 3: Mandibular Left (Patient's Left, FDI 31 up to 38)
    31: 24,
    32: 23,
    33: 22,
    34: 21,
    35: 20,
    36: 19,
    37: 18,
    38: 17,
    // Quadrant 4: Mandibular Right (Patient's Right, FDI 48 down to 41)
    41: 25,
    42: 26,
    43: 27,
    44: 28,
    45: 29,
    46: 30,
    47: 31,
    48: 32,
  };

  static final Map<int, int> _universalToFdi = {
    for (final entry in _fdiToUniversal.entries) entry.value: entry.key,
  };

  /// Converts an FDI tooth number (11-48) to Universal number (1-32).
  static int fdiToUniversal(int fdiNumber) {
    return _fdiToUniversal[fdiNumber] ?? fdiNumber;
  }

  /// Converts a Universal tooth number (1-32) to FDI number (11-48).
  static int universalToFdi(int universalNumber) {
    return _universalToFdi[universalNumber] ?? universalNumber;
  }

  /// Formats tooth display string based on active notation.
  static String formatToothNumber(int fdiNumber, DentalNotation notation) {
    if (notation == DentalNotation.universal) {
      return '#${fdiToUniversal(fdiNumber)}';
    }
    return '$fdiNumber';
  }

  /// Returns the anatomical tooth name.
  static String getToothName(int fdiNumber) {
    final toothPos = fdiNumber % 10;
    final quad = fdiNumber ~/ 10;

    String typeName;
    switch (toothPos) {
      case 1:
        typeName = 'Central Incisor';
        break;
      case 2:
        typeName = 'Lateral Incisor';
        break;
      case 3:
        typeName = 'Canine';
        break;
      case 4:
        typeName = 'First Premolar';
        break;
      case 5:
        typeName = 'Second Premolar';
        break;
      case 6:
        typeName = 'First Molar';
        break;
      case 7:
        typeName = 'Second Molar';
        break;
      case 8:
        typeName = 'Third Molar (Wisdom)';
        break;
      default:
        typeName = 'Tooth';
    }

    String quadName;
    switch (quad) {
      case 1:
        quadName = 'Upper Right';
        break;
      case 2:
        quadName = 'Upper Left';
        break;
      case 3:
        quadName = 'Lower Left';
        break;
      case 4:
        quadName = 'Lower Right';
        break;
      default:
        quadName = '';
    }

    return quadName.isNotEmpty ? '$quadName $typeName' : typeName;
  }

  /// Returns quadrant label (e.g., "Upper Right (Maxillary)").
  static String getQuadrantName(int fdiNumber) {
    final quad = fdiNumber ~/ 10;
    switch (quad) {
      case 1:
        return 'Upper Right (Maxillary Q1)';
      case 2:
        return 'Upper Left (Maxillary Q2)';
      case 3:
        return 'Lower Left (Mandibular Q3)';
      case 4:
        return 'Lower Right (Mandibular Q4)';
      default:
        return 'Quadrant $quad';
    }
  }

  /// All 8 teeth of Upper Right Quadrant (FDI 18 to 11, facing center).
  static const List<int> upperRightTeeth = [18, 17, 16, 15, 14, 13, 12, 11];

  /// All 8 teeth of Upper Left Quadrant (FDI 21 to 28, facing away).
  static const List<int> upperLeftTeeth = [21, 22, 23, 24, 25, 26, 27, 28];

  /// All 8 teeth of Lower Left Quadrant (FDI 31 to 38, facing away).
  static const List<int> lowerLeftTeeth = [31, 32, 33, 34, 35, 36, 37, 38];

  /// All 8 teeth of Lower Right Quadrant (FDI 48 to 41, facing center).
  static const List<int> lowerRightTeeth = [48, 47, 46, 45, 44, 43, 42, 41];

  /// Full list of all 32 adult permanent teeth in standard dental sequence.
  static const List<int> all32Teeth = [
    ...upperRightTeeth,
    ...upperLeftTeeth,
    ...lowerLeftTeeth,
    ...lowerRightTeeth,
  ];
}

/// Clinical state of an individual tooth.
class ToothData {
  final int fdiNumber;
  final ToothCondition condition;
  final Set<ToothSurface> affectedSurfaces;
  final String notes;

  const ToothData({
    required this.fdiNumber,
    this.condition = ToothCondition.healthy,
    this.affectedSurfaces = const {},
    this.notes = '',
  });

  int get universalNumber => DentalNotationUtils.fdiToUniversal(fdiNumber);
  String get toothName => DentalNotationUtils.getToothName(fdiNumber);
  String get quadrantName => DentalNotationUtils.getQuadrantName(fdiNumber);

  bool get isHealthy => condition == ToothCondition.healthy;
  bool get hasCaries => condition == ToothCondition.caries;
  bool get isFilled => condition == ToothCondition.filled;
  bool get hasRootCanal => condition == ToothCondition.rootCanal;
  bool get hasCrown => condition == ToothCondition.crown;
  bool get isMissing => condition == ToothCondition.missing;
  bool get isImplant => condition == ToothCondition.implant;
  bool get isImpacted => condition == ToothCondition.impacted;

  /// String formatted affected surfaces (e.g. "MOD" or "O").
  String get surfacesSummary {
    if (affectedSurfaces.isEmpty) return '';
    final order = [
      ToothSurface.mesial,
      ToothSurface.occlusal,
      ToothSurface.distal,
      ToothSurface.buccal,
      ToothSurface.lingual,
    ];
    return order
        .where((s) => affectedSurfaces.contains(s))
        .map((s) => s.code)
        .join();
  }

  ToothData copyWith({
    int? fdiNumber,
    ToothCondition? condition,
    Set<ToothSurface>? affectedSurfaces,
    String? notes,
  }) {
    return ToothData(
      fdiNumber: fdiNumber ?? this.fdiNumber,
      condition: condition ?? this.condition,
      affectedSurfaces: affectedSurfaces ?? this.affectedSurfaces,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'fdi': fdiNumber,
    'condition': condition.name,
    'surfaces': affectedSurfaces.map((s) => s.name).toList(),
    'notes': notes,
  };

  factory ToothData.fromJson(Map<String, dynamic> json) {
    final fdi = json['fdi'] as int? ?? 11;
    final condName = json['condition'] as String? ?? 'healthy';
    final cond = ToothCondition.values.firstWhere(
      (c) => c.name == condName,
      orElse: () => ToothCondition.healthy,
    );
    final rawSurfaces = json['surfaces'] as List<dynamic>? ?? [];
    final surfaces =
        rawSurfaces
            .map(
              (s) => ToothSurface.values.cast<ToothSurface?>().firstWhere(
                (ts) => ts?.name == s,
                orElse: () => null,
              ),
            )
            .whereType<ToothSurface>()
            .toSet();

    return ToothData(
      fdiNumber: fdi,
      condition: cond,
      affectedSurfaces: surfaces,
      notes: json['notes'] as String? ?? '',
    );
  }
}

/// A planned, ongoing, or completed dental procedure.
class DentalProcedure {
  final String id;
  final String title;
  final List<int> toothNumbers; // FDI numbers
  final double estimatedFee;
  final String status; // 'planned', 'in_progress', 'completed'
  final String notes;
  final DateTime? appointmentDate;

  const DentalProcedure({
    required this.id,
    required this.title,
    this.toothNumbers = const [],
    this.estimatedFee = 0.0,
    this.status = 'planned',
    this.notes = '',
    this.appointmentDate,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isPlanned => status.toLowerCase() == 'planned';

  String get toothSummary {
    if (toothNumbers.isEmpty) return 'Full Mouth';
    return toothNumbers.map((n) => '$n').join(', ');
  }

  DentalProcedure copyWith({
    String? id,
    String? title,
    List<int>? toothNumbers,
    double? estimatedFee,
    String? status,
    String? notes,
    DateTime? appointmentDate,
  }) {
    return DentalProcedure(
      id: id ?? this.id,
      title: title ?? this.title,
      toothNumbers: toothNumbers ?? this.toothNumbers,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      appointmentDate: appointmentDate ?? this.appointmentDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'toothNumbers': toothNumbers,
    'estimatedFee': estimatedFee,
    'status': status,
    'notes': notes,
    'appointmentDate': appointmentDate?.toIso8601String(),
  };

  factory DentalProcedure.fromJson(Map<String, dynamic> json) =>
      DentalProcedure(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        toothNumbers:
            (json['toothNumbers'] as List<dynamic>? ?? [])
                .map((e) => e as int)
                .toList(),
        estimatedFee: (json['estimatedFee'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] as String? ?? 'planned',
        notes: json['notes'] as String? ?? '',
        appointmentDate:
            json['appointmentDate'] != null
                ? DateTime.tryParse(json['appointmentDate'] as String)
                : null,
      );
}

/// Comprehensive dental chart record containing all 32 teeth and procedures.
class DentalChartData {
  final DentalNotation notation;
  final Map<int, ToothData> teeth;
  final List<DentalProcedure> procedures;
  final String generalNotes;
  final DateTime? lastExaminedAt;

  DentalChartData({
    this.notation = DentalNotation.fdi,
    Map<int, ToothData>? teeth,
    this.procedures = const [],
    this.generalNotes = '',
    this.lastExaminedAt,
  }) : teeth = teeth ?? _initDefaultTeeth();

  static Map<int, ToothData> _initDefaultTeeth() {
    final map = <int, ToothData>{};
    for (final fdi in DentalNotationUtils.all32Teeth) {
      map[fdi] = ToothData(fdiNumber: fdi);
    }
    return map;
  }

  /// Tooth count metrics
  int get totalTeethPresent =>
      teeth.values.where((t) => t.condition != ToothCondition.missing).length;

  int get cariesCount =>
      teeth.values.where((t) => t.condition == ToothCondition.caries).length;

  int get filledCount =>
      teeth.values.where((t) => t.condition == ToothCondition.filled).length;

  int get rootCanalCount =>
      teeth.values.where((t) => t.condition == ToothCondition.rootCanal).length;

  int get crownCount =>
      teeth.values.where((t) => t.condition == ToothCondition.crown).length;

  int get missingCount =>
      teeth.values.where((t) => t.condition == ToothCondition.missing).length;

  int get implantCount =>
      teeth.values.where((t) => t.condition == ToothCondition.implant).length;

  int get impactedCount =>
      teeth.values.where((t) => t.condition == ToothCondition.impacted).length;

  double get totalPlannedFees =>
      procedures.fold(0.0, (sum, p) => sum + p.estimatedFee);

  int get completedProceduresCount =>
      procedures.where((p) => p.isCompleted).length;

  bool get hasFindings =>
      teeth.values.any((t) => t.condition != ToothCondition.healthy) ||
      procedures.isNotEmpty ||
      generalNotes.isNotEmpty;

  /// Compact one-line summary for clinical cards.
  String get summaryBadgeText {
    final parts = <String>[];
    parts.add('$totalTeethPresent Teeth Present');
    if (cariesCount > 0) parts.add('$cariesCount Caries');
    if (filledCount > 0) parts.add('$filledCount Filled');
    if (rootCanalCount > 0) parts.add('$rootCanalCount RCT');
    if (crownCount > 0) parts.add('$crownCount Crowns');
    if (missingCount > 0) parts.add('$missingCount Missing');
    if (implantCount > 0) parts.add('$implantCount Implants');
    return parts.join(' • ');
  }

  /// Detailed narrative summary of all pathological or restored teeth.
  String get clinicalFindingsNarrative {
    final items = <String>[];
    for (final tooth in teeth.values) {
      if (tooth.condition != ToothCondition.healthy) {
        final surfaces =
            tooth.surfacesSummary.isNotEmpty
                ? ' (${tooth.surfacesSummary})'
                : '';
        items.add(
          'Tooth ${tooth.fdiNumber}: ${tooth.condition.label}$surfaces${tooth.notes.isNotEmpty ? " - ${tooth.notes}" : ""}',
        );
      }
    }
    return items.join('\n');
  }

  DentalChartData copyWith({
    DentalNotation? notation,
    Map<int, ToothData>? teeth,
    List<DentalProcedure>? procedures,
    String? generalNotes,
    DateTime? lastExaminedAt,
  }) {
    return DentalChartData(
      notation: notation ?? this.notation,
      teeth: teeth ?? Map<int, ToothData>.from(this.teeth),
      procedures: procedures ?? List<DentalProcedure>.from(this.procedures),
      generalNotes: generalNotes ?? this.generalNotes,
      lastExaminedAt: lastExaminedAt ?? this.lastExaminedAt,
    );
  }

  /// Updates or sets state for a specific tooth.
  DentalChartData withUpdatedTooth(ToothData updated) {
    final newMap = Map<int, ToothData>.from(teeth);
    newMap[updated.fdiNumber] = updated;
    return copyWith(teeth: newMap, lastExaminedAt: DateTime.now());
  }

  /// Adds a new procedure to the treatment plan.
  DentalChartData withAddedProcedure(DentalProcedure procedure) {
    final newProcs = List<DentalProcedure>.from(procedures)..add(procedure);
    return copyWith(procedures: newProcs, lastExaminedAt: DateTime.now());
  }

  /// Updates an existing procedure.
  DentalChartData withUpdatedProcedure(DentalProcedure updated) {
    final newProcs =
        procedures.map((p) => p.id == updated.id ? updated : p).toList();
    return copyWith(procedures: newProcs, lastExaminedAt: DateTime.now());
  }

  /// Removes a procedure.
  DentalChartData withRemovedProcedure(String procedureId) {
    final newProcs = procedures.where((p) => p.id != procedureId).toList();
    return copyWith(procedures: newProcs, lastExaminedAt: DateTime.now());
  }

  Map<String, dynamic> toJson() => {
    'notation': notation.name,
    'teeth': teeth.values.map((t) => t.toJson()).toList(),
    'procedures': procedures.map((p) => p.toJson()).toList(),
    'generalNotes': generalNotes,
    'lastExaminedAt': lastExaminedAt?.toIso8601String(),
  };

  factory DentalChartData.fromJson(Map<String, dynamic> json) {
    final notationName = json['notation'] as String? ?? 'fdi';
    final notation = DentalNotation.values.firstWhere(
      (n) => n.name == notationName,
      orElse: () => DentalNotation.fdi,
    );

    final rawTeeth = json['teeth'] as List<dynamic>? ?? [];
    final teethMap = DentalChartData._initDefaultTeeth();
    for (final item in rawTeeth) {
      if (item is Map<String, dynamic>) {
        final tooth = ToothData.fromJson(item);
        teethMap[tooth.fdiNumber] = tooth;
      }
    }

    final rawProcs = json['procedures'] as List<dynamic>? ?? [];
    final procedures =
        rawProcs
            .whereType<Map<String, dynamic>>()
            .map(DentalProcedure.fromJson)
            .toList();

    return DentalChartData(
      notation: notation,
      teeth: teethMap,
      procedures: procedures,
      generalNotes: json['generalNotes'] as String? ?? '',
      lastExaminedAt:
          json['lastExaminedAt'] != null
              ? DateTime.tryParse(json['lastExaminedAt'] as String)
              : null,
    );
  }

  /// Safely attempts to parse dental chart data from a JSON string.
  static DentalChartData? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return DentalChartData.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  /// Merges this dental chart into an existing or new [MasterCaseRecordData].
  MasterCaseRecordData toMasterCaseRecord({
    required String patientId,
    MasterCaseRecordData? existingRecord,
    DateTime? examDate,
  }) {
    final now = examDate ?? DateTime.now();
    final dentalJson = jsonEncode(toJson());

    // Generate comprehensive oral exam note for the standard record
    final oralSummary = StringBuffer();
    oralSummary.writeln('=== DENTAL ODONTOGRAM EXAMINATION ===');
    oralSummary.writeln(summaryBadgeText);
    if (clinicalFindingsNarrative.isNotEmpty) {
      oralSummary.writeln('\nFindings:');
      oralSummary.writeln(clinicalFindingsNarrative);
    }
    if (generalNotes.isNotEmpty) {
      oralSummary.writeln('\nNotes: $generalNotes');
    }
    if (procedures.isNotEmpty) {
      oralSummary.writeln('\nTreatment Plan:');
      for (final p in procedures) {
        oralSummary.writeln(
          '- ${p.title} (${p.toothSummary}) [${p.status.toUpperCase()}] ₹${p.estimatedFee.toStringAsFixed(0)}',
        );
      }
    }

    final existingExam =
        existingRecord?.clinicalExam ?? const ClinicalExamVitals();
    final updatedExam = existingExam.copyWith(
      entOralExamination: oralSummary.toString().trim(),
      dentalChartJson: dentalJson,
    );

    // Build or update chief complaints if empty
    final complaints = List<ChiefComplaintDetail>.from(
      existingRecord?.chiefComplaints ?? [],
    );
    if (complaints.isEmpty && cariesCount > 0) {
      complaints.add(
        ChiefComplaintDetail(
          complaint: 'Dental pain / caries ($cariesCount teeth affected)',
          location: 'Oral Cavity',
          duration: 'Recent',
        ),
      );
    }

    // Build assessment provisional diagnosis
    final diag = StringBuffer();
    if (cariesCount > 0) diag.write('Dental Caries ($cariesCount)');
    if (rootCanalCount > 0) {
      if (diag.isNotEmpty) diag.write(', ');
      diag.write('Endodontic Pulpitis / RCT Needed ($rootCanalCount)');
    }
    if (missingCount > 0) {
      if (diag.isNotEmpty) diag.write(', ');
      diag.write('Partial Edentulism ($missingCount missing)');
    }
    final diagStr =
        diag.toString().isNotEmpty
            ? diag.toString()
            : 'Routine Dental Evaluation';

    final existingAssessment =
        existingRecord?.clinicalAssessment ?? const ClinicalAssessmentDetails();
    final updatedAssessment = existingAssessment.copyWith(
      provisionalDiagnosis:
          existingAssessment.provisionalDiagnosis.isNotEmpty
              ? existingAssessment.provisionalDiagnosis
              : diagStr,
      finalWorkingDiagnosis:
          existingAssessment.finalWorkingDiagnosis.isNotEmpty
              ? existingAssessment.finalWorkingDiagnosis
              : diagStr,
    );

    return MasterCaseRecordData(
      id: existingRecord?.id ?? IdGenerator.generate(),
      patientId: patientId,
      recordDate: existingRecord?.recordDate ?? now,
      identification:
          existingRecord?.identification ??
          const PatientIdentificationDetails(),
      chiefComplaints: complaints,
      additionalComplaints: existingRecord?.additionalComplaints ?? '',
      hpi: existingRecord?.hpi ?? const HpiDetails(),
      pastHistory: existingRecord?.pastHistory ?? const PastHistoryDetails(),
      familyHistory:
          existingRecord?.familyHistory ?? const FamilyHistoryDetails(),
      developmentalHistory:
          existingRecord?.developmentalHistory ??
          const DevelopmentalHistoryDetails(),
      physicalGenerals:
          existingRecord?.physicalGenerals ?? const PhysicalGenerals(),
      mentalGenerals: existingRecord?.mentalGenerals ?? const MentalGenerals(),
      lifestyleHabits:
          existingRecord?.lifestyleHabits ?? const LifestyleHistoryDetails(),
      clinicalExam: updatedExam,
      miasmaticAnalysis:
          existingRecord?.miasmaticAnalysis ?? const MiasmaticAnalysis(),
      caseTotality: existingRecord?.caseTotality ?? const CaseTotality(),
      clinicalAssessment: updatedAssessment,
      baselinePrescription:
          existingRecord?.baselinePrescription ??
          const PrescriptionPlanDetails(),
      investigations:
          existingRecord?.investigations ?? const InvestigationsPlanDetails(),
      followUpDetails:
          existingRecord?.followUpDetails ?? const FollowUpDetails(),
      followUpNotes: existingRecord?.followUpNotes ?? '',
      outcomeDetails: existingRecord?.outcomeDetails ?? const OutcomeDetails(),
      outcome: existingRecord?.outcome ?? 'Under Active Treatment',
      documentation:
          existingRecord?.documentation ?? const DocumentationDetails(),
    );
  }

  /// Reconstructs a [DentalChartData] from a [MasterCaseRecordData].
  factory DentalChartData.fromMasterCaseRecord(MasterCaseRecordData record) {
    final parsed = tryParse(record.clinicalExam.dentalChartJson);
    if (parsed != null) return parsed;

    // If no serialized chart exists, check if there are oral notes
    final oral = record.clinicalExam.entOralExamination;
    return DentalChartData(generalNotes: oral);
  }
}
