import 'dart:convert';

/// Section 1: Patient Identification fields from Master Excel
class PatientIdentificationDetails {
  final String regNo;
  final String firstVisitDate;
  final String patientName;
  final String age;
  final String gender;
  final String dob;
  final String occupation;
  final String address;
  final String phone;
  final String maritalStatus;

  const PatientIdentificationDetails({
    this.regNo = '',
    this.firstVisitDate = '',
    this.patientName = '',
    this.age = '',
    this.gender = '',
    this.dob = '',
    this.occupation = '',
    this.address = '',
    this.phone = '',
    this.maritalStatus = '',
  });

  Map<String, dynamic> toJson() => {
        'regNo': regNo,
        'firstVisitDate': firstVisitDate,
        'patientName': patientName,
        'age': age,
        'gender': gender,
        'dob': dob,
        'occupation': occupation,
        'address': address,
        'phone': phone,
        'maritalStatus': maritalStatus,
      };

  factory PatientIdentificationDetails.fromJson(Map<String, dynamic> json) =>
      PatientIdentificationDetails(
        regNo: json['regNo'] as String? ?? '',
        firstVisitDate: json['firstVisitDate'] as String? ?? '',
        patientName: json['patientName'] as String? ?? '',
        age: json['age'] as String? ?? '',
        gender: json['gender'] as String? ?? '',
        dob: json['dob'] as String? ?? '',
        occupation: json['occupation'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        maritalStatus: json['maritalStatus'] as String? ?? '',
      );
}

/// Section 2: Chief Complaint details (Dynamic list with + Add Complaint)
class ChiefComplaintDetail {
  final String complaint;
  final String location;
  final String sensation;
  final String modalitiesAgg;
  final String modalitiesAmel;
  final String concomitants;
  final String duration;
  final String causation;
  final String severity;

  const ChiefComplaintDetail({
    this.complaint = '',
    this.location = '',
    this.sensation = '',
    this.modalitiesAgg = '',
    this.modalitiesAmel = '',
    this.concomitants = '',
    this.duration = '',
    this.causation = '',
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
        'causation': causation,
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
        causation: json['causation'] as String? ?? '',
        severity: json['severity'] as String? ?? 'Moderate',
      );
}

/// Section 3: History of Present Illness (HPI)
class HpiDetails {
  final String progression;
  final String firstOccurrence;
  final String previousTreatments;
  final String precipitatingFactors;

  const HpiDetails({
    this.progression = '',
    this.firstOccurrence = '',
    this.previousTreatments = '',
    this.precipitatingFactors = '',
  });

  Map<String, dynamic> toJson() => {
        'progression': progression,
        'firstOccurrence': firstOccurrence,
        'previousTreatments': previousTreatments,
        'precipitatingFactors': precipitatingFactors,
      };

  factory HpiDetails.fromJson(Map<String, dynamic> json) => HpiDetails(
        progression: json['progression'] as String? ?? '',
        firstOccurrence: json['firstOccurrence'] as String? ?? '',
        previousTreatments: json['previousTreatments'] as String? ?? '',
        precipitatingFactors: json['precipitatingFactors'] as String? ?? '',
      );

  factory HpiDetails.fromString(String raw) {
    if (raw.trim().isEmpty) return const HpiDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return HpiDetails.fromJson(decoded);
      }
    } catch (_) {}
    return HpiDetails(progression: raw);
  }
}

/// Section 4: Past Medical History
class PastHistoryDetails {
  final String childhoodIllnesses;
  final String chronicDiseases;
  final String surgeries;
  final String injuriesTrauma;
  final String allergies;
  final String previousTreatments;

  const PastHistoryDetails({
    this.childhoodIllnesses = '',
    this.chronicDiseases = '',
    this.surgeries = '',
    this.injuriesTrauma = '',
    this.allergies = '',
    this.previousTreatments = '',
  });

  Map<String, dynamic> toJson() => {
        'childhoodIllnesses': childhoodIllnesses,
        'chronicDiseases': chronicDiseases,
        'surgeries': surgeries,
        'injuriesTrauma': injuriesTrauma,
        'allergies': allergies,
        'previousTreatments': previousTreatments,
      };

  factory PastHistoryDetails.fromJson(Map<String, dynamic> json) =>
      PastHistoryDetails(
        childhoodIllnesses: json['childhoodIllnesses'] as String? ?? '',
        chronicDiseases: json['chronicDiseases'] as String? ?? '',
        surgeries: json['surgeries'] as String? ?? '',
        injuriesTrauma: json['injuriesTrauma'] as String? ?? '',
        allergies: json['allergies'] as String? ?? '',
        previousTreatments: json['previousTreatments'] as String? ?? '',
      );

  factory PastHistoryDetails.fromString(String raw) {
    if (raw.trim().isEmpty) return const PastHistoryDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return PastHistoryDetails.fromJson(decoded);
      }
    } catch (_) {}
    return PastHistoryDetails(chronicDiseases: raw);
  }
}

/// Section 5: Family Medical History
class FamilyHistoryDetails {
  final String father;
  final String mother;
  final String siblingsChildren;
  final String hereditaryDiseases;
  final String psychiatricHistory;

  const FamilyHistoryDetails({
    this.father = '',
    this.mother = '',
    this.siblingsChildren = '',
    this.hereditaryDiseases = '',
    this.psychiatricHistory = '',
  });

  Map<String, dynamic> toJson() => {
        'father': father,
        'mother': mother,
        'siblingsChildren': siblingsChildren,
        'hereditaryDiseases': hereditaryDiseases,
        'psychiatricHistory': psychiatricHistory,
      };

  factory FamilyHistoryDetails.fromJson(Map<String, dynamic> json) =>
      FamilyHistoryDetails(
        father: json['father'] as String? ?? '',
        mother: json['mother'] as String? ?? '',
        siblingsChildren: json['siblingsChildren'] as String? ?? '',
        hereditaryDiseases: json['hereditaryDiseases'] as String? ?? '',
        psychiatricHistory: json['psychiatricHistory'] as String? ?? '',
      );

  factory FamilyHistoryDetails.fromString(String raw) {
    if (raw.trim().isEmpty) return const FamilyHistoryDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return FamilyHistoryDetails.fromJson(decoded);
      }
    } catch (_) {}
    return FamilyHistoryDetails(hereditaryDiseases: raw);
  }
}

/// Section 6: Intrauterine & Developmental History
class DevelopmentalHistoryDetails {
  final String maternalHealth;
  final String deliveryComplications;
  final String milestonesDentition;
  final String vaccinationNeonatal;

  const DevelopmentalHistoryDetails({
    this.maternalHealth = '',
    this.deliveryComplications = '',
    this.milestonesDentition = '',
    this.vaccinationNeonatal = '',
  });

  Map<String, dynamic> toJson() => {
        'maternalHealth': maternalHealth,
        'deliveryComplications': deliveryComplications,
        'milestonesDentition': milestonesDentition,
        'vaccinationNeonatal': vaccinationNeonatal,
      };

  factory DevelopmentalHistoryDetails.fromJson(Map<String, dynamic> json) =>
      DevelopmentalHistoryDetails(
        maternalHealth: json['maternalHealth'] as String? ?? '',
        deliveryComplications: json['deliveryComplications'] as String? ?? '',
        milestonesDentition: json['milestonesDentition'] as String? ?? '',
        vaccinationNeonatal: json['vaccinationNeonatal'] as String? ?? '',
      );

  factory DevelopmentalHistoryDetails.fromString(String raw) {
    if (raw.trim().isEmpty) return const DevelopmentalHistoryDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return DevelopmentalHistoryDetails.fromJson(decoded);
      }
    } catch (_) {}
    return DevelopmentalHistoryDetails(milestonesDentition: raw);
  }
}

/// Section 7: Physical Generals
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
  final String energyFatigue;
  final String skinHairNails;

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
    this.energyFatigue = '',
    this.skinHairNails = '',
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
        'energyFatigue': energyFatigue,
        'skinHairNails': skinHairNails,
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
        energyFatigue: json['energyFatigue'] as String? ?? '',
        skinHairNails: json['skinHairNails'] as String? ?? '',
      );
}

/// Section 8: Mental Generals
class MentalGenerals {
  final String disposition;
  final String irritabilityAnger;
  final String anxietyFears;
  final String sadnessGrief;
  final String companySolitude;
  final String consolationReaction;
  final String memoryConcentration;
  final String stressResponse;

  const MentalGenerals({
    this.disposition = '',
    this.irritabilityAnger = '',
    this.anxietyFears = '',
    this.sadnessGrief = '',
    this.companySolitude = '',
    this.consolationReaction = '',
    this.memoryConcentration = '',
    this.stressResponse = '',
  });

  Map<String, dynamic> toJson() => {
        'disposition': disposition,
        'irritabilityAnger': irritabilityAnger,
        'anxietyFears': anxietyFears,
        'sadnessGrief': sadnessGrief,
        'companySolitude': companySolitude,
        'consolationReaction': consolationReaction,
        'memoryConcentration': memoryConcentration,
        'stressResponse': stressResponse,
      };

  factory MentalGenerals.fromJson(Map<String, dynamic> json) => MentalGenerals(
        disposition: json['disposition'] as String? ?? '',
        irritabilityAnger: json['irritabilityAnger'] as String? ?? '',
        anxietyFears: json['anxietyFears'] as String? ?? '',
        sadnessGrief: json['sadnessGrief'] as String? ?? '',
        companySolitude: (json['companySolitude'] ?? json['companyDesireSolitude']) as String? ?? '',
        consolationReaction: json['consolationReaction'] as String? ?? '',
        memoryConcentration: json['memoryConcentration'] as String? ?? '',
        stressResponse: json['stressResponse'] as String? ?? '',
      );
}

/// Section 9: Personal & Lifestyle History
class LifestyleHistoryDetails {
  final String dietaryHabits;
  final String habitsAddictions;
  final String physicalActivity;
  final String occupationalHazards;
  final String socialStressors;

  const LifestyleHistoryDetails({
    this.dietaryHabits = '',
    this.habitsAddictions = '',
    this.physicalActivity = '',
    this.occupationalHazards = '',
    this.socialStressors = '',
  });

  Map<String, dynamic> toJson() => {
        'dietaryHabits': dietaryHabits,
        'habitsAddictions': habitsAddictions,
        'physicalActivity': physicalActivity,
        'occupationalHazards': occupationalHazards,
        'socialStressors': socialStressors,
      };

  factory LifestyleHistoryDetails.fromJson(Map<String, dynamic> json) =>
      LifestyleHistoryDetails(
        dietaryHabits: json['dietaryHabits'] as String? ?? '',
        habitsAddictions: json['habitsAddictions'] as String? ?? '',
        physicalActivity: json['physicalActivity'] as String? ?? '',
        occupationalHazards: json['occupationalHazards'] as String? ?? '',
        socialStressors: json['socialStressors'] as String? ?? '',
      );

  factory LifestyleHistoryDetails.fromString(String raw) {
    if (raw.trim().isEmpty) return const LifestyleHistoryDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return LifestyleHistoryDetails.fromJson(decoded);
      }
    } catch (_) {}
    return LifestyleHistoryDetails(dietaryHabits: raw);
  }
}

/// Section 10: Clinical Exam & Vitals
class ClinicalExamVitals {
  final String generalAppearance;
  final String pallorIcterus;
  final String bp;
  final String pulse;
  final String respiratoryRate;
  final String temperature;
  final String spo2;
  final String weightKg;
  final String heightCm;
  final String bmi;
  final String tongueExam;
  final String systemicFindings;

  const ClinicalExamVitals({
    this.generalAppearance = '',
    this.pallorIcterus = '',
    this.bp = '',
    this.pulse = '',
    this.respiratoryRate = '',
    this.temperature = '',
    this.spo2 = '',
    this.weightKg = '',
    this.heightCm = '',
    this.bmi = '',
    this.tongueExam = '',
    this.systemicFindings = '',
  });

  Map<String, dynamic> toJson() => {
        'generalAppearance': generalAppearance,
        'pallorIcterus': pallorIcterus,
        'bp': bp,
        'pulse': pulse,
        'respiratoryRate': respiratoryRate,
        'temperature': temperature,
        'spo2': spo2,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'bmi': bmi,
        'tongueExam': tongueExam,
        'systemicFindings': systemicFindings,
      };

  factory ClinicalExamVitals.fromJson(Map<String, dynamic> json) =>
      ClinicalExamVitals(
        generalAppearance: json['generalAppearance'] as String? ?? '',
        pallorIcterus: json['pallorIcterus'] as String? ?? '',
        bp: json['bp'] as String? ?? '',
        pulse: json['pulse'] as String? ?? '',
        respiratoryRate: json['respiratoryRate'] as String? ?? '',
        temperature: json['temperature'] as String? ?? '',
        spo2: json['spo2'] as String? ?? '',
        weightKg: json['weightKg'] as String? ?? '',
        heightCm: json['heightCm'] as String? ?? '',
        bmi: json['bmi'] as String? ?? '',
        tongueExam: json['tongueExam'] as String? ?? '',
        systemicFindings: json['systemicFindings'] as String? ?? '',
      );
}

/// Section 11: Miasmatic Analysis
class MiasmaticAnalysis {
  final String psoricFeatures;
  final String sycoticFeatures;
  final String syphiliticFeatures;
  final String tubercularFeatures;
  final String cancerinicFeatures;
  final String characteristicSymptoms;
  final String dominantMiasm;

  const MiasmaticAnalysis({
    this.psoricFeatures = '',
    this.sycoticFeatures = '',
    this.syphiliticFeatures = '',
    this.tubercularFeatures = '',
    this.cancerinicFeatures = '',
    this.characteristicSymptoms = '',
    this.dominantMiasm = 'Mixed / Dynamic',
  });

  Map<String, dynamic> toJson() => {
        'psoricFeatures': psoricFeatures,
        'sycoticFeatures': sycoticFeatures,
        'syphiliticFeatures': syphiliticFeatures,
        'tubercularFeatures': tubercularFeatures,
        'cancerinicFeatures': cancerinicFeatures,
        'characteristicSymptoms': characteristicSymptoms,
        'dominantMiasm': dominantMiasm,
      };

  factory MiasmaticAnalysis.fromJson(Map<String, dynamic> json) =>
      MiasmaticAnalysis(
        psoricFeatures: json['psoricFeatures'] as String? ?? '',
        sycoticFeatures: json['sycoticFeatures'] as String? ?? '',
        syphiliticFeatures: json['syphiliticFeatures'] as String? ?? '',
        tubercularFeatures: json['tubercularFeatures'] as String? ?? '',
        cancerinicFeatures: json['cancerinicFeatures'] as String? ?? '',
        characteristicSymptoms: json['characteristicSymptoms'] as String? ?? '',
        dominantMiasm: json['dominantMiasm'] as String? ?? 'Mixed / Dynamic',
      );
}

/// Section 12: Case Totality & Repertory Analysis
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

/// Section 13: Prescription Plan
class PrescriptionPlanDetails {
  final String remedyName;
  final String potency;
  final String dosageForm;
  final String doseCount;
  final String frequency;
  final String duration;
  final String instructions;
  final String dietaryAdvice;
  final String referralAdvice;

  const PrescriptionPlanDetails({
    this.remedyName = '',
    this.potency = '',
    this.dosageForm = '',
    this.doseCount = '',
    this.frequency = '',
    this.duration = '',
    this.instructions = '',
    this.dietaryAdvice = '',
    this.referralAdvice = '',
  });

  Map<String, dynamic> toJson() => {
        'remedyName': remedyName,
        'potency': potency,
        'dosageForm': dosageForm,
        'doseCount': doseCount,
        'frequency': frequency,
        'duration': duration,
        'instructions': instructions,
        'dietaryAdvice': dietaryAdvice,
        'referralAdvice': referralAdvice,
      };

  factory PrescriptionPlanDetails.fromJson(Map<String, dynamic> json) =>
      PrescriptionPlanDetails(
        remedyName: json['remedyName'] as String? ?? '',
        potency: json['potency'] as String? ?? '',
        dosageForm: json['dosageForm'] as String? ?? '',
        doseCount: json['doseCount'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
        instructions: json['instructions'] as String? ?? '',
        dietaryAdvice: json['dietaryAdvice'] as String? ?? '',
        referralAdvice: json['referralAdvice'] as String? ?? '',
      );

  factory PrescriptionPlanDetails.fromString(String raw) {
    if (raw.trim().isEmpty) return const PrescriptionPlanDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return PrescriptionPlanDetails.fromJson(decoded);
      }
    } catch (_) {}
    return PrescriptionPlanDetails(remedyName: raw);
  }
}

/// Section 14: Diagnostic Lab Orders & Investigations
class InvestigationsPlanDetails {
  final String testsAdvised;
  final String resultsInterpretation;

  const InvestigationsPlanDetails({
    this.testsAdvised = '',
    this.resultsInterpretation = '',
  });

  Map<String, dynamic> toJson() => {
        'testsAdvised': testsAdvised,
        'resultsInterpretation': resultsInterpretation,
      };

  factory InvestigationsPlanDetails.fromJson(Map<String, dynamic> json) =>
      InvestigationsPlanDetails(
        testsAdvised: json['testsAdvised'] as String? ?? '',
        resultsInterpretation: json['resultsInterpretation'] as String? ?? '',
      );

  factory InvestigationsPlanDetails.fromString(String raw) {
    if (raw.trim().isEmpty) return const InvestigationsPlanDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return InvestigationsPlanDetails.fromJson(decoded);
      }
    } catch (_) {}
    return InvestigationsPlanDetails(testsAdvised: raw);
  }
}

/// Full Master Case Model uniting all 16 clinical sections.
class MasterCaseRecordData {
  final String? id;
  final String patientId;
  final DateTime recordDate;
  final PatientIdentificationDetails identification; // Section 1
  final List<ChiefComplaintDetail> chiefComplaints; // Section 2
  final HpiDetails hpi; // Section 3
  final PastHistoryDetails pastHistory; // Section 4
  final FamilyHistoryDetails familyHistory; // Section 5
  final DevelopmentalHistoryDetails developmentalHistory; // Section 6
  final PhysicalGenerals physicalGenerals; // Section 7
  final MentalGenerals mentalGenerals; // Section 8
  final LifestyleHistoryDetails lifestyleHabits; // Section 9
  final ClinicalExamVitals clinicalExam; // Section 10
  final MiasmaticAnalysis miasmaticAnalysis; // Section 11
  final CaseTotality caseTotality; // Section 12
  final PrescriptionPlanDetails baselinePrescription; // Section 13
  final InvestigationsPlanDetails investigations; // Section 14
  final String followUpNotes; // Section 15
  final String outcome; // Section 16

  const MasterCaseRecordData({
    this.id,
    required this.patientId,
    required this.recordDate,
    this.identification = const PatientIdentificationDetails(),
    this.chiefComplaints = const [ChiefComplaintDetail()],
    this.hpi = const HpiDetails(),
    this.pastHistory = const PastHistoryDetails(),
    this.familyHistory = const FamilyHistoryDetails(),
    this.developmentalHistory = const DevelopmentalHistoryDetails(),
    this.physicalGenerals = const PhysicalGenerals(),
    this.mentalGenerals = const MentalGenerals(),
    this.lifestyleHabits = const LifestyleHistoryDetails(),
    this.clinicalExam = const ClinicalExamVitals(),
    this.miasmaticAnalysis = const MiasmaticAnalysis(),
    this.caseTotality = const CaseTotality(),
    this.baselinePrescription = const PrescriptionPlanDetails(),
    this.investigations = const InvestigationsPlanDetails(),
    this.followUpNotes = '',
    this.outcome = 'Under Active Treatment',
  });

  String get identificationJson => jsonEncode(identification.toJson());
  String get chiefComplaintsJson => jsonEncode(chiefComplaints.map((c) => c.toJson()).toList());
  String get hpiJson => jsonEncode(hpi.toJson());
  String get pastHistoryJson => jsonEncode(pastHistory.toJson());
  String get familyHistoryJson => jsonEncode(familyHistory.toJson());
  String get developmentalHistoryJson => jsonEncode(developmentalHistory.toJson());
  String get physicalGeneralsJson => jsonEncode(physicalGenerals.toJson());
  String get mentalGeneralsJson => jsonEncode(mentalGenerals.toJson());
  String get lifestyleJson => jsonEncode(lifestyleHabits.toJson());
  String get clinicalExamJson => jsonEncode(clinicalExam.toJson());
  String get miasmaticAnalysisJson => jsonEncode(miasmaticAnalysis.toJson());
  String get caseTotalityJson => jsonEncode(caseTotality.toJson());
  String get baselinePrescriptionJson => jsonEncode(baselinePrescription.toJson());
  String get investigationsJson => jsonEncode(investigations.toJson());

  static List<ChiefComplaintDetail> parseChiefComplaints(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return [const ChiefComplaintDetail()];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List && decoded.isNotEmpty) {
        return decoded.map((e) => ChiefComplaintDetail.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [const ChiefComplaintDetail()];
  }

  static HpiDetails parseHpi(String? raw) => HpiDetails.fromString(raw ?? '');
  static PastHistoryDetails parsePastHistory(String? raw) => PastHistoryDetails.fromString(raw ?? '');
  static FamilyHistoryDetails parseFamilyHistory(String? raw) => FamilyHistoryDetails.fromString(raw ?? '');
  static DevelopmentalHistoryDetails parseDevHistory(String? raw) => DevelopmentalHistoryDetails.fromString(raw ?? '');
  static LifestyleHistoryDetails parseLifestyle(String? raw) => LifestyleHistoryDetails.fromString(raw ?? '');
  static PrescriptionPlanDetails parsePrescription(String? raw) => PrescriptionPlanDetails.fromString(raw ?? '');
  static InvestigationsPlanDetails parseInvestigations(String? raw) => InvestigationsPlanDetails.fromString(raw ?? '');

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