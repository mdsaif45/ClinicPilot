import 'dart:convert';

/// Block 2: Chief Complaint details (up to 3 distinct complaints).
class ChiefComplaintDetail {
  final String complaint;
  final String location;
  final String sensation;
  final String modalitiesAgg;
  final String modalitiesAmel;
  final String concomitants;
  final String duration;
  final String severity;

  const ChiefComplaintDetail({
    this.complaint = '',
    this.location = '',
    this.sensation = '',
    this.modalitiesAgg = '',
    this.modalitiesAmel = '',
    this.concomitants = '',
    this.duration = '',
    this.severity = 'Moderate',
  });

  Map<String, dynamic> toJson() => {
        'complaint': complaint,
        'location': location,
        'sensation': sensation,
        'modalitiesAgg': modalitiesAgg,
        'modalitiesAmel': modalitiesAmel,
        'concomitants': concomitants,
        'duration': duration,
        'severity': severity,
      };

  factory ChiefComplaintDetail.fromJson(Map<String, dynamic> json) =>
      ChiefComplaintDetail(
        complaint: json['complaint'] as String? ?? '',
        location: json['location'] as String? ?? '',
        sensation: json['sensation'] as String? ?? '',
        modalitiesAgg: json['modalitiesAgg'] as String? ?? '',
        modalitiesAmel: json['modalitiesAmel'] as String? ?? '',
        concomitants: json['concomitants'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
        severity: json['severity'] as String? ?? 'Moderate',
      );
}

/// Block 7: Physical Generals (thermal, thirst, appetite, cravings, aversions, stool, sweat, sleep).
class PhysicalGenerals {
  final String thermal; // Hot / Chilly / Ambithermal
  final String weatherPreference;
  final String thirst;
  final String appetite;
  final String cravings;
  final String aversions;
  final String intolerances;
  final String stool;
  final String urine;
  final String perspiration;
  final String sleep;
  final String dreams;

  const PhysicalGenerals({
    this.thermal = 'Ambithermal',
    this.weatherPreference = '',
    this.thirst = '',
    this.appetite = '',
    this.cravings = '',
    this.aversions = '',
    this.intolerances = '',
    this.stool = '',
    this.urine = '',
    this.perspiration = '',
    this.sleep = '',
    this.dreams = '',
  });

  Map<String, dynamic> toJson() => {
        'thermal': thermal,
        'weatherPreference': weatherPreference,
        'thirst': thirst,
        'appetite': appetite,
        'cravings': cravings,
        'aversions': aversions,
        'intolerances': intolerances,
        'stool': stool,
        'urine': urine,
        'perspiration': perspiration,
        'sleep': sleep,
        'dreams': dreams,
      };

  factory PhysicalGenerals.fromJson(Map<String, dynamic> json) =>
      PhysicalGenerals(
        thermal: json['thermal'] as String? ?? 'Ambithermal',
        weatherPreference: json['weatherPreference'] as String? ?? '',
        thirst: json['thirst'] as String? ?? '',
        appetite: json['appetite'] as String? ?? '',
        cravings: json['cravings'] as String? ?? '',
        aversions: json['aversions'] as String? ?? '',
        intolerances: json['intolerances'] as String? ?? '',
        stool: json['stool'] as String? ?? '',
        urine: json['urine'] as String? ?? '',
        perspiration: json['perspiration'] as String? ?? '',
        sleep: json['sleep'] as String? ?? '',
        dreams: json['dreams'] as String? ?? '',
      );
}

/// Block 8: Mental Generals (mind, disposition, emotions, fears, memory).
class MentalGenerals {
  final String disposition;
  final String irritabilityAnger;
  final String anxietyFears;
  final String sadnessGrief;
  final String consolationReaction;
  final String companyDesireSolitude;
  final String memoryConcentration;
  final String stressResponse;

  const MentalGenerals({
    this.disposition = '',
    this.irritabilityAnger = '',
    this.anxietyFears = '',
    this.sadnessGrief = '',
    this.consolationReaction = '',
    this.companyDesireSolitude = '',
    this.memoryConcentration = '',
    this.stressResponse = '',
  });

  Map<String, dynamic> toJson() => {
        'disposition': disposition,
        'irritabilityAnger': irritabilityAnger,
        'anxietyFears': anxietyFears,
        'sadnessGrief': sadnessGrief,
        'consolationReaction': consolationReaction,
        'companyDesireSolitude': companyDesireSolitude,
        'memoryConcentration': memoryConcentration,
        'stressResponse': stressResponse,
      };

  factory MentalGenerals.fromJson(Map<String, dynamic> json) => MentalGenerals(
        disposition: json['disposition'] as String? ?? '',
        irritabilityAnger: json['irritabilityAnger'] as String? ?? '',
        anxietyFears: json['anxietyFears'] as String? ?? '',
        sadnessGrief: json['sadnessGrief'] as String? ?? '',
        consolationReaction: json['consolationReaction'] as String? ?? '',
        companyDesireSolitude: json['companyDesireSolitude'] as String? ?? '',
        memoryConcentration: json['memoryConcentration'] as String? ?? '',
        stressResponse: json['stressResponse'] as String? ?? '',
      );
}

/// Block 10: Clinical Exam & Vitals.
class ClinicalExamVitals {
  final String bp;
  final String pulse;
  final String weightKg;
  final String heightCm;
  final String temperature;
  final String spo2;
  final String pallorIcterus;
  final String tongueExam;
  final String systemicFindings;

  const ClinicalExamVitals({
    this.bp = '',
    this.pulse = '',
    this.weightKg = '',
    this.heightCm = '',
    this.temperature = '',
    this.spo2 = '',
    this.pallorIcterus = '',
    this.tongueExam = '',
    this.systemicFindings = '',
  });

  Map<String, dynamic> toJson() => {
        'bp': bp,
        'pulse': pulse,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'temperature': temperature,
        'spo2': spo2,
        'pallorIcterus': pallorIcterus,
        'tongueExam': tongueExam,
        'systemicFindings': systemicFindings,
      };

  factory ClinicalExamVitals.fromJson(Map<String, dynamic> json) =>
      ClinicalExamVitals(
        bp: json['bp'] as String? ?? '',
        pulse: json['pulse'] as String? ?? '',
        weightKg: json['weightKg'] as String? ?? '',
        heightCm: json['heightCm'] as String? ?? '',
        temperature: json['temperature'] as String? ?? '',
        spo2: json['spo2'] as String? ?? '',
        pallorIcterus: json['pallorIcterus'] as String? ?? '',
        tongueExam: json['tongueExam'] as String? ?? '',
        systemicFindings: json['systemicFindings'] as String? ?? '',
      );
}

/// Block 11: Miasmatic Analysis.
class MiasmaticAnalysis {
  final String psoricFeatures;
  final String sycoticFeatures;
  final String syphiliticFeatures;
  final String tubercularFeatures;
  final String dominantMiasm;

  const MiasmaticAnalysis({
    this.psoricFeatures = '',
    this.sycoticFeatures = '',
    this.syphiliticFeatures = '',
    this.tubercularFeatures = '',
    this.dominantMiasm = 'Mixed / Dynamic',
  });

  Map<String, dynamic> toJson() => {
        'psoricFeatures': psoricFeatures,
        'sycoticFeatures': sycoticFeatures,
        'syphiliticFeatures': syphiliticFeatures,
        'tubercularFeatures': tubercularFeatures,
        'dominantMiasm': dominantMiasm,
      };

  factory MiasmaticAnalysis.fromJson(Map<String, dynamic> json) =>
      MiasmaticAnalysis(
        psoricFeatures: json['psoricFeatures'] as String? ?? '',
        sycoticFeatures: json['sycoticFeatures'] as String? ?? '',
        syphiliticFeatures: json['syphiliticFeatures'] as String? ?? '',
        tubercularFeatures: json['tubercularFeatures'] as String? ?? '',
        dominantMiasm: json['dominantMiasm'] as String? ?? 'Mixed / Dynamic',
      );
}

/// Block 12: Case Totality & Repertorial Analysis.
class CaseTotality {
  final String characteristicSymptoms;
  final String rubricsSelected;
  final String repertorialResult;
  final String differentialRemedies;
  final String selectedRemedy;
  final String potency;
  final String justification;

  const CaseTotality({
    this.characteristicSymptoms = '',
    this.rubricsSelected = '',
    this.repertorialResult = '',
    this.differentialRemedies = '',
    this.selectedRemedy = '',
    this.potency = '',
    this.justification = '',
  });

  Map<String, dynamic> toJson() => {
        'characteristicSymptoms': characteristicSymptoms,
        'rubricsSelected': rubricsSelected,
        'repertorialResult': repertorialResult,
        'differentialRemedies': differentialRemedies,
        'selectedRemedy': selectedRemedy,
        'potency': potency,
        'justification': justification,
      };

  factory CaseTotality.fromJson(Map<String, dynamic> json) => CaseTotality(
        characteristicSymptoms: json['characteristicSymptoms'] as String? ?? '',
        rubricsSelected: json['rubricsSelected'] as String? ?? '',
        repertorialResult: json['repertorialResult'] as String? ?? '',
        differentialRemedies: json['differentialRemedies'] as String? ?? '',
        selectedRemedy: json['selectedRemedy'] as String? ?? '',
        potency: json['potency'] as String? ?? '',
        justification: json['justification'] as String? ?? '',
      );
}

/// Full Master Case Model uniting all 16 clinical sections.
class MasterCaseRecordData {
  final String? id;
  final String patientId;
  final DateTime recordDate;
  final List<ChiefComplaintDetail> chiefComplaints; // Section 2
  final String hpi; // Section 3
  final String pastHistory; // Section 4
  final String familyHistory; // Section 5
  final String developmentalHistory; // Section 6
  final PhysicalGenerals physicalGenerals; // Section 7
  final MentalGenerals mentalGenerals; // Section 8
  final String lifestyleHabits; // Section 9
  final ClinicalExamVitals clinicalExam; // Section 10
  final MiasmaticAnalysis miasmaticAnalysis; // Section 11
  final CaseTotality caseTotality; // Section 12
  final String baselinePrescription; // Section 13
  final String investigations; // Section 14
  final String followUpNotes; // Section 15
  final String outcome; // Section 16

  const MasterCaseRecordData({
    this.id,
    required this.patientId,
    required this.recordDate,
    this.chiefComplaints = const [],
    this.hpi = '',
    this.pastHistory = '',
    this.familyHistory = '',
    this.developmentalHistory = '',
    this.physicalGenerals = const PhysicalGenerals(),
    this.mentalGenerals = const MentalGenerals(),
    this.lifestyleHabits = '',
    this.clinicalExam = const ClinicalExamVitals(),
    this.miasmaticAnalysis = const MiasmaticAnalysis(),
    this.caseTotality = const CaseTotality(),
    this.baselinePrescription = '',
    this.investigations = '',
    this.followUpNotes = '',
    this.outcome = 'Under Active Treatment',
  });

  String get chiefComplaintsJson => jsonEncode(chiefComplaints.map((c) => c.toJson()).toList());
  String get physicalGeneralsJson => jsonEncode(physicalGenerals.toJson());
  String get mentalGeneralsJson => jsonEncode(mentalGenerals.toJson());
  String get clinicalExamJson => jsonEncode(clinicalExam.toJson());
  String get miasmaticAnalysisJson => jsonEncode(miasmaticAnalysis.toJson());
  String get caseTotalityJson => jsonEncode(caseTotality.toJson());

  static List<ChiefComplaintDetail> parseChiefComplaints(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded.map((e) => ChiefComplaintDetail.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static PhysicalGenerals parsePhysicalGenerals(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return const PhysicalGenerals();
    try {
      return PhysicalGenerals.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {}
    return const PhysicalGenerals();
  }

  static MentalGenerals parseMentalGenerals(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return const MentalGenerals();
    try {
      return MentalGenerals.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {}
    return const MentalGenerals();
  }

  static ClinicalExamVitals parseClinicalExam(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return const ClinicalExamVitals();
    try {
      return ClinicalExamVitals.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {}
    return const ClinicalExamVitals();
  }

  static MiasmaticAnalysis parseMiasmaticAnalysis(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return const MiasmaticAnalysis();
    try {
      return MiasmaticAnalysis.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {}
    return const MiasmaticAnalysis();
  }

  static CaseTotality parseCaseTotality(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return const CaseTotality();
    try {
      return CaseTotality.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {}
    return const CaseTotality();
  }
}
