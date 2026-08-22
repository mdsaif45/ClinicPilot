import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/picker_field.dart';
import '../models/case_record_models.dart';
import '../providers/case_record_provider.dart';

class _ComplaintEntry {
  final TextEditingController complaint = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController sensation = TextEditingController();
  final TextEditingController agg = TextEditingController();
  final TextEditingController amel = TextEditingController();
  final TextEditingController concomitant = TextEditingController();
  final TextEditingController duration = TextEditingController();
  final TextEditingController causation = TextEditingController();
  String severity = 'Moderate';

  void dispose() {
    complaint.dispose();
    location.dispose();
    sensation.dispose();
    agg.dispose();
    amel.dispose();
    concomitant.dispose();
    duration.dispose();
    causation.dispose();
  }
}

class MasterCaseTakingScreen extends ConsumerStatefulWidget {
  final Patient patient;

  const MasterCaseTakingScreen({super.key, required this.patient});

  @override
  ConsumerState<MasterCaseTakingScreen> createState() => _MasterCaseTakingScreenState();
}

class _MasterCaseTakingScreenState extends ConsumerState<MasterCaseTakingScreen> {
  bool _initialized = false;
  bool _saving = false;

  // Section 1: Patient Identification
  final _regNoController = TextEditingController();
  final _firstVisitDateController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _maritalStatus = 'Married';

  // Section 2: Chief Complaints (Dynamic List)
  final List<_ComplaintEntry> _complaints = [_ComplaintEntry()];

  // Section 3: History of Present Illness (HPI)
  final _hpiProgressionController = TextEditingController();
  final _hpiFirstOccurrenceController = TextEditingController();
  final _hpiPrevTreatmentsController = TextEditingController();
  final _hpiPrecipitatingFactorsController = TextEditingController();

  // Section 4: Past Medical History
  final _pastChildhoodController = TextEditingController();
  final _pastChronicController = TextEditingController();
  final _pastSurgeriesController = TextEditingController();
  final _pastInjuriesController = TextEditingController();
  final _pastAllergiesController = TextEditingController();
  final _pastPrevTreatmentsController = TextEditingController();

  // Section 5: Family Medical History
  final _familyFatherController = TextEditingController();
  final _familyMotherController = TextEditingController();
  final _familySiblingsController = TextEditingController();
  final _familyHereditaryController = TextEditingController();
  final _familyPsychiatricController = TextEditingController();

  // Section 6: Intrauterine & Developmental History
  final _devMaternalHealthController = TextEditingController();
  final _devDeliveryComplicationsController = TextEditingController();
  final _devMilestonesController = TextEditingController();
  final _devVaccinationController = TextEditingController();

  // Section 7: Physical Generals
  String _thermal = 'Ambithermal';
  final _weatherPrefController = TextEditingController();
  final _thirstController = TextEditingController();
  final _appetiteController = TextEditingController();
  final _cravingsController = TextEditingController();
  final _aversionsController = TextEditingController();
  final _intolerancesController = TextEditingController();
  final _stoolController = TextEditingController();
  final _urineController = TextEditingController();
  final _sweatController = TextEditingController();
  final _sleepController = TextEditingController();
  final _dreamsController = TextEditingController();
  final _energyFatigueController = TextEditingController();
  final _skinHairNailsController = TextEditingController();

  // Section 8: Mental Generals
  final _mindDispositionController = TextEditingController();
  final _angerIrritabilityController = TextEditingController();
  final _anxietyFearsController = TextEditingController();
  final _sadnessGriefController = TextEditingController();
  final _companySolitudeController = TextEditingController();
  final _consolationReactionController = TextEditingController();
  final _memoryConcentrationController = TextEditingController();
  final _stressResponseController = TextEditingController();

  // Section 9: Personal & Lifestyle History
  final _lifestyleDietController = TextEditingController();
  final _lifestyleHabitsController = TextEditingController();
  final _lifestyleActivityController = TextEditingController();
  final _lifestyleOccupationalHazardsController = TextEditingController();
  final _lifestyleSocialStressorsController = TextEditingController();

  // Section 10: Clinical Exam & Vitals
  final _examAppearanceController = TextEditingController();
  final _examPallorIcterusController = TextEditingController();
  final _bpController = TextEditingController();
  final _pulseController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _tongueController = TextEditingController();
  final _systemicExamController = TextEditingController();

  // Section 11: Miasmatic Analysis
  String _dominantMiasm = 'Mixed / Dynamic';
  final _miasmPsoricController = TextEditingController();
  final _miasmSycoticController = TextEditingController();
  final _miasmSyphiliticController = TextEditingController();
  final _miasmTubercularController = TextEditingController();
  final _miasmCancerinicController = TextEditingController();
  final _miasmCharacteristicController = TextEditingController();

  // Section 12: Case Totality & Repertory
  final _totalityController = TextEditingController();
  final _rubricsController = TextEditingController();
  final _repertorialResultController = TextEditingController();
  final _differentialRemediesController = TextEditingController();
  final _selectedRemedyController = TextEditingController();
  final _potencyJustificationController = TextEditingController();

  // Section 13: Prescription Plan
  final _rxRemedyController = TextEditingController();
  final _rxPotencyController = TextEditingController();
  final _rxDosageFormController = TextEditingController();
  final _rxDoseCountController = TextEditingController();
  final _rxFrequencyController = TextEditingController();
  final _rxDurationController = TextEditingController();
  final _rxInstructionsController = TextEditingController();
  final _rxDietaryAdviceController = TextEditingController();
  final _rxReferralAdviceController = TextEditingController();

  // Section 14: Investigations
  final _invTestsAdvisedController = TextEditingController();
  final _invResultsInterpretationController = TextEditingController();

  // Section 15: Follow-up Notes
  final _followUpNotesController = TextEditingController();

  // Section 16: Outcome
  String _outcome = 'Under Active Treatment';

  @override
  void initState() {
    super.initState();
    _initDefaultPatientFields();
  }

  void _initDefaultPatientFields() {
    _regNoController.text = widget.patient.serialNo.isNotEmpty ? widget.patient.serialNo : widget.patient.patientCode;
    _firstVisitDateController.text = '${widget.patient.createdAt.day}/${widget.patient.createdAt.month}/${widget.patient.createdAt.year}';
    _patientNameController.text = widget.patient.name;
    _ageController.text = widget.patient.age.toString();
    _genderController.text = widget.patient.gender;
    _occupationController.text = widget.patient.occupation ?? '';
    _addressController.text = widget.patient.address ?? (widget.patient.area ?? '');
    _phoneController.text = widget.patient.phone;
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _firstVisitDateController.dispose();
    _patientNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _phoneController.dispose();

    for (final c in _complaints) {
      c.dispose();
    }

    _hpiProgressionController.dispose();
    _hpiFirstOccurrenceController.dispose();
    _hpiPrevTreatmentsController.dispose();
    _hpiPrecipitatingFactorsController.dispose();

    _pastChildhoodController.dispose();
    _pastChronicController.dispose();
    _pastSurgeriesController.dispose();
    _pastInjuriesController.dispose();
    _pastAllergiesController.dispose();
    _pastPrevTreatmentsController.dispose();

    _familyFatherController.dispose();
    _familyMotherController.dispose();
    _familySiblingsController.dispose();
    _familyHereditaryController.dispose();
    _familyPsychiatricController.dispose();

    _devMaternalHealthController.dispose();
    _devDeliveryComplicationsController.dispose();
    _devMilestonesController.dispose();
    _devVaccinationController.dispose();

    _weatherPrefController.dispose();
    _thirstController.dispose();
    _appetiteController.dispose();
    _cravingsController.dispose();
    _aversionsController.dispose();
    _intolerancesController.dispose();
    _stoolController.dispose();
    _urineController.dispose();
    _sweatController.dispose();
    _sleepController.dispose();
    _dreamsController.dispose();
    _energyFatigueController.dispose();
    _skinHairNailsController.dispose();

    _mindDispositionController.dispose();
    _angerIrritabilityController.dispose();
    _anxietyFearsController.dispose();
    _sadnessGriefController.dispose();
    _companySolitudeController.dispose();
    _consolationReactionController.dispose();
    _memoryConcentrationController.dispose();
    _stressResponseController.dispose();

    _lifestyleDietController.dispose();
    _lifestyleHabitsController.dispose();
    _lifestyleActivityController.dispose();
    _lifestyleOccupationalHazardsController.dispose();
    _lifestyleSocialStressorsController.dispose();

    _examAppearanceController.dispose();
    _examPallorIcterusController.dispose();
    _bpController.dispose();
    _pulseController.dispose();
    _respiratoryRateController.dispose();
    _temperatureController.dispose();
    _spo2Controller.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bmiController.dispose();
    _tongueController.dispose();
    _systemicExamController.dispose();

    _miasmPsoricController.dispose();
    _miasmSycoticController.dispose();
    _miasmSyphiliticController.dispose();
    _miasmTubercularController.dispose();
    _miasmCancerinicController.dispose();
    _miasmCharacteristicController.dispose();

    _totalityController.dispose();
    _rubricsController.dispose();
    _repertorialResultController.dispose();
    _differentialRemediesController.dispose();
    _selectedRemedyController.dispose();
    _potencyJustificationController.dispose();

    _rxRemedyController.dispose();
    _rxPotencyController.dispose();
    _rxDosageFormController.dispose();
    _rxDoseCountController.dispose();
    _rxFrequencyController.dispose();
    _rxDurationController.dispose();
    _rxInstructionsController.dispose();
    _rxDietaryAdviceController.dispose();
    _rxReferralAdviceController.dispose();

    _invTestsAdvisedController.dispose();
    _invResultsInterpretationController.dispose();

    _followUpNotesController.dispose();
    super.dispose();
  }

  void _populateFromExisting(MasterCaseRecordData record) {
    if (_initialized) return;
    _initialized = true;

    // Identification
    if (record.identification.regNo.isNotEmpty) _regNoController.text = record.identification.regNo;
    if (record.identification.firstVisitDate.isNotEmpty) _firstVisitDateController.text = record.identification.firstVisitDate;
    if (record.identification.patientName.isNotEmpty) _patientNameController.text = record.identification.patientName;
    if (record.identification.age.isNotEmpty) _ageController.text = record.identification.age;
    if (record.identification.gender.isNotEmpty) _genderController.text = record.identification.gender;
    if (record.identification.dob.isNotEmpty) _dobController.text = record.identification.dob;
    if (record.identification.occupation.isNotEmpty) _occupationController.text = record.identification.occupation;
    if (record.identification.address.isNotEmpty) _addressController.text = record.identification.address;
    if (record.identification.phone.isNotEmpty) _phoneController.text = record.identification.phone;
    if (record.identification.maritalStatus.isNotEmpty) _maritalStatus = record.identification.maritalStatus;

    // Complaints
    if (record.chiefComplaints.isNotEmpty) {
      _complaints.clear();
      for (final c in record.chiefComplaints) {
        final entry = _ComplaintEntry();
        entry.complaint.text = c.complaint;
        entry.location.text = c.location;
        entry.sensation.text = c.sensation;
        entry.agg.text = c.modalitiesAgg;
        entry.amel.text = c.modalitiesAmel;
        entry.concomitant.text = c.concomitants;
        entry.duration.text = c.duration;
        entry.causation.text = c.causation;
        entry.severity = c.severity.isNotEmpty ? c.severity : 'Moderate';
        _complaints.add(entry);
      }
    }
    if (_complaints.isEmpty) _complaints.add(_ComplaintEntry());

    // HPI
    _hpiProgressionController.text = record.hpi.progression;
    _hpiFirstOccurrenceController.text = record.hpi.firstOccurrence;
    _hpiPrevTreatmentsController.text = record.hpi.previousTreatments;
    _hpiPrecipitatingFactorsController.text = record.hpi.precipitatingFactors;

    // Past History
    _pastChildhoodController.text = record.pastHistory.childhoodIllnesses;
    _pastChronicController.text = record.pastHistory.chronicDiseases;
    _pastSurgeriesController.text = record.pastHistory.surgeries;
    _pastInjuriesController.text = record.pastHistory.injuriesTrauma;
    _pastAllergiesController.text = record.pastHistory.allergies;
    _pastPrevTreatmentsController.text = record.pastHistory.previousTreatments;

    // Family History
    _familyFatherController.text = record.familyHistory.father;
    _familyMotherController.text = record.familyHistory.mother;
    _familySiblingsController.text = record.familyHistory.siblingsChildren;
    _familyHereditaryController.text = record.familyHistory.hereditaryDiseases;
    _familyPsychiatricController.text = record.familyHistory.psychiatricHistory;

    // Dev History
    _devMaternalHealthController.text = record.developmentalHistory.maternalHealth;
    _devDeliveryComplicationsController.text = record.developmentalHistory.deliveryComplications;
    _devMilestonesController.text = record.developmentalHistory.milestonesDentition;
    _devVaccinationController.text = record.developmentalHistory.vaccinationNeonatal;

    // Physical Generals
    _thermal = record.physicalGenerals.thermal;
    _weatherPrefController.text = record.physicalGenerals.weatherPreference;
    _thirstController.text = record.physicalGenerals.thirst;
    _appetiteController.text = record.physicalGenerals.appetite;
    _cravingsController.text = record.physicalGenerals.cravings;
    _aversionsController.text = record.physicalGenerals.aversions;
    _intolerancesController.text = record.physicalGenerals.intolerances;
    _stoolController.text = record.physicalGenerals.stool;
    _urineController.text = record.physicalGenerals.urine;
    _sweatController.text = record.physicalGenerals.perspiration;
    _sleepController.text = record.physicalGenerals.sleep;
    _dreamsController.text = record.physicalGenerals.dreams;
    _energyFatigueController.text = record.physicalGenerals.energyFatigue;
    _skinHairNailsController.text = record.physicalGenerals.skinHairNails;

    // Mental Generals
    _mindDispositionController.text = record.mentalGenerals.disposition;
    _angerIrritabilityController.text = record.mentalGenerals.irritabilityAnger;
    _anxietyFearsController.text = record.mentalGenerals.anxietyFears;
    _sadnessGriefController.text = record.mentalGenerals.sadnessGrief;
    _companySolitudeController.text = record.mentalGenerals.companySolitude;
    _consolationReactionController.text = record.mentalGenerals.consolationReaction;
    _memoryConcentrationController.text = record.mentalGenerals.memoryConcentration;
    _stressResponseController.text = record.mentalGenerals.stressResponse;

    // Lifestyle
    _lifestyleDietController.text = record.lifestyleHabits.dietaryHabits;
    _lifestyleHabitsController.text = record.lifestyleHabits.habitsAddictions;
    _lifestyleActivityController.text = record.lifestyleHabits.physicalActivity;
    _lifestyleOccupationalHazardsController.text = record.lifestyleHabits.occupationalHazards;
    _lifestyleSocialStressorsController.text = record.lifestyleHabits.socialStressors;

    // Clinical Exam
    _examAppearanceController.text = record.clinicalExam.generalAppearance;
    _examPallorIcterusController.text = record.clinicalExam.pallorIcterus;
    _bpController.text = record.clinicalExam.bp;
    _pulseController.text = record.clinicalExam.pulse;
    _respiratoryRateController.text = record.clinicalExam.respiratoryRate;
    _temperatureController.text = record.clinicalExam.temperature;
    _spo2Controller.text = record.clinicalExam.spo2;
    _weightController.text = record.clinicalExam.weightKg;
    _heightController.text = record.clinicalExam.heightCm;
    _bmiController.text = record.clinicalExam.bmi;
    _tongueController.text = record.clinicalExam.tongueExam;
    _systemicExamController.text = record.clinicalExam.systemicFindings;

    // Miasmatic Analysis
    _dominantMiasm = record.miasmaticAnalysis.dominantMiasm;
    _miasmPsoricController.text = record.miasmaticAnalysis.psoricFeatures;
    _miasmSycoticController.text = record.miasmaticAnalysis.sycoticFeatures;
    _miasmSyphiliticController.text = record.miasmaticAnalysis.syphiliticFeatures;
    _miasmTubercularController.text = record.miasmaticAnalysis.tubercularFeatures;
    _miasmCancerinicController.text = record.miasmaticAnalysis.cancerinicFeatures;
    _miasmCharacteristicController.text = record.miasmaticAnalysis.characteristicSymptoms;

    // Case Totality
    _totalityController.text = record.caseTotality.characteristicSymptoms;
    _rubricsController.text = record.caseTotality.rubricsSelected;
    _repertorialResultController.text = record.caseTotality.repertorialResult;
    _differentialRemediesController.text = record.caseTotality.differentialRemedies;
    _selectedRemedyController.text = record.caseTotality.selectedRemedy;
    _potencyJustificationController.text = record.caseTotality.justification;

    // Prescription
    _rxRemedyController.text = record.baselinePrescription.remedyName;
    _rxPotencyController.text = record.baselinePrescription.potency;
    _rxDosageFormController.text = record.baselinePrescription.dosageForm;
    _rxDoseCountController.text = record.baselinePrescription.doseCount;
    _rxFrequencyController.text = record.baselinePrescription.frequency;
    _rxDurationController.text = record.baselinePrescription.duration;
    _rxInstructionsController.text = record.baselinePrescription.instructions;
    _rxDietaryAdviceController.text = record.baselinePrescription.dietaryAdvice;
    _rxReferralAdviceController.text = record.baselinePrescription.referralAdvice;

    // Investigations
    _invTestsAdvisedController.text = record.investigations.testsAdvised;
    _invResultsInterpretationController.text = record.investigations.resultsInterpretation;

    // Follow-up Notes & Outcome
    _followUpNotesController.text = record.followUpNotes;
    _outcome = record.outcome;
  }

  void _addComplaintBlock() {
    setState(() {
      _complaints.add(_ComplaintEntry());
    });
    AppHaptics.light();
  }

  void _removeComplaintBlock(int index) {
    if (_complaints.length <= 1) return;
    setState(() {
      final removed = _complaints.removeAt(index);
      removed.dispose();
    });
    AppHaptics.selection();
  }

  Future<void> _saveRecord() async {
    setState(() => _saving = true);

    final complaintsList = _complaints.map((c) => ChiefComplaintDetail(
          complaint: c.complaint.text.trim(),
          location: c.location.text.trim(),
          sensation: c.sensation.text.trim(),
          modalitiesAgg: c.agg.text.trim(),
          modalitiesAmel: c.amel.text.trim(),
          concomitants: c.concomitant.text.trim(),
          duration: c.duration.text.trim(),
          causation: c.causation.text.trim(),
          severity: c.severity,
        )).toList();

    final record = MasterCaseRecordData(
      patientId: widget.patient.id,
      recordDate: DateTime.now(),
      identification: PatientIdentificationDetails(
        regNo: _regNoController.text.trim(),
        firstVisitDate: _firstVisitDateController.text.trim(),
        patientName: _patientNameController.text.trim(),
        age: _ageController.text.trim(),
        gender: _genderController.text.trim(),
        dob: _dobController.text.trim(),
        occupation: _occupationController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        maritalStatus: _maritalStatus,
      ),
      chiefComplaints: complaintsList,
      hpi: HpiDetails(
        progression: _hpiProgressionController.text.trim(),
        firstOccurrence: _hpiFirstOccurrenceController.text.trim(),
        previousTreatments: _hpiPrevTreatmentsController.text.trim(),
        precipitatingFactors: _hpiPrecipitatingFactorsController.text.trim(),
      ),
      pastHistory: PastHistoryDetails(
        childhoodIllnesses: _pastChildhoodController.text.trim(),
        chronicDiseases: _pastChronicController.text.trim(),
        surgeries: _pastSurgeriesController.text.trim(),
        injuriesTrauma: _pastInjuriesController.text.trim(),
        allergies: _pastAllergiesController.text.trim(),
        previousTreatments: _pastPrevTreatmentsController.text.trim(),
      ),
      familyHistory: FamilyHistoryDetails(
        father: _familyFatherController.text.trim(),
        mother: _familyMotherController.text.trim(),
        siblingsChildren: _familySiblingsController.text.trim(),
        hereditaryDiseases: _familyHereditaryController.text.trim(),
        psychiatricHistory: _familyPsychiatricController.text.trim(),
      ),
      developmentalHistory: DevelopmentalHistoryDetails(
        maternalHealth: _devMaternalHealthController.text.trim(),
        deliveryComplications: _devDeliveryComplicationsController.text.trim(),
        milestonesDentition: _devMilestonesController.text.trim(),
        vaccinationNeonatal: _devVaccinationController.text.trim(),
      ),
      physicalGenerals: PhysicalGenerals(
        thermal: _thermal,
        weatherPreference: _weatherPrefController.text.trim(),
        thirst: _thirstController.text.trim(),
        appetite: _appetiteController.text.trim(),
        cravings: _cravingsController.text.trim(),
        aversions: _aversionsController.text.trim(),
        intolerances: _intolerancesController.text.trim(),
        stool: _stoolController.text.trim(),
        urine: _urineController.text.trim(),
        perspiration: _sweatController.text.trim(),
        sleep: _sleepController.text.trim(),
        dreams: _dreamsController.text.trim(),
        energyFatigue: _energyFatigueController.text.trim(),
        skinHairNails: _skinHairNailsController.text.trim(),
      ),
      mentalGenerals: MentalGenerals(
        disposition: _mindDispositionController.text.trim(),
        irritabilityAnger: _angerIrritabilityController.text.trim(),
        anxietyFears: _anxietyFearsController.text.trim(),
        sadnessGrief: _sadnessGriefController.text.trim(),
        companySolitude: _companySolitudeController.text.trim(),
        consolationReaction: _consolationReactionController.text.trim(),
        memoryConcentration: _memoryConcentrationController.text.trim(),
        stressResponse: _stressResponseController.text.trim(),
      ),
      lifestyleHabits: LifestyleHistoryDetails(
        dietaryHabits: _lifestyleDietController.text.trim(),
        habitsAddictions: _lifestyleHabitsController.text.trim(),
        physicalActivity: _lifestyleActivityController.text.trim(),
        occupationalHazards: _lifestyleOccupationalHazardsController.text.trim(),
        socialStressors: _lifestyleSocialStressorsController.text.trim(),
      ),
      clinicalExam: ClinicalExamVitals(
        generalAppearance: _examAppearanceController.text.trim(),
        pallorIcterus: _examPallorIcterusController.text.trim(),
        bp: _bpController.text.trim(),
        pulse: _pulseController.text.trim(),
        respiratoryRate: _respiratoryRateController.text.trim(),
        temperature: _temperatureController.text.trim(),
        spo2: _spo2Controller.text.trim(),
        weightKg: _weightController.text.trim(),
        heightCm: _heightController.text.trim(),
        bmi: _bmiController.text.trim(),
        tongueExam: _tongueController.text.trim(),
        systemicFindings: _systemicExamController.text.trim(),
      ),
      miasmaticAnalysis: MiasmaticAnalysis(
        psoricFeatures: _miasmPsoricController.text.trim(),
        sycoticFeatures: _miasmSycoticController.text.trim(),
        syphiliticFeatures: _miasmSyphiliticController.text.trim(),
        tubercularFeatures: _miasmTubercularController.text.trim(),
        cancerinicFeatures: _miasmCancerinicController.text.trim(),
        characteristicSymptoms: _miasmCharacteristicController.text.trim(),
        dominantMiasm: _dominantMiasm,
      ),
      caseTotality: CaseTotality(
        characteristicSymptoms: _totalityController.text.trim(),
        rubricsSelected: _rubricsController.text.trim(),
        repertorialResult: _repertorialResultController.text.trim(),
        differentialRemedies: _differentialRemediesController.text.trim(),
        selectedRemedy: _selectedRemedyController.text.trim(),
        justification: _potencyJustificationController.text.trim(),
      ),
      baselinePrescription: PrescriptionPlanDetails(
        remedyName: _rxRemedyController.text.trim(),
        potency: _rxPotencyController.text.trim(),
        dosageForm: _rxDosageFormController.text.trim(),
        doseCount: _rxDoseCountController.text.trim(),
        frequency: _rxFrequencyController.text.trim(),
        duration: _rxDurationController.text.trim(),
        instructions: _rxInstructionsController.text.trim(),
        dietaryAdvice: _rxDietaryAdviceController.text.trim(),
        referralAdvice: _rxReferralAdviceController.text.trim(),
      ),
      investigations: InvestigationsPlanDetails(
        testsAdvised: _invTestsAdvisedController.text.trim(),
        resultsInterpretation: _invResultsInterpretationController.text.trim(),
      ),
      followUpNotes: _followUpNotesController.text.trim(),
      outcome: _outcome,
    );

    try {
      await ref.read(caseRecordNotifierProvider.notifier).saveCaseRecord(record);
      AppHaptics.success();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Master Case Record saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving case: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseAsync = ref.watch(patientCaseRecordProvider(widget.patient.id));

    return caseAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (existingRecord) {
        if (existingRecord != null) {
          _populateFromExisting(existingRecord);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Clinical Case Taking • ${widget.patient.name}'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: FilledButton.icon(
                  onPressed: _saving ? null : _saveRecord,
                  icon: _saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Master Case'),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              // SECTION 1: PATIENT IDENTIFICATION
              _buildSectionCard(
                sectionNum: '01',
                title: 'Patient Identification',
                icon: Icons.badge_outlined,
                subtitle: 'Demographics, contact & registration details',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(_regNoController, 'Registration Number (e.g. 001)', Icons.numbers),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: _buildInput(_firstVisitDateController, 'Date of First Visit', Icons.calendar_today_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildInput(_patientNameController, 'Patient Full Name', Icons.person_outline)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ageController, 'Age', Icons.cake_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_genderController, 'Sex / Gender', Icons.wc_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_dobController, 'Date of Birth (Optional)', Icons.event_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_occupationController, 'Occupation (e.g. Tailor, Teacher)', Icons.work_outline)),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: PickerField<String>(
                          label: 'Marital Status',
                          value: _maritalStatus,
                          options: const [
                            PickerOption(value: 'Single', label: 'Single'),
                            PickerOption(value: 'Married', label: 'Married'),
                            PickerOption(value: 'Divorced', label: 'Divorced'),
                            PickerOption(value: 'Widowed', label: 'Widowed'),
                            PickerOption(value: 'Other', label: 'Other'),
                          ],
                          onChanged: (v) => setState(() => _maritalStatus = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildInput(_addressController, 'Address / Locality', Icons.home_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_phoneController, 'Phone / Contact Number', Icons.phone_outlined)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 2: CHIEF COMPLAINTS (DYNAMIC LIST)
              _buildSectionCard(
                sectionNum: '02',
                title: 'Chief Complaints (${_complaints.length} Relational Block${_complaints.length > 1 ? 's' : ''})',
                icon: Icons.healing_outlined,
                subtitle: 'Presenting complaints with location, sensation, modalities and severity',
                children: [
                  for (int i = 0; i < _complaints.length; i++) ...[
                    _buildComplaintCard(i),
                    if (i < _complaints.length - 1) const SizedBox(height: Spacing.md),
                  ],
                  const SizedBox(height: Spacing.md),
                  OutlinedButton.icon(
                    onPressed: _addComplaintBlock,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Another Complaint (+ Complaint Block)'),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 3: HPI
              _buildSectionCard(
                sectionNum: '03',
                title: 'History of Present Illness (HPI)',
                icon: Icons.history_edu_outlined,
                subtitle: 'Chronological progression, onset, prior treatments & precipitating factors',
                children: [
                  _buildInput(_hpiProgressionController, 'Chronological Progression / Development', Icons.timeline, 2),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_hpiFirstOccurrenceController, 'First Occurrence / Previous Episodes', Icons.event_repeat),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_hpiPrevTreatmentsController, 'Previous Treatments, Medications & Response', Icons.medication_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_hpiPrecipitatingFactorsController, 'Precipitating Factors / Causation', Icons.psychology_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 4: PAST MEDICAL HISTORY
              _buildSectionCard(
                sectionNum: '04',
                title: 'Past Medical History',
                icon: Icons.medical_services_outlined,
                subtitle: 'Childhood illnesses, surgeries, chronic ailments, allergies & treatments',
                children: [
                  _buildInput(_pastChildhoodController, 'Childhood Illnesses & Infections (Measles, Mumps, etc.)', Icons.child_care_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastChronicController, 'Chronic Diseases & Major Illnesses (Diabetes, HTN, etc.)', Icons.coronavirus_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastSurgeriesController, 'Operations & Surgeries (e.g. Abscess drainage, Cholecystectomy)', Icons.local_hospital_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastInjuriesController, 'Injuries, Trauma & Hospitalisation History', Icons.personal_injury_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastAllergiesController, 'Allergies & Drug Sensitivities', Icons.warning_amber_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastPrevTreatmentsController, 'Previous Homeopathic or Systemic Treatments', Icons.history),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 5: FAMILY MEDICAL HISTORY
              _buildSectionCard(
                sectionNum: '05',
                title: 'Family Medical History',
                icon: Icons.family_restroom_outlined,
                subtitle: 'Hereditary conditions, diabetes, hypertension, asthma, cancer, psychiatric history',
                children: [
                  _buildInput(_familyFatherController, "Father's Health History & Major Illnesses", Icons.man_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familyMotherController, "Mother's Health History & Major Illnesses", Icons.woman_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familySiblingsController, 'Siblings & Children Health History', Icons.people_outline),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familyHereditaryController, 'Hereditary & Familial Diseases (DM, HTN, Cancer, TB, Asthma)', Icons.hub_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familyPsychiatricController, 'Mental & Psychiatric History in Family', Icons.psychology_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 6: INTRAUTERINE & DEVELOPMENTAL HISTORY
              _buildSectionCard(
                sectionNum: '06',
                title: 'Intrauterine & Developmental History',
                icon: Icons.sentiment_satisfied_alt_outlined,
                subtitle: 'Maternal gestation, birth milestones, dentition, vaccination & neonatal history',
                children: [
                  _buildInput(_devMaternalHealthController, 'Maternal Health & Medications During Gestation', Icons.pregnant_woman_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_devDeliveryComplicationsController, 'Delivery Details (Term, Mode of Delivery, Birth Weight)', Icons.child_friendly_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_devMilestonesController, 'Developmental Milestones & Dentition', Icons.directions_walk_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_devVaccinationController, 'Vaccination History & Neonatal Complications', Icons.vaccines_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 7: PHYSICAL GENERALS
              _buildSectionCard(
                sectionNum: '07',
                title: 'Physical Generals',
                icon: Icons.accessibility_new_outlined,
                subtitle: 'Thermal state, thirst, appetite, cravings, aversions, stool, sweat & sleep',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PickerField<String>(
                          label: 'Thermal State',
                          value: _thermal,
                          options: const [
                            PickerOption(value: 'Hot', label: 'Hot (Warm Blooded)'),
                            PickerOption(value: 'Chilly', label: 'Chilly (Cold Blooded)'),
                            PickerOption(value: 'Ambithermal', label: 'Ambithermal (Neutral)'),
                          ],
                          onChanged: (v) => setState(() => _thermal = v),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: _buildInput(_weatherPrefController, 'Weather / Season Preference', Icons.wb_sunny_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_thirstController, 'Thirst (Quantity & Frequency)', Icons.water_drop_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_appetiteController, 'Appetite & Hunger Pattern', Icons.restaurant_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_cravingsController, 'Food Desires / Cravings (Sweets, Salt, Spicy, Meat, Fish, etc.)', Icons.fastfood_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_aversionsController, 'Food Aversions (Milk, Fatty food, Meat, Bread, etc.)', Icons.no_food_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_intolerancesController, 'Food Intolerances & Digestive Aggravations', Icons.warning_amber_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_stoolController, 'Stool & Bowel Habits', Icons.airline_seat_legroom_reduced_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_urineController, 'Urine & Bladder Symptoms', Icons.water_damage_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_sweatController, 'Perspiration / Sweat (Location, Odor, Staining)', Icons.waterfall_chart_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_sleepController, 'Sleep Routine & Quality', Icons.bedtime_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_dreamsController, 'Characteristic Dreams', Icons.cloud_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_energyFatigueController, 'Energy, Vitality & Fatigue Pattern', Icons.bolt_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_skinHairNailsController, 'Skin, Hair & Nails Examination', Icons.brush_outlined)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 8: MENTAL GENERALS
              _buildSectionCard(
                sectionNum: '08',
                title: 'Mental Generals & Disposition',
                icon: Icons.psychology_outlined,
                subtitle: 'Mind, disposition, anger, anxiety, fears, consolation & emotional totality',
                children: [
                  _buildInput(_mindDispositionController, 'Mind & General Disposition (Nature, Mood, Temperament)', Icons.person_search_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_angerIrritabilityController, 'Irritability & Anger Reaction (Triggers, Duration, Cool-off)', Icons.sentiment_very_dissatisfied_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_anxietyFearsController, 'Anxiety, Fears & Phobias (Disease, Death, Solitude, Future)', Icons.crisis_alert_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_sadnessGriefController, 'Sadness, Grief & Depression History', Icons.sentiment_dissatisfied_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_companySolitudeController, 'Company vs Solitude Preference', Icons.groups_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_consolationReactionController, 'Reaction to Consolation (Amel / Agg)', Icons.favorite_outline)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_memoryConcentrationController, 'Memory, Focus & Concentration Level', Icons.memory_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_stressResponseController, 'Stress Response & Mental Causation (Grief, Financial, Family)', Icons.electric_bolt_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 9: PERSONAL & LIFESTYLE HISTORY
              _buildSectionCard(
                sectionNum: '09',
                title: 'Personal & Lifestyle History',
                icon: Icons.self_improvement_outlined,
                subtitle: 'Diet, habits, physical activity, occupation, routine & social stressors',
                children: [
                  _buildInput(_lifestyleDietController, 'Dietary Habits & Meal Routine (Veg / Non-veg, Irregular meals)', Icons.restaurant_menu_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_lifestyleHabitsController, 'Habits & Addictions (Tea, Coffee, Tobacco, Alcohol)', Icons.smoking_rooms_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_lifestyleActivityController, 'Physical Activity & Exercise Routine', Icons.fitness_center_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_lifestyleOccupationalHazardsController, 'Daily Work Routine & Occupational Hazards', Icons.work_history_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_lifestyleSocialStressorsController, 'Social Environment & Life Stressors', Icons.account_tree_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 10: CLINICAL EXAMINATION & VITALS
              _buildSectionCard(
                sectionNum: '10',
                title: 'Clinical Examination & Vitals',
                icon: Icons.monitor_heart_outlined,
                subtitle: 'BP, Pulse, RR, Temp, SpO2, Weight, Height, BMI, Tongue & Systemic Findings',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput(_bpController, 'BP (e.g. 120/80 mmHg)', Icons.speed)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pulseController, 'Pulse (bpm)', Icons.favorite)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_respiratoryRateController, 'Respiratory Rate (RR)', Icons.air)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_temperatureController, 'Temperature (°F)', Icons.thermostat_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_spo2Controller, 'SpO2 (%)', Icons.bloodtype_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_weightController, 'Weight (kg)', Icons.scale_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_heightController, 'Height (cm)', Icons.height)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_bmiController, 'BMI', Icons.calculate_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_examAppearanceController, 'General Appearance & Build (Nutritional status, posture)', Icons.person_outline),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_examPallorIcterusController, 'Pallor, Icterus, Cyanosis, Clubbing, Oedema, Lymph Nodes', Icons.visibility_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_tongueController, 'Tongue & Oral Cavity Examination (Coating, Warts, Cracks)', Icons.sentiment_neutral_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_systemicExamController, 'Systemic Findings (Respiratory, CVS, Abdomen, CNS, Musculoskeletal)', Icons.health_and_safety_outlined, 2),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 11: MIASMATIC ANALYSIS
              _buildSectionCard(
                sectionNum: '11',
                title: 'Miasmatic Analysis',
                icon: Icons.biotech_outlined,
                subtitle: 'Psoric, Sycotic, Syphilitic, Tubercular, Cancerinic breakdown & Dominant Miasm',
                children: [
                  PickerField<String>(
                    label: 'Dominant Miasm',
                    value: _dominantMiasm,
                    options: const [
                      PickerOption(value: 'Psora', label: 'Psora (Functional / Sensational)'),
                      PickerOption(value: 'Sycosis', label: 'Sycosis (Overgrowth / Infiltration)'),
                      PickerOption(value: 'Syphilis', label: 'Syphilis (Destructive / Degenerative)'),
                      PickerOption(value: 'Tubercular', label: 'Tubercular (Suppressive / Respiratory)'),
                      PickerOption(value: 'Cancerinic', label: 'Cancerinic (Cellular Chaos)'),
                      PickerOption(value: 'Mixed / Dynamic', label: 'Mixed / Dynamic Miasm'),
                    ],
                    onChanged: (v) => setState(() => _dominantMiasm = v),
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_miasmPsoricController, 'Psoric Features (Functional, itching, hypersensitivity)', Icons.grain),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_miasmSycoticController, 'Sycotic Features (Warts, growths, joint stiffness < damp)', Icons.bubble_chart_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_miasmSyphiliticController, 'Syphilitic Features (Ulcerations, bone pains, destruction)', Icons.warning_amber_rounded),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_miasmTubercularController, 'Tubercular Features (Frequent colds, weight loss, restlessness)', Icons.air_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_miasmCancerinicController, 'Cancerinic Features (Family malignancy, deep suppression)', Icons.coronavirus_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_miasmCharacteristicController, 'Characteristic Symptoms Supporting Miasmatic Assessment', Icons.assignment_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 12: CASE TOTALITY & REPERTORY
              _buildSectionCard(
                sectionNum: '12',
                title: 'Case Totality, Repertory & Analysis',
                icon: Icons.auto_awesome_outlined,
                subtitle: 'Characteristic totality, selected rubrics, repertorial score & differential remedies',
                children: [
                  _buildInput(_totalityController, 'Totality of Symptoms (Generals + Characteristic Particulars)', Icons.summarize_outlined, 2),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_rubricsController, 'Selected Repertorial Rubrics (e.g. Extremities; pain; hip; right)', Icons.menu_book_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_repertorialResultController, 'Repertorial Results & Remedy Scores (e.g. Thuja 18/7, Rhus Tox 14/5)', Icons.assessment_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_differentialRemediesController, 'Differential Remedies Considered (Materia Medica correlation)', Icons.compare_arrows_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_selectedRemedyController, 'Selected Similimum Remedy', Icons.star_outline),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_potencyJustificationController, 'Potency & Dose Justification', Icons.info_outline),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 13: PRESCRIPTION PLAN
              _buildSectionCard(
                sectionNum: '13',
                title: 'Prescription Plan',
                icon: Icons.receipt_long_outlined,
                subtitle: 'Remedy, potency, dosage form, frequency, instructions, dietary advice & referrals',
                children: [
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildInput(_rxRemedyController, 'Remedy Name (e.g. Thuja Occidentalis)', Icons.medication_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxPotencyController, 'Potency (e.g. 200C, 30C, 1M)', Icons.numbers)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_rxDosageFormController, 'Dosage Form (e.g. Globules No. 30, Drops)', Icons.science_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxDoseCountController, 'Dose Count (e.g. 4 pills, 10 drops)', Icons.pin_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxFrequencyController, 'Frequency (e.g. OD, BD, TDS, HS, Stat)', Icons.schedule)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxDurationController, 'Duration (e.g. 3 Days, 15 Days)', Icons.timelapse)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_rxInstructionsController, 'Administration Instructions (e.g. Clean empty tongue in morning)', Icons.assignment_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_rxDietaryAdviceController, 'Dietary Restrictions & Regimen Advice (Avoid raw onion, garlic, perfume)', Icons.no_food_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_rxReferralAdviceController, 'Specialist Referral / Investigations Advised', Icons.share_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 14: INVESTIGATIONS
              _buildSectionCard(
                sectionNum: '14',
                title: 'Diagnostic Lab Orders & Investigations',
                icon: Icons.science_outlined,
                subtitle: 'Recommended tests, pathology indications, lab results & reference interpretations',
                children: [
                  _buildInput(_invTestsAdvisedController, 'Diagnostic Tests Advised (FBS, PPBS, HbA1c, Uric Acid, X-Ray)', Icons.checklist_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_invResultsInterpretationController, 'Laboratory Results & Clinical Interpretation', Icons.query_stats_outlined, 2),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 15: FOLLOW-UP LOG
              _buildSectionCard(
                sectionNum: '15',
                title: 'Follow-up Notes & Clinical Progression',
                icon: Icons.event_note_outlined,
                subtitle: 'Date-wise response, symptom changes, amelioration/aggravation & next visit schedule',
                children: [
                  _buildInput(_followUpNotesController, 'Date-wise Progress & Reaction to Treatment Notes', Icons.notes_outlined, 3),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // SECTION 16: OUTCOME
              _buildSectionCard(
                sectionNum: '16',
                title: 'Clinical Outcome & Case Status',
                icon: Icons.task_alt_outlined,
                subtitle: 'Overall outcome status and clinical disposition',
                children: [
                  PickerField<String>(
                    label: 'Clinical Case Outcome',
                    value: _outcome,
                    options: const [
                      PickerOption(value: 'Under Active Treatment', label: 'Under Active Treatment'),
                      PickerOption(value: 'Improved', label: 'Significantly Improved'),
                      PickerOption(value: 'Resolved', label: 'Completely Resolved'),
                      PickerOption(value: 'Stable', label: 'Stable / Maintained'),
                      PickerOption(value: 'Discontinued', label: 'Discontinued by Patient'),
                      PickerOption(value: 'Lost to Follow-up', label: 'Lost to Follow-up'),
                    ],
                    onChanged: (v) => setState(() => _outcome = v),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xxl),

              // Bottom Save Button
              FilledButton.icon(
                onPressed: _saving ? null : _saveRecord,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Save Master Case Record'),
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String sectionNum,
    required String title,
    required IconData icon,
    required String subtitle,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: Radii.pillAll,
                ),
                child: Text(
                  sectionNum,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          const Divider(),
          const SizedBox(height: Spacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildComplaintCard(int index) {
    final theme = Theme.of(context);
    final entry = _complaints[index];

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: Radii.mdAll,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Complaint #${index + 1}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (_complaints.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: theme.colorScheme.error,
                  tooltip: 'Remove this complaint',
                  onPressed: () => _removeComplaintBlock(index),
                ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _buildInput(entry.complaint, 'Complaint Description (e.g. Pain in right hip extending to knee)', Icons.healing),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.location, 'Location / Extension', Icons.place_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.sensation, 'Sensation / Character (Drawing, tearing, burning)', Icons.touch_app_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.agg, 'Aggravation (<)', Icons.arrow_upward_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.amel, 'Amelioration (>)', Icons.arrow_downward_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.concomitant, 'Concomitants / Associated Symptoms', Icons.alt_route_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.duration, 'Duration / Onset (e.g. 2 Years, Gradual)', Icons.timer_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.causation, 'Causation / Timing', Icons.alarm_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: PickerField<String>(
                  label: 'Severity Level',
                  value: entry.severity,
                  options: const [
                    PickerOption(value: 'Mild', label: 'Mild (1 - 3)'),
                    PickerOption(value: 'Moderate', label: 'Moderate (4 - 6)'),
                    PickerOption(value: 'Severe', label: 'Severe (7 - 9)'),
                    PickerOption(value: 'Intolerable', label: 'Intolerable (10/10)'),
                  ],
                  onChanged: (v) => setState(() => entry.severity = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, [IconData? icon, int maxLines = 1]) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: Radii.smAll),
        isDense: true,
      ),
    );
  }
}