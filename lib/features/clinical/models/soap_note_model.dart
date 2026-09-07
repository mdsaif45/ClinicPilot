import 'case_record_models.dart';

/// Structured vital signs for general medical and clinical consultations.
class VitalSigns {
  final String bloodPressure; // e.g. "120/80"
  final String pulse; // bpm
  final String temperature; // °F
  final String spo2; // %
  final String respiratoryRate; // breaths / min
  final String weightKg; // kg
  final String heightCm; // cm
  final String bmi; // calculated or manual
  final String bloodSugar; // mg/dL

  const VitalSigns({
    this.bloodPressure = '',
    this.pulse = '',
    this.temperature = '',
    this.spo2 = '',
    this.respiratoryRate = '',
    this.weightKg = '',
    this.heightCm = '',
    this.bmi = '',
    this.bloodSugar = '',
  });

  bool get isNotEmpty =>
      bloodPressure.trim().isNotEmpty ||
      pulse.trim().isNotEmpty ||
      temperature.trim().isNotEmpty ||
      spo2.trim().isNotEmpty ||
      respiratoryRate.trim().isNotEmpty ||
      weightKg.trim().isNotEmpty ||
      heightCm.trim().isNotEmpty ||
      bloodSugar.trim().isNotEmpty;

  bool get hasVitals => isNotEmpty;

  /// Calculate BMI from weight (kg) and height (cm).
  static String calculateBmi(String weight, String height) {
    final w = double.tryParse(weight.trim());
    final h = double.tryParse(height.trim());
    if (w == null || h == null || w <= 0 || h <= 0) return '';
    final heightInMeters = h / 100.0;
    final bmiVal = w / (heightInMeters * heightInMeters);
    return bmiVal.toStringAsFixed(1);
  }

  /// Categorize BMI according to WHO standard ranges.
  static String getBmiCategory(String bmi) {
    final val = double.tryParse(bmi.trim());
    if (val == null) return '';
    if (val < 18.5) return 'Underweight';
    if (val < 25.0) return 'Normal weight';
    if (val < 30.0) return 'Overweight';
    return 'Obese';
  }

  String get bmiCategory => getBmiCategory(bmi);

  /// Compact single-line summary of non-empty vitals for chips and headers.
  String get summaryLine {
    final parts = <String>[];
    if (bloodPressure.trim().isNotEmpty) {
      parts.add('BP: $bloodPressure mmHg');
    }
    if (pulse.trim().isNotEmpty) parts.add('Pulse: $pulse bpm');
    if (temperature.trim().isNotEmpty) parts.add('Temp: $temperature°F');
    if (spo2.trim().isNotEmpty) parts.add('SpO2: $spo2%');
    if (weightKg.trim().isNotEmpty) parts.add('Wt: $weightKg kg');
    if (bmi.trim().isNotEmpty) parts.add('BMI: $bmi');
    if (bloodSugar.trim().isNotEmpty) parts.add('Sugar: $bloodSugar');
    return parts.join(' • ');
  }

  Map<String, dynamic> toJson() => {
    'bloodPressure': bloodPressure,
    'pulse': pulse,
    'temperature': temperature,
    'spo2': spo2,
    'respiratoryRate': respiratoryRate,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'bmi': bmi,
    'bloodSugar': bloodSugar,
  };

  factory VitalSigns.fromClinicalExam(ClinicalExamVitals exam) => VitalSigns(
    bloodPressure: exam.bloodPressure,
    pulse: exam.pulse,
    temperature: exam.temperature,
    spo2: exam.spo2,
    respiratoryRate: exam.respiratoryRate,
    weightKg: exam.weightKg,
    heightCm: exam.heightCm,
    bmi:
        exam.bmi.isNotEmpty
            ? exam.bmi
            : VitalSigns.calculateBmi(exam.weightKg, exam.heightCm),
  );

  Map<String, dynamic> toMap() => toJson();

  factory VitalSigns.fromMap(Map<String, dynamic> map) =>
      VitalSigns.fromJson(map);

  String get summary =>
      summaryLine.isEmpty ? 'No vitals recorded' : summaryLine;

  factory VitalSigns.fromJson(Map<String, dynamic> json) => VitalSigns(
    bloodPressure: json['bloodPressure'] as String? ?? '',
    pulse: json['pulse'] as String? ?? '',
    temperature: json['temperature'] as String? ?? '',
    spo2: json['spo2'] as String? ?? '',
    respiratoryRate: json['respiratoryRate'] as String? ?? '',
    weightKg: json['weightKg'] as String? ?? '',
    heightCm: json['heightCm'] as String? ?? '',
    bmi: json['bmi'] as String? ?? '',
    bloodSugar: json['bloodSugar'] as String? ?? '',
  );

  VitalSigns copyWith({
    String? bloodPressure,
    String? pulse,
    String? temperature,
    String? spo2,
    String? respiratoryRate,
    String? weightKg,
    String? heightCm,
    String? bmi,
    String? bloodSugar,
  }) {
    return VitalSigns(
      bloodPressure: bloodPressure ?? this.bloodPressure,
      pulse: pulse ?? this.pulse,
      temperature: temperature ?? this.temperature,
      spo2: spo2 ?? this.spo2,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      bmi: bmi ?? this.bmi,
      bloodSugar: bloodSugar ?? this.bloodSugar,
    );
  }
}

/// Universal SOAP (Subjective, Objective, Assessment, Plan) Clinical Note data model.
class SoapNoteData {
  final String? id;
  final String patientId;
  final DateTime recordDate;

  // ── S: SUBJECTIVE ──────────────────────────────────────────
  final String chiefComplaint;
  final String symptomDuration;
  final String hpi; // History of present illness / narrative

  // ── O: OBJECTIVE ───────────────────────────────────────────
  final VitalSigns vitals;
  final String physicalExamFindings;

  // ── A: ASSESSMENT ──────────────────────────────────────────
  final String workingDiagnosis;
  final String differentialDiagnosis;
  final String comorbidities;
  final String clinicalRemarks;

  // ── P: PLAN ────────────────────────────────────────────────
  final String prescriptionNotes;
  final String investigationsOrdered;
  final String adviceLifestyle;
  final DateTime? nextFollowUpDate;

  const SoapNoteData({
    this.id,
    required this.patientId,
    required this.recordDate,
    this.chiefComplaint = '',
    this.symptomDuration = '',
    this.hpi = '',
    this.vitals = const VitalSigns(),
    this.physicalExamFindings = '',
    this.workingDiagnosis = '',
    this.differentialDiagnosis = '',
    this.comorbidities = '',
    this.clinicalRemarks = '',
    this.prescriptionNotes = '',
    this.investigationsOrdered = '',
    this.adviceLifestyle = '',
    this.nextFollowUpDate,
  });

  /// Convert a SOAP note into a MasterCaseRecordData object for unified storage
  /// in the existing SQLite `patient_case_records` table without schema migration.
  MasterCaseRecordData toMasterCaseRecord() {
    final complaintList = <ChiefComplaintDetail>[];
    if (chiefComplaint.trim().isNotEmpty) {
      complaintList.add(
        ChiefComplaintDetail(
          complaint: chiefComplaint.trim(),
          duration: symptomDuration.trim(),
        ),
      );
    }

    return MasterCaseRecordData(
      id: id,
      patientId: patientId,
      recordDate: recordDate,
      chiefComplaints: complaintList,
      hpi: HpiDetails(chronologicalDevelopment: hpi),
      clinicalExam: ClinicalExamVitals(
        bloodPressure: vitals.bloodPressure,
        pulse: vitals.pulse,
        temperature: vitals.temperature,
        spo2: vitals.spo2,
        respiratoryRate: vitals.respiratoryRate,
        weightKg: vitals.weightKg,
        heightCm: vitals.heightCm,
        bmi: vitals.bmi,
        otherExaminationFindings: physicalExamFindings,
      ),
      clinicalAssessment: ClinicalAssessmentDetails(
        provisionalDiagnosis: workingDiagnosis,
        finalWorkingDiagnosis: workingDiagnosis,
        differentialDiagnosis: differentialDiagnosis,
        comorbidities: comorbidities,
        clinicalRemarks: clinicalRemarks,
      ),
      baselinePrescription: PrescriptionPlanDetails(
        prescriptionNotes: prescriptionNotes,
        dietRegimenAdvice: adviceLifestyle,
      ),
      investigations: InvestigationsPlanDetails(
        investigationName: investigationsOrdered,
      ),
      followUpDetails: FollowUpDetails(
        nextFollowUp: nextFollowUpDate?.toIso8601String() ?? '',
      ),
      followUpNotes: adviceLifestyle,
    );
  }

  /// Reconstruct a SoapNoteData representation from an existing MasterCaseRecordData.
  factory SoapNoteData.fromMasterCaseRecord(MasterCaseRecordData record) {
    String cc = '';
    String dur = '';
    if (record.chiefComplaints.isNotEmpty) {
      cc = record.chiefComplaints.first.complaint;
      dur = record.chiefComplaints.first.duration;
    }

    final exam = record.clinicalExam;
    final vitals = VitalSigns(
      bloodPressure: exam.bloodPressure,
      pulse: exam.pulse,
      temperature: exam.temperature,
      spo2: exam.spo2,
      respiratoryRate: exam.respiratoryRate,
      weightKg: exam.weightKg,
      heightCm: exam.heightCm,
      bmi:
          exam.bmi.isNotEmpty
              ? exam.bmi
              : VitalSigns.calculateBmi(exam.weightKg, exam.heightCm),
    );

    final assess = record.clinicalAssessment;
    final workingDiag =
        assess.finalWorkingDiagnosis.isNotEmpty
            ? assess.finalWorkingDiagnosis
            : assess.provisionalDiagnosis;

    DateTime? followUp;
    if (record.followUpDetails.nextFollowUp.isNotEmpty) {
      followUp = DateTime.tryParse(record.followUpDetails.nextFollowUp);
    }

    return SoapNoteData(
      id: record.id,
      patientId: record.patientId,
      recordDate: record.recordDate,
      chiefComplaint: cc,
      symptomDuration: dur,
      hpi: record.hpi.chronologicalDevelopment,
      vitals: vitals,
      physicalExamFindings: exam.otherExaminationFindings,
      workingDiagnosis: workingDiag,
      differentialDiagnosis: assess.differentialDiagnosis,
      comorbidities: assess.comorbidities,
      clinicalRemarks: assess.clinicalRemarks,
      prescriptionNotes:
          record.baselinePrescription.prescriptionNotes.isNotEmpty
              ? record.baselinePrescription.prescriptionNotes
              : record.baselinePrescription.remedyName,
      investigationsOrdered: record.investigations.investigationName,
      adviceLifestyle:
          record.baselinePrescription.dietRegimenAdvice.isNotEmpty
              ? record.baselinePrescription.dietRegimenAdvice
              : record.followUpNotes,
      nextFollowUpDate: followUp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'recordDate': recordDate.toIso8601String(),
    'chiefComplaint': chiefComplaint,
    'symptomDuration': symptomDuration,
    'hpi': hpi,
    'vitals': vitals.toJson(),
    'physicalExamFindings': physicalExamFindings,
    'workingDiagnosis': workingDiagnosis,
    'differentialDiagnosis': differentialDiagnosis,
    'comorbidities': comorbidities,
    'clinicalRemarks': clinicalRemarks,
    'prescriptionNotes': prescriptionNotes,
    'investigationsOrdered': investigationsOrdered,
    'adviceLifestyle': adviceLifestyle,
    'nextFollowUpDate': nextFollowUpDate?.toIso8601String(),
  };

  factory SoapNoteData.fromJson(Map<String, dynamic> json) => SoapNoteData(
    id: json['id'] as String?,
    patientId: json['patientId'] as String? ?? '',
    recordDate:
        DateTime.tryParse(json['recordDate'] as String? ?? '') ??
        DateTime.now(),
    chiefComplaint: json['chiefComplaint'] as String? ?? '',
    symptomDuration: json['symptomDuration'] as String? ?? '',
    hpi: json['hpi'] as String? ?? '',
    vitals:
        json['vitals'] != null
            ? VitalSigns.fromJson(json['vitals'] as Map<String, dynamic>)
            : const VitalSigns(),
    physicalExamFindings: json['physicalExamFindings'] as String? ?? '',
    workingDiagnosis: json['workingDiagnosis'] as String? ?? '',
    differentialDiagnosis: json['differentialDiagnosis'] as String? ?? '',
    comorbidities: json['comorbidities'] as String? ?? '',
    clinicalRemarks: json['clinicalRemarks'] as String? ?? '',
    prescriptionNotes: json['prescriptionNotes'] as String? ?? '',
    investigationsOrdered: json['investigationsOrdered'] as String? ?? '',
    adviceLifestyle: json['adviceLifestyle'] as String? ?? '',
    nextFollowUpDate:
        json['nextFollowUpDate'] != null
            ? DateTime.tryParse(json['nextFollowUpDate'] as String)
            : null,
  );
}
