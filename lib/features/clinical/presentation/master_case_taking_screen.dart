import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/picker_field.dart';
import '../models/case_record_models.dart';
import '../providers/case_record_provider.dart';

class _ComplaintEntry {
  final TextEditingController complaint = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController onset = TextEditingController();
  final TextEditingController duration = TextEditingController();
  final TextEditingController sensation = TextEditingController();
  final TextEditingController extensionRadiation = TextEditingController();
  final TextEditingController agg = TextEditingController();
  final TextEditingController amel = TextEditingController();
  final TextEditingController concomitant = TextEditingController();
  final TextEditingController causation = TextEditingController();
  final TextEditingController periodicity = TextEditingController();
  final TextEditingController time = TextEditingController();
  String severity = 'Moderate';
  final TextEditingController associatedSymptoms = TextEditingController();

  void dispose() {
    complaint.dispose();
    location.dispose();
    onset.dispose();
    duration.dispose();
    sensation.dispose();
    extensionRadiation.dispose();
    agg.dispose();
    amel.dispose();
    concomitant.dispose();
    causation.dispose();
    periodicity.dispose();
    time.dispose();
    associatedSymptoms.dispose();
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
  bool _isDirty = false;
  bool _isPopulating = false;
  
  // Default: keep 01 (index 0) expanded, collapse all other sections (1..18)
  final Set<int> _collapsedSections = {for (int i = 1; i < 19; i++) i};
  late final List<GlobalKey> _sectionKeys;

  static const List<String> _sectionTitles = [
    'Identification',
    'Chief Complaints',
    'Other Complaints',
    'HPI',
    'Past History',
    'Family History',
    'Developmental',
    'Physical Generals',
    'Mental Generals',
    'Lifestyle',
    'Vitals & Exam',
    'Miasmatic Analysis',
    'Case Totality',
    'Diagnosis',
    'Prescription',
    'Investigations',
    'Follow-Up',
    'Outcome',
    'Documentation',
  ];

  // 1. Patient Identification (10 fields)
  final _regNoController = TextEditingController();
  final _firstVisitDateController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController(text: 'Male');
  final _dobController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _maritalStatus = 'Married';

  // 2. Chief Complaints (Dynamic 1+ blocks)
  final List<_ComplaintEntry> _complaints = [_ComplaintEntry()];

  // 3. Additional Complaints (1 field)
  final _additionalComplaintsController = TextEditingController();

  // 4. History of Present Illness (HPI - 8 fields)
  final _hpiChronoDevController = TextEditingController();
  final _hpiFirstOccurrenceController = TextEditingController();
  final _hpiProgressionController = TextEditingController();
  final _hpiPreviousEpisodesController = TextEditingController();
  final _hpiPreviousTreatmentController = TextEditingController();
  final _hpiResponseToTreatmentController = TextEditingController();
  final _hpiPrecipitatingFactorsController = TextEditingController();
  final _hpiOtherRelevantHistoryController = TextEditingController();

  // 5. Past History (11 fields)
  final _pastChildhoodIllnessesController = TextEditingController();
  final _pastMajorIllnessesController = TextEditingController();
  final _pastChronicDiseasesController = TextEditingController();
  final _pastSurgeriesController = TextEditingController();
  final _pastInjuriesTraumaController = TextEditingController();
  final _pastHospitalisationsController = TextEditingController();
  final _pastInfectionsController = TextEditingController();
  final _pastAllergiesController = TextEditingController();
  final _pastPreviousMedicationsController = TextEditingController();
  final _pastPrevHomeopathicTreatmentController = TextEditingController();
  final _pastOtherPastHistoryController = TextEditingController();

  // 6. Family History (10 fields)
  final _familyFatherController = TextEditingController();
  final _familyMotherController = TextEditingController();
  final _familySiblingsController = TextEditingController();
  final _familySpouseController = TextEditingController();
  final _familyChildrenController = TextEditingController();
  final _familyGrandparentsRelativesController = TextEditingController();
  final _familyHereditaryDiseasesController = TextEditingController();
  final _familyMajorFamilialDiseasesController = TextEditingController();
  final _familyPsychiatricHistoryController = TextEditingController();
  final _familyOtherFamilyHistoryController = TextEditingController();

  // 7. Intrauterine & Developmental History (15 fields)
  final _devMaternalHealthController = TextEditingController();
  final _devPregnancyComplicationsController = TextEditingController();
  final _devMaternalInfectionsController = TextEditingController();
  final _devMaternalMedicationsController = TextEditingController();
  final _devAntenatalCareController = TextEditingController();
  final _devNutritionDuringPregnancyController = TextEditingController();
  final _devGestationalAgeController = TextEditingController();
  final _devBirthOrderController = TextEditingController();
  final _devModeOfDeliveryController = TextEditingController();
  final _devBirthWeightController = TextEditingController();
  final _devNeonatalHistoryController = TextEditingController();
  final _devBreastfeedingController = TextEditingController();
  final _devDevelopmentalMilestonesController = TextEditingController();
  final _devChildhoodDevelopmentController = TextEditingController();
  final _devOtherBirthDevelopmentalHistoryController = TextEditingController();

  // 8. Physical Generals (37 fields)
  final _pgHotChillyController = TextEditingController(text: 'Ambithermal');
  final _pgWeatherSeasonPreferenceController = TextEditingController();
  final _pgSensitivityToTemperatureController = TextEditingController();
  final _pgThirstQuantityController = TextEditingController();
  final _pgThirstFrequencyController = TextEditingController();
  final _pgThirstTimingController = TextEditingController();
  final _pgAppetiteController = TextEditingController();
  final _pgHungerFastingController = TextEditingController();
  final _pgFoodDesiresController = TextEditingController();
  final _pgFoodAversionsController = TextEditingController();
  final _pgFoodIntolerancesController = TextEditingController();
  final _pgStoolFrequencyController = TextEditingController();
  final _pgStoolConsistencyController = TextEditingController();
  final _pgStoolColourOdourController = TextEditingController();
  final _pgStoolDifficultiesModalitiesController = TextEditingController();
  final _pgUrineFrequencyController = TextEditingController();
  final _pgUrineQuantityController = TextEditingController();
  final _pgUrineColourOdourController = TextEditingController();
  final _pgUrinarySymptomsController = TextEditingController();
  final _pgPerspirationQuantityController = TextEditingController();
  final _pgPerspirationOdourController = TextEditingController();
  final _pgPerspirationTimingDistributionController = TextEditingController();
  final _pgSleepQuantityController = TextEditingController();
  final _pgSleepQualityController = TextEditingController();
  final _pgSleepPositionController = TextEditingController();
  final _pgSleepOnsetController = TextEditingController();
  final _pgSleepDisturbancesController = TextEditingController();
  final _pgDreamsGeneralController = TextEditingController();
  final _pgDreamsRecurrentPeculiarController = TextEditingController();
  final _pgEnergyVitalityController = TextEditingController();
  final _pgFatigueController = TextEditingController();
  final _pgSexualHistoryController = TextEditingController();
  final _pgMenstrualHistoryController = TextEditingController();
  final _pgObstetricHistoryController = TextEditingController();
  final _pgSkinHairNailsController = TextEditingController();
  final _pgGeneralDischargesController = TextEditingController();
  final _pgOtherPhysicalGeneralsController = TextEditingController();

  // 9. Mental & Emotional Generals (27 fields)
  final _mgGeneralMentalEmotionalStateController = TextEditingController();
  final _mgDispositionController = TextEditingController();
  final _mgIrritabilityController = TextEditingController();
  final _mgAngerController = TextEditingController();
  final _mgAnxietyController = TextEditingController();
  final _mgFearsController = TextEditingController();
  final _mgSpecificFearsPhobiasController = TextEditingController();
  final _mgSadnessGriefController = TextEditingController();
  final _mgDepressionController = TextEditingController();
  final _mgJealousyController = TextEditingController();
  final _mgSuspicionController = TextEditingController();
  final _mgCompanyDesireAversionController = TextEditingController();
  final _mgDesireForSolitudeController = TextEditingController();
  final _mgDesireForAttentionConsolationController = TextEditingController();
  final _mgTalkativenessQuietnessController = TextEditingController();
  final _mgConfidenceSelfEsteemController = TextEditingController();
  final _mgWillDeterminationController = TextEditingController();
  final _mgIndecisionController = TextEditingController();
  final _mgMemoryController = TextEditingController();
  final _mgConcentrationController = TextEditingController();
  final _mgWorkStudyResponseController = TextEditingController();
  final _mgRestlessnessController = TextEditingController();
  final _mgResponseToStressController = TextEditingController();
  final _mgResponseToContradictionOppositionController = TextEditingController();
  final _mgResponseToReprimandController = TextEditingController();
  final _mgCompulsionsObsessionsController = TextEditingController();
  final _mgOtherCharacteristicMentalSymptomsController = TextEditingController();

  // 10. Lifestyle, Habits & Environment (14 fields)
  final _plDietController = TextEditingController();
  final _plMealPatternController = TextEditingController();
  final _plTeaCoffeeController = TextEditingController();
  final _plTobaccoController = TextEditingController();
  final _plAlcoholController = TextEditingController();
  final _plOtherSubstanceUseController = TextEditingController();
  final _plPhysicalActivityController = TextEditingController();
  final _plOccupationWorkPatternController = TextEditingController();
  final _plSedentaryBehaviourController = TextEditingController();
  final _plSleepRoutineController = TextEditingController();
  final _plPersonalHygieneController = TextEditingController();
  final _plSocialHistoryController = TextEditingController();
  final _plFinancialOccupationalStressorsController = TextEditingController();
  final _plOtherHabitsController = TextEditingController();

  // 11. Clinical Examination & Vitals (24 fields)
  final _ceGeneralAppearanceController = TextEditingController();
  final _ceBuildNutritionController = TextEditingController();
  final _cePallorController = TextEditingController();
  final _ceIcterusController = TextEditingController();
  final _ceCyanosisController = TextEditingController();
  final _ceClubbingController = TextEditingController();
  final _ceLymphadenopathyController = TextEditingController();
  final _ceOedemaController = TextEditingController();
  final _ceTemperatureController = TextEditingController();
  final _cePulseController = TextEditingController();
  final _ceBloodPressureController = TextEditingController();
  final _ceRespiratoryRateController = TextEditingController();
  final _ceSpO2Controller = TextEditingController();
  final _ceWeightController = TextEditingController();
  final _ceHeightController = TextEditingController();
  final _ceBMIController = TextEditingController();
  final _ceCVSExaminationController = TextEditingController();
  final _ceRespiratoryExaminationController = TextEditingController();
  final _ceAbdominalExaminationController = TextEditingController();
  final _ceCNSExaminationController = TextEditingController();
  final _ceMusculoskeletalExaminationController = TextEditingController();
  final _ceSkinExaminationController = TextEditingController();
  final _ceENTOralExaminationController = TextEditingController();
  final _ceOtherExaminationFindingsController = TextEditingController();

  // 12. Miasmatic Analysis (10 fields)
  String _maPredominantMiasm = 'Psora';
  final _maSecondaryMixedMiasmController = TextEditingController();
  final _maPsoricFeaturesController = TextEditingController();
  final _maSycoticFeaturesController = TextEditingController();
  final _maSyphiliticFeaturesController = TextEditingController();
  final _maTubercularFeaturesController = TextEditingController();
  final _maCancerinicFeaturesController = TextEditingController();
  final _maOtherMiasmaticIndicatorsController = TextEditingController();
  final _maCharacteristicSymptomsSupportingMiasmController = TextEditingController();
  final _maFinalMiasmaticInterpretationController = TextEditingController();

  // 13. Case Analysis & Totality (15 fields)
  final _caTotalityOfSymptomsController = TextEditingController();
  final _caCharacteristicSymptomsController = TextEditingController();
  final _caGeneralsController = TextEditingController();
  final _caParticularsController = TextEditingController();
  final _caMentalGeneralsController = TextEditingController();
  final _caPhysicalGeneralsController = TextEditingController();
  final _caModalitiesController = TextEditingController();
  final _caConcomitantsController = TextEditingController();
  final _caCausationController = TextEditingController();
  final _caRepertoryUsedController = TextEditingController();
  final _caRubricsSelectedController = TextEditingController();
  final _caRepertorialResultController = TextEditingController();
  final _caMateriaMedicaCorrelationController = TextEditingController();
  final _caDifferentialRemediesController = TextEditingController();
  final _caFinalRemedySelectionRationaleController = TextEditingController();

  // 14. Clinical Assessment & Diagnosis (6 fields)
  final _diagProvisionalDiagnosisController = TextEditingController();
  final _diagFinalWorkingDiagnosisController = TextEditingController();
  final _diagDifferentialDiagnosisController = TextEditingController();
  final _diagComorbiditiesController = TextEditingController();
  final _diagRedFlagsReferralIndicationsController = TextEditingController();
  final _diagClinicalRemarksController = TextEditingController();

  // 15. Baseline Prescription & Management (14 fields)
  final _rxPrescriptionDateController = TextEditingController();
  final _rxRemedyController = TextEditingController();
  final _rxPotencyController = TextEditingController();
  final _rxDoseController = TextEditingController();
  final _rxRepetitionFrequencyController = TextEditingController();
  final _rxRouteController = TextEditingController(text: 'Oral');
  final _rxPharmaceuticalFormController = TextEditingController(text: 'Globules / Sugar Pellets');
  final _rxQuantityDispensedController = TextEditingController();
  final _rxDietRegimenAdviceController = TextEditingController();
  final _rxLifestyleAdviceController = TextEditingController();
  final _rxInvestigationsAdvisedController = TextEditingController();
  final _rxReferralAdvisedController = TextEditingController();
  final _rxPrescriptionRationaleController = TextEditingController();
  final _rxPrescriptionNotesController = TextEditingController();

  // 16. Investigations & Laboratory Findings (10 fields)
  final _invInvestigationDateController = TextEditingController();
  final _invInvestigationNameController = TextEditingController();
  final _invTypePanelController = TextEditingController();
  final _invResultValueController = TextEditingController();
  final _invUnitController = TextEditingController();
  final _invReferenceRangeController = TextEditingController();
  final _invNormalAbnormalController = TextEditingController(text: 'Normal');
  final _invReportSummaryController = TextEditingController();
  final _invClinicalInterpretationController = TextEditingController();
  final _invReportReferenceController = TextEditingController();

  // 17. Follow-Up Details (20 fields)
  final _fuFollowUpDateController = TextEditingController();
  final _fuIntervalSincePreviousVisitController = TextEditingController();
  final _fuOverallResponseController = TextEditingController();
  final _fuChiefComplaintChangesController = TextEditingController();
  final _fuNewSymptomsController = TextEditingController();
  final _fuAggravationController = TextEditingController();
  final _fuImprovementController = TextEditingController();
  final _fuGeneralSymptomsChangeController = TextEditingController();
  final _fuMentalSymptomsChangeController = TextEditingController();
  final _fuSleepChangeController = TextEditingController();
  final _fuAppetiteThirstChangeController = TextEditingController();
  final _fuStoolUrineChangeController = TextEditingController();
  final _fuPerspirationChangeController = TextEditingController();
  final _fuEnergyChangeController = TextEditingController();
  final _fuAdverseNewSymptomsController = TextEditingController();
  final _fuFollowUpPrescriptionController = TextEditingController();
  final _fuPotencyController = TextEditingController();
  final _fuDoseRepetitionController = TextEditingController();
  final _fuNextFollowUpController = TextEditingController();
  final _fuFollowUpRemarksController = TextEditingController();

  // 18. Outcome & Treatment Closure (6 fields)
  String _outFinalStatus = 'Under Active Treatment';
  final _outDegreeOfImprovementController = TextEditingController();
  final _outTreatmentDurationController = TextEditingController();
  final _outReasonForDiscontinuationClosureController = TextEditingController();
  final _outLostToFollowUpController = TextEditingController();
  final _outFinalOutcomeNotesController = TextEditingController();

  // 19. Documentation & Archival Details (4 fields)
  final _docDataSourceController = TextEditingController();
  final _docOriginalRegisterReferenceController = TextEditingController();
  final _docTranscriptionNotesController = TextEditingController();
  final _docUnclearInformationController = TextEditingController();

  void _markDirty() {
    if (!_isPopulating && !_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  void _attachComplaintListeners(_ComplaintEntry entry) {
    entry.complaint.addListener(_markDirty);
    entry.location.addListener(_markDirty);
    entry.onset.addListener(_markDirty);
    entry.duration.addListener(_markDirty);
    entry.sensation.addListener(_markDirty);
    entry.extensionRadiation.addListener(_markDirty);
    entry.agg.addListener(_markDirty);
    entry.amel.addListener(_markDirty);
    entry.concomitant.addListener(_markDirty);
    entry.causation.addListener(_markDirty);
    entry.periodicity.addListener(_markDirty);
    entry.time.addListener(_markDirty);
    entry.associatedSymptoms.addListener(_markDirty);
  }

  List<TextEditingController> _getAllControllers() {
    return [
      _regNoController,
      _firstVisitDateController,
      _patientNameController,
      _ageController,
      _genderController,
      _dobController,
      _occupationController,
      _addressController,
      _phoneController,
      _additionalComplaintsController,
      _hpiChronoDevController,
      _hpiFirstOccurrenceController,
      _hpiProgressionController,
      _hpiPreviousEpisodesController,
      _hpiPreviousTreatmentController,
      _hpiResponseToTreatmentController,
      _hpiPrecipitatingFactorsController,
      _hpiOtherRelevantHistoryController,
      _pastChildhoodIllnessesController,
      _pastMajorIllnessesController,
      _pastChronicDiseasesController,
      _pastSurgeriesController,
      _pastInjuriesTraumaController,
      _pastHospitalisationsController,
      _pastInfectionsController,
      _pastAllergiesController,
      _pastPreviousMedicationsController,
      _pastPrevHomeopathicTreatmentController,
      _pastOtherPastHistoryController,
      _familyFatherController,
      _familyMotherController,
      _familySiblingsController,
      _familySpouseController,
      _familyChildrenController,
      _familyGrandparentsRelativesController,
      _familyHereditaryDiseasesController,
      _familyMajorFamilialDiseasesController,
      _familyPsychiatricHistoryController,
      _familyOtherFamilyHistoryController,
      _devMaternalHealthController,
      _devPregnancyComplicationsController,
      _devMaternalInfectionsController,
      _devMaternalMedicationsController,
      _devAntenatalCareController,
      _devNutritionDuringPregnancyController,
      _devGestationalAgeController,
      _devBirthOrderController,
      _devModeOfDeliveryController,
      _devBirthWeightController,
      _devNeonatalHistoryController,
      _devBreastfeedingController,
      _devDevelopmentalMilestonesController,
      _devChildhoodDevelopmentController,
      _devOtherBirthDevelopmentalHistoryController,
      _pgHotChillyController,
      _pgWeatherSeasonPreferenceController,
      _pgSensitivityToTemperatureController,
      _pgThirstQuantityController,
      _pgThirstFrequencyController,
      _pgThirstTimingController,
      _pgAppetiteController,
      _pgHungerFastingController,
      _pgFoodDesiresController,
      _pgFoodAversionsController,
      _pgFoodIntolerancesController,
      _pgStoolFrequencyController,
      _pgStoolConsistencyController,
      _pgStoolColourOdourController,
      _pgStoolDifficultiesModalitiesController,
      _pgUrineFrequencyController,
      _pgUrineQuantityController,
      _pgUrineColourOdourController,
      _pgUrinarySymptomsController,
      _pgPerspirationQuantityController,
      _pgPerspirationOdourController,
      _pgPerspirationTimingDistributionController,
      _pgSleepQuantityController,
      _pgSleepQualityController,
      _pgSleepPositionController,
      _pgSleepOnsetController,
      _pgSleepDisturbancesController,
      _pgDreamsGeneralController,
      _pgDreamsRecurrentPeculiarController,
      _pgEnergyVitalityController,
      _pgFatigueController,
      _pgSexualHistoryController,
      _pgMenstrualHistoryController,
      _pgObstetricHistoryController,
      _pgSkinHairNailsController,
      _pgGeneralDischargesController,
      _pgOtherPhysicalGeneralsController,
      _mgGeneralMentalEmotionalStateController,
      _mgDispositionController,
      _mgIrritabilityController,
      _mgAngerController,
      _mgAnxietyController,
      _mgFearsController,
      _mgSpecificFearsPhobiasController,
      _mgSadnessGriefController,
      _mgDepressionController,
      _mgJealousyController,
      _mgSuspicionController,
      _mgCompanyDesireAversionController,
      _mgDesireForSolitudeController,
      _mgDesireForAttentionConsolationController,
      _mgTalkativenessQuietnessController,
      _mgConfidenceSelfEsteemController,
      _mgWillDeterminationController,
      _mgIndecisionController,
      _mgMemoryController,
      _mgConcentrationController,
      _mgWorkStudyResponseController,
      _mgRestlessnessController,
      _mgResponseToStressController,
      _mgResponseToContradictionOppositionController,
      _mgResponseToReprimandController,
      _mgCompulsionsObsessionsController,
      _mgOtherCharacteristicMentalSymptomsController,
      _plDietController,
      _plMealPatternController,
      _plTeaCoffeeController,
      _plTobaccoController,
      _plAlcoholController,
      _plOtherSubstanceUseController,
      _plPhysicalActivityController,
      _plOccupationWorkPatternController,
      _plSedentaryBehaviourController,
      _plSleepRoutineController,
      _plPersonalHygieneController,
      _plSocialHistoryController,
      _plFinancialOccupationalStressorsController,
      _plOtherHabitsController,
      _ceGeneralAppearanceController,
      _ceBuildNutritionController,
      _cePallorController,
      _ceIcterusController,
      _ceCyanosisController,
      _ceClubbingController,
      _ceLymphadenopathyController,
      _ceOedemaController,
      _ceTemperatureController,
      _cePulseController,
      _ceBloodPressureController,
      _ceRespiratoryRateController,
      _ceSpO2Controller,
      _ceWeightController,
      _ceHeightController,
      _ceBMIController,
      _ceCVSExaminationController,
      _ceRespiratoryExaminationController,
      _ceAbdominalExaminationController,
      _ceCNSExaminationController,
      _ceMusculoskeletalExaminationController,
      _ceSkinExaminationController,
      _ceENTOralExaminationController,
      _ceOtherExaminationFindingsController,
      _maSecondaryMixedMiasmController,
      _maPsoricFeaturesController,
      _maSycoticFeaturesController,
      _maSyphiliticFeaturesController,
      _maTubercularFeaturesController,
      _maCancerinicFeaturesController,
      _maOtherMiasmaticIndicatorsController,
      _maCharacteristicSymptomsSupportingMiasmController,
      _maFinalMiasmaticInterpretationController,
      _caTotalityOfSymptomsController,
      _caCharacteristicSymptomsController,
      _caGeneralsController,
      _caParticularsController,
      _caMentalGeneralsController,
      _caPhysicalGeneralsController,
      _caModalitiesController,
      _caConcomitantsController,
      _caCausationController,
      _caRepertoryUsedController,
      _caRubricsSelectedController,
      _caRepertorialResultController,
      _caMateriaMedicaCorrelationController,
      _caDifferentialRemediesController,
      _caFinalRemedySelectionRationaleController,
      _diagProvisionalDiagnosisController,
      _diagFinalWorkingDiagnosisController,
      _diagDifferentialDiagnosisController,
      _diagComorbiditiesController,
      _diagRedFlagsReferralIndicationsController,
      _diagClinicalRemarksController,
      _rxPrescriptionDateController,
      _rxRemedyController,
      _rxPotencyController,
      _rxDoseController,
      _rxRepetitionFrequencyController,
      _rxRouteController,
      _rxPharmaceuticalFormController,
      _rxQuantityDispensedController,
      _rxDietRegimenAdviceController,
      _rxLifestyleAdviceController,
      _rxInvestigationsAdvisedController,
      _rxReferralAdvisedController,
      _rxPrescriptionRationaleController,
      _rxPrescriptionNotesController,
      _invInvestigationDateController,
      _invInvestigationNameController,
      _invTypePanelController,
      _invResultValueController,
      _invUnitController,
      _invReferenceRangeController,
      _invNormalAbnormalController,
      _invReportSummaryController,
      _invClinicalInterpretationController,
      _invReportReferenceController,
      _fuFollowUpDateController,
      _fuIntervalSincePreviousVisitController,
      _fuOverallResponseController,
      _fuChiefComplaintChangesController,
      _fuNewSymptomsController,
      _fuAggravationController,
      _fuImprovementController,
      _fuGeneralSymptomsChangeController,
      _fuMentalSymptomsChangeController,
      _fuSleepChangeController,
      _fuAppetiteThirstChangeController,
      _fuStoolUrineChangeController,
      _fuPerspirationChangeController,
      _fuEnergyChangeController,
      _fuAdverseNewSymptomsController,
      _fuFollowUpPrescriptionController,
      _fuPotencyController,
      _fuDoseRepetitionController,
      _fuNextFollowUpController,
      _fuFollowUpRemarksController,
      _outDegreeOfImprovementController,
      _outTreatmentDurationController,
      _outReasonForDiscontinuationClosureController,
      _outLostToFollowUpController,
      _outFinalOutcomeNotesController,
      _docDataSourceController,
      _docOriginalRegisterReferenceController,
      _docTranscriptionNotesController,
      _docUnclearInformationController,
    ];
  }

  @override
  void initState() {
    super.initState();
    _sectionKeys = List.generate(_sectionTitles.length, (_) => GlobalKey());
    _isPopulating = true;
    _initializeDefaultData();
    for (final c in _getAllControllers()) {
      c.addListener(_markDirty);
    }
    for (final entry in _complaints) {
      _attachComplaintListeners(entry);
    }
    _isPopulating = false;
  }

  void _initializeDefaultData() {
    _patientNameController.text = widget.patient.name;
    _ageController.text = '${widget.patient.age}';
    _genderController.text = widget.patient.gender.isNotEmpty ? widget.patient.gender : 'Male';
    _phoneController.text = widget.patient.phone;
    if (widget.patient.patientCode.isNotEmpty) {
      _regNoController.text = widget.patient.patientCode;
    }
    _addressController.text = widget.patient.address ?? '';
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

    _additionalComplaintsController.dispose();

    _hpiChronoDevController.dispose();
    _hpiFirstOccurrenceController.dispose();
    _hpiProgressionController.dispose();
    _hpiPreviousEpisodesController.dispose();
    _hpiPreviousTreatmentController.dispose();
    _hpiResponseToTreatmentController.dispose();
    _hpiPrecipitatingFactorsController.dispose();
    _hpiOtherRelevantHistoryController.dispose();

    _pastChildhoodIllnessesController.dispose();
    _pastMajorIllnessesController.dispose();
    _pastChronicDiseasesController.dispose();
    _pastSurgeriesController.dispose();
    _pastInjuriesTraumaController.dispose();
    _pastHospitalisationsController.dispose();
    _pastInfectionsController.dispose();
    _pastAllergiesController.dispose();
    _pastPreviousMedicationsController.dispose();
    _pastPrevHomeopathicTreatmentController.dispose();
    _pastOtherPastHistoryController.dispose();

    _familyFatherController.dispose();
    _familyMotherController.dispose();
    _familySiblingsController.dispose();
    _familySpouseController.dispose();
    _familyChildrenController.dispose();
    _familyGrandparentsRelativesController.dispose();
    _familyHereditaryDiseasesController.dispose();
    _familyMajorFamilialDiseasesController.dispose();
    _familyPsychiatricHistoryController.dispose();
    _familyOtherFamilyHistoryController.dispose();

    _devMaternalHealthController.dispose();
    _devPregnancyComplicationsController.dispose();
    _devMaternalInfectionsController.dispose();
    _devMaternalMedicationsController.dispose();
    _devAntenatalCareController.dispose();
    _devNutritionDuringPregnancyController.dispose();
    _devGestationalAgeController.dispose();
    _devBirthOrderController.dispose();
    _devModeOfDeliveryController.dispose();
    _devBirthWeightController.dispose();
    _devNeonatalHistoryController.dispose();
    _devBreastfeedingController.dispose();
    _devDevelopmentalMilestonesController.dispose();
    _devChildhoodDevelopmentController.dispose();
    _devOtherBirthDevelopmentalHistoryController.dispose();

    _pgHotChillyController.dispose();
    _pgWeatherSeasonPreferenceController.dispose();
    _pgSensitivityToTemperatureController.dispose();
    _pgThirstQuantityController.dispose();
    _pgThirstFrequencyController.dispose();
    _pgThirstTimingController.dispose();
    _pgAppetiteController.dispose();
    _pgHungerFastingController.dispose();
    _pgFoodDesiresController.dispose();
    _pgFoodAversionsController.dispose();
    _pgFoodIntolerancesController.dispose();
    _pgStoolFrequencyController.dispose();
    _pgStoolConsistencyController.dispose();
    _pgStoolColourOdourController.dispose();
    _pgStoolDifficultiesModalitiesController.dispose();
    _pgUrineFrequencyController.dispose();
    _pgUrineQuantityController.dispose();
    _pgUrineColourOdourController.dispose();
    _pgUrinarySymptomsController.dispose();
    _pgPerspirationQuantityController.dispose();
    _pgPerspirationOdourController.dispose();
    _pgPerspirationTimingDistributionController.dispose();
    _pgSleepQuantityController.dispose();
    _pgSleepQualityController.dispose();
    _pgSleepPositionController.dispose();
    _pgSleepOnsetController.dispose();
    _pgSleepDisturbancesController.dispose();
    _pgDreamsGeneralController.dispose();
    _pgDreamsRecurrentPeculiarController.dispose();
    _pgEnergyVitalityController.dispose();
    _pgFatigueController.dispose();
    _pgSexualHistoryController.dispose();
    _pgMenstrualHistoryController.dispose();
    _pgObstetricHistoryController.dispose();
    _pgSkinHairNailsController.dispose();
    _pgGeneralDischargesController.dispose();
    _pgOtherPhysicalGeneralsController.dispose();

    _mgGeneralMentalEmotionalStateController.dispose();
    _mgDispositionController.dispose();
    _mgIrritabilityController.dispose();
    _mgAngerController.dispose();
    _mgAnxietyController.dispose();
    _mgFearsController.dispose();
    _mgSpecificFearsPhobiasController.dispose();
    _mgSadnessGriefController.dispose();
    _mgDepressionController.dispose();
    _mgJealousyController.dispose();
    _mgSuspicionController.dispose();
    _mgCompanyDesireAversionController.dispose();
    _mgDesireForSolitudeController.dispose();
    _mgDesireForAttentionConsolationController.dispose();
    _mgTalkativenessQuietnessController.dispose();
    _mgConfidenceSelfEsteemController.dispose();
    _mgWillDeterminationController.dispose();
    _mgIndecisionController.dispose();
    _mgMemoryController.dispose();
    _mgConcentrationController.dispose();
    _mgWorkStudyResponseController.dispose();
    _mgRestlessnessController.dispose();
    _mgResponseToStressController.dispose();
    _mgResponseToContradictionOppositionController.dispose();
    _mgResponseToReprimandController.dispose();
    _mgCompulsionsObsessionsController.dispose();
    _mgOtherCharacteristicMentalSymptomsController.dispose();

    _plDietController.dispose();
    _plMealPatternController.dispose();
    _plTeaCoffeeController.dispose();
    _plTobaccoController.dispose();
    _plAlcoholController.dispose();
    _plOtherSubstanceUseController.dispose();
    _plPhysicalActivityController.dispose();
    _plOccupationWorkPatternController.dispose();
    _plSedentaryBehaviourController.dispose();
    _plSleepRoutineController.dispose();
    _plPersonalHygieneController.dispose();
    _plSocialHistoryController.dispose();
    _plFinancialOccupationalStressorsController.dispose();
    _plOtherHabitsController.dispose();

    _ceGeneralAppearanceController.dispose();
    _ceBuildNutritionController.dispose();
    _cePallorController.dispose();
    _ceIcterusController.dispose();
    _ceCyanosisController.dispose();
    _ceClubbingController.dispose();
    _ceLymphadenopathyController.dispose();
    _ceOedemaController.dispose();
    _ceTemperatureController.dispose();
    _cePulseController.dispose();
    _ceBloodPressureController.dispose();
    _ceRespiratoryRateController.dispose();
    _ceSpO2Controller.dispose();
    _ceWeightController.dispose();
    _ceHeightController.dispose();
    _ceBMIController.dispose();
    _ceCVSExaminationController.dispose();
    _ceRespiratoryExaminationController.dispose();
    _ceAbdominalExaminationController.dispose();
    _ceCNSExaminationController.dispose();
    _ceMusculoskeletalExaminationController.dispose();
    _ceSkinExaminationController.dispose();
    _ceENTOralExaminationController.dispose();
    _ceOtherExaminationFindingsController.dispose();

    _maSecondaryMixedMiasmController.dispose();
    _maPsoricFeaturesController.dispose();
    _maSycoticFeaturesController.dispose();
    _maSyphiliticFeaturesController.dispose();
    _maTubercularFeaturesController.dispose();
    _maCancerinicFeaturesController.dispose();
    _maOtherMiasmaticIndicatorsController.dispose();
    _maCharacteristicSymptomsSupportingMiasmController.dispose();
    _maFinalMiasmaticInterpretationController.dispose();

    _caTotalityOfSymptomsController.dispose();
    _caCharacteristicSymptomsController.dispose();
    _caGeneralsController.dispose();
    _caParticularsController.dispose();
    _caMentalGeneralsController.dispose();
    _caPhysicalGeneralsController.dispose();
    _caModalitiesController.dispose();
    _caConcomitantsController.dispose();
    _caCausationController.dispose();
    _caRepertoryUsedController.dispose();
    _caRubricsSelectedController.dispose();
    _caRepertorialResultController.dispose();
    _caMateriaMedicaCorrelationController.dispose();
    _caDifferentialRemediesController.dispose();
    _caFinalRemedySelectionRationaleController.dispose();

    _diagProvisionalDiagnosisController.dispose();
    _diagFinalWorkingDiagnosisController.dispose();
    _diagDifferentialDiagnosisController.dispose();
    _diagComorbiditiesController.dispose();
    _diagRedFlagsReferralIndicationsController.dispose();
    _diagClinicalRemarksController.dispose();

    _rxPrescriptionDateController.dispose();
    _rxRemedyController.dispose();
    _rxPotencyController.dispose();
    _rxDoseController.dispose();
    _rxRepetitionFrequencyController.dispose();
    _rxRouteController.dispose();
    _rxPharmaceuticalFormController.dispose();
    _rxQuantityDispensedController.dispose();
    _rxDietRegimenAdviceController.dispose();
    _rxLifestyleAdviceController.dispose();
    _rxInvestigationsAdvisedController.dispose();
    _rxReferralAdvisedController.dispose();
    _rxPrescriptionRationaleController.dispose();
    _rxPrescriptionNotesController.dispose();

    _invInvestigationDateController.dispose();
    _invInvestigationNameController.dispose();
    _invTypePanelController.dispose();
    _invResultValueController.dispose();
    _invUnitController.dispose();
    _invReferenceRangeController.dispose();
    _invNormalAbnormalController.dispose();
    _invReportSummaryController.dispose();
    _invClinicalInterpretationController.dispose();
    _invReportReferenceController.dispose();

    _fuFollowUpDateController.dispose();
    _fuIntervalSincePreviousVisitController.dispose();
    _fuOverallResponseController.dispose();
    _fuChiefComplaintChangesController.dispose();
    _fuNewSymptomsController.dispose();
    _fuAggravationController.dispose();
    _fuImprovementController.dispose();
    _fuGeneralSymptomsChangeController.dispose();
    _fuMentalSymptomsChangeController.dispose();
    _fuSleepChangeController.dispose();
    _fuAppetiteThirstChangeController.dispose();
    _fuStoolUrineChangeController.dispose();
    _fuPerspirationChangeController.dispose();
    _fuEnergyChangeController.dispose();
    _fuAdverseNewSymptomsController.dispose();
    _fuFollowUpPrescriptionController.dispose();
    _fuPotencyController.dispose();
    _fuDoseRepetitionController.dispose();
    _fuNextFollowUpController.dispose();
    _fuFollowUpRemarksController.dispose();

    _outDegreeOfImprovementController.dispose();
    _outTreatmentDurationController.dispose();
    _outReasonForDiscontinuationClosureController.dispose();
    _outLostToFollowUpController.dispose();
    _outFinalOutcomeNotesController.dispose();

    _docDataSourceController.dispose();
    _docOriginalRegisterReferenceController.dispose();
    _docTranscriptionNotesController.dispose();
    _docUnclearInformationController.dispose();

    super.dispose();
  }

  void _populateFromExisting(MasterCaseRecordData record) {
    if (_initialized) return;
    _initialized = true;
    _isPopulating = true;

    // 1. Identification
    if (record.identification.regNo.isNotEmpty) _regNoController.text = record.identification.regNo;
    if (record.identification.firstVisitDate.isNotEmpty) _firstVisitDateController.text = Formatters.displayFromDbDate(record.identification.firstVisitDate);
    if (record.identification.patientName.isNotEmpty) _patientNameController.text = record.identification.patientName;
    if (record.identification.age.isNotEmpty) _ageController.text = record.identification.age;
    if (record.identification.gender.isNotEmpty) _genderController.text = record.identification.gender;
    if (record.identification.dob.isNotEmpty) _dobController.text = Formatters.displayFromDbDate(record.identification.dob);
    if (record.identification.occupation.isNotEmpty) _occupationController.text = record.identification.occupation;
    if (record.identification.address.isNotEmpty) _addressController.text = record.identification.address;
    if (record.identification.phone.isNotEmpty) _phoneController.text = record.identification.phone;
    if (record.identification.maritalStatus.isNotEmpty) _maritalStatus = record.identification.maritalStatus;

    // 2. Chief Complaints
    if (record.chiefComplaints.isNotEmpty) {
      _complaints.clear();
      for (final c in record.chiefComplaints) {
        final entry = _ComplaintEntry();
        entry.complaint.text = c.complaint;
        entry.location.text = c.location;
        entry.onset.text = c.onset;
        entry.duration.text = c.duration;
        entry.sensation.text = c.sensation;
        entry.extensionRadiation.text = c.extensionRadiation;
        entry.agg.text = c.modalitiesAgg;
        entry.amel.text = c.modalitiesAmel;
        entry.concomitant.text = c.concomitants;
        entry.causation.text = c.causation;
        entry.periodicity.text = c.periodicity;
        entry.time.text = c.time;
        entry.severity = c.severity.isNotEmpty ? c.severity : 'Moderate';
        entry.associatedSymptoms.text = c.associatedSymptoms;
        _complaints.add(entry);
      }
    }
    if (_complaints.isEmpty) _complaints.add(_ComplaintEntry());

    // 3. Additional Complaints
    _additionalComplaintsController.text = record.additionalComplaints;

    // 4. HPI
    _hpiChronoDevController.text = record.hpi.chronologicalDevelopment;
    _hpiFirstOccurrenceController.text = record.hpi.firstOccurrence;
    _hpiProgressionController.text = record.hpi.progression;
    _hpiPreviousEpisodesController.text = record.hpi.previousEpisodes;
    _hpiPreviousTreatmentController.text = record.hpi.previousTreatment;
    _hpiResponseToTreatmentController.text = record.hpi.responseToTreatment;
    _hpiPrecipitatingFactorsController.text = record.hpi.relevantPrecipitatingFactors;
    _hpiOtherRelevantHistoryController.text = record.hpi.otherRelevantHistory;

    // 5. Past History
    _pastChildhoodIllnessesController.text = record.pastHistory.childhoodIllnesses;
    _pastMajorIllnessesController.text = record.pastHistory.majorIllnesses;
    _pastChronicDiseasesController.text = record.pastHistory.chronicDiseases;
    _pastSurgeriesController.text = record.pastHistory.surgeries;
    _pastInjuriesTraumaController.text = record.pastHistory.injuriesTrauma;
    _pastHospitalisationsController.text = record.pastHistory.hospitalisations;
    _pastInfectionsController.text = record.pastHistory.infections;
    _pastAllergiesController.text = record.pastHistory.allergies;
    _pastPreviousMedicationsController.text = record.pastHistory.previousMedications;
    _pastPrevHomeopathicTreatmentController.text = record.pastHistory.previousHomeopathicTreatment;
    _pastOtherPastHistoryController.text = record.pastHistory.otherPastHistory;

    // 6. Family History
    _familyFatherController.text = record.familyHistory.father;
    _familyMotherController.text = record.familyHistory.mother;
    _familySiblingsController.text = record.familyHistory.siblings;
    _familySpouseController.text = record.familyHistory.spouse;
    _familyChildrenController.text = record.familyHistory.children;
    _familyGrandparentsRelativesController.text = record.familyHistory.grandparentsRelatives;
    _familyHereditaryDiseasesController.text = record.familyHistory.hereditaryDiseases;
    _familyMajorFamilialDiseasesController.text = record.familyHistory.majorFamilialDiseases;
    _familyPsychiatricHistoryController.text = record.familyHistory.psychiatricHistory;
    _familyOtherFamilyHistoryController.text = record.familyHistory.otherFamilyHistory;

    // 7. Developmental History
    _devMaternalHealthController.text = record.developmentalHistory.maternalHealth;
    _devPregnancyComplicationsController.text = record.developmentalHistory.pregnancyComplications;
    _devMaternalInfectionsController.text = record.developmentalHistory.maternalInfections;
    _devMaternalMedicationsController.text = record.developmentalHistory.maternalMedications;
    _devAntenatalCareController.text = record.developmentalHistory.antenatalCare;
    _devNutritionDuringPregnancyController.text = record.developmentalHistory.nutritionDuringPregnancy;
    _devGestationalAgeController.text = record.developmentalHistory.gestationalAge;
    _devBirthOrderController.text = record.developmentalHistory.birthOrder;
    _devModeOfDeliveryController.text = record.developmentalHistory.modeOfDelivery;
    _devBirthWeightController.text = record.developmentalHistory.birthWeight;
    _devNeonatalHistoryController.text = record.developmentalHistory.neonatalHistory;
    _devBreastfeedingController.text = record.developmentalHistory.breastfeeding;
    _devDevelopmentalMilestonesController.text = record.developmentalHistory.developmentalMilestones;
    _devChildhoodDevelopmentController.text = record.developmentalHistory.childhoodDevelopment;
    _devOtherBirthDevelopmentalHistoryController.text = record.developmentalHistory.otherBirthDevelopmentalHistory;

    // 8. Physical Generals
    if (record.physicalGenerals.hotChilly.isNotEmpty) {
      _pgHotChillyController.text = record.physicalGenerals.hotChilly;
    } else if (record.physicalGenerals.thermal.isNotEmpty) {
      _pgHotChillyController.text = record.physicalGenerals.thermal;
    }
    _pgWeatherSeasonPreferenceController.text = record.physicalGenerals.weatherPreference;
    _pgSensitivityToTemperatureController.text = record.physicalGenerals.sensitivityToTemperature;
    _pgThirstQuantityController.text = record.physicalGenerals.thirst;
    _pgThirstFrequencyController.text = record.physicalGenerals.thirstFrequency;
    _pgThirstTimingController.text = record.physicalGenerals.thirstTiming;
    _pgAppetiteController.text = record.physicalGenerals.appetite;
    _pgHungerFastingController.text = record.physicalGenerals.hungerFasting;
    _pgFoodDesiresController.text = record.physicalGenerals.cravings;
    _pgFoodAversionsController.text = record.physicalGenerals.aversions;
    _pgFoodIntolerancesController.text = record.physicalGenerals.intolerances;
    _pgStoolFrequencyController.text = record.physicalGenerals.stoolFrequency;
    _pgStoolConsistencyController.text = record.physicalGenerals.stoolConsistency;
    _pgStoolColourOdourController.text = record.physicalGenerals.stoolColourOdour;
    _pgStoolDifficultiesModalitiesController.text = record.physicalGenerals.stoolDifficultiesModalities.isNotEmpty ? record.physicalGenerals.stoolDifficultiesModalities : record.physicalGenerals.stool;
    _pgUrineFrequencyController.text = record.physicalGenerals.urineFrequency.isNotEmpty ? record.physicalGenerals.urineFrequency : record.physicalGenerals.urine;
    _pgUrineQuantityController.text = record.physicalGenerals.urineQuantity;
    _pgUrineColourOdourController.text = record.physicalGenerals.urineColourOdour;
    _pgUrinarySymptomsController.text = record.physicalGenerals.urinarySymptoms;
    _pgPerspirationQuantityController.text = record.physicalGenerals.perspiration;
    _pgPerspirationOdourController.text = record.physicalGenerals.perspirationOdour;
    _pgPerspirationTimingDistributionController.text = record.physicalGenerals.perspirationTimingDistribution;
    _pgSleepQuantityController.text = record.physicalGenerals.sleepQuantity.isNotEmpty ? record.physicalGenerals.sleepQuantity : record.physicalGenerals.sleep;
    _pgSleepQualityController.text = record.physicalGenerals.sleepQuality;
    _pgSleepPositionController.text = record.physicalGenerals.sleepPosition;
    _pgSleepOnsetController.text = record.physicalGenerals.sleepOnset;
    _pgSleepDisturbancesController.text = record.physicalGenerals.sleepDisturbances;
    _pgDreamsGeneralController.text = record.physicalGenerals.dreams;
    _pgDreamsRecurrentPeculiarController.text = record.physicalGenerals.dreamsRecurrentPeculiar;
    _pgEnergyVitalityController.text = record.physicalGenerals.energyVitality;
    _pgFatigueController.text = record.physicalGenerals.fatigue;
    _pgSexualHistoryController.text = record.physicalGenerals.sexualHistory;
    _pgMenstrualHistoryController.text = record.physicalGenerals.menstrualHistory;
    _pgObstetricHistoryController.text = record.physicalGenerals.obstetricHistory;
    _pgSkinHairNailsController.text = record.physicalGenerals.skinHairNails;
    _pgGeneralDischargesController.text = record.physicalGenerals.generalDischarges;
    _pgOtherPhysicalGeneralsController.text = record.physicalGenerals.otherPhysicalGenerals;

    // 9. Mental Generals
    _mgGeneralMentalEmotionalStateController.text = record.mentalGenerals.generalMentalState;
    _mgDispositionController.text = record.mentalGenerals.disposition;
    _mgIrritabilityController.text = record.mentalGenerals.irritability;
    _mgAngerController.text = record.mentalGenerals.anger;
    _mgAnxietyController.text = record.mentalGenerals.anxiety;
    _mgFearsController.text = record.mentalGenerals.fears;
    _mgSpecificFearsPhobiasController.text = record.mentalGenerals.specificFearsPhobias;
    _mgSadnessGriefController.text = record.mentalGenerals.sadnessGrief;
    _mgDepressionController.text = record.mentalGenerals.depression;
    _mgJealousyController.text = record.mentalGenerals.jealousy;
    _mgSuspicionController.text = record.mentalGenerals.suspicion;
    _mgCompanyDesireAversionController.text = record.mentalGenerals.companyDesireAversion;
    _mgDesireForSolitudeController.text = record.mentalGenerals.desireForSolitude;
    _mgDesireForAttentionConsolationController.text = record.mentalGenerals.desireForAttentionConsolation;
    _mgTalkativenessQuietnessController.text = record.mentalGenerals.talkativenessQuietness;
    _mgConfidenceSelfEsteemController.text = record.mentalGenerals.confidenceSelfEsteem;
    _mgWillDeterminationController.text = record.mentalGenerals.willDetermination;
    _mgIndecisionController.text = record.mentalGenerals.indecision;
    _mgMemoryController.text = record.mentalGenerals.memory;
    _mgConcentrationController.text = record.mentalGenerals.concentration;
    _mgWorkStudyResponseController.text = record.mentalGenerals.workStudyResponse;
    _mgRestlessnessController.text = record.mentalGenerals.restlessness;
    _mgResponseToStressController.text = record.mentalGenerals.responseToStress;
    _mgResponseToContradictionOppositionController.text = record.mentalGenerals.responseToContradictionOpposition;
    _mgResponseToReprimandController.text = record.mentalGenerals.responseToReprimand;
    _mgCompulsionsObsessionsController.text = record.mentalGenerals.compulsionsObsessions;
    _mgOtherCharacteristicMentalSymptomsController.text = record.mentalGenerals.otherCharacteristicMentalSymptoms;

    // 10. Lifestyle
    _plDietController.text = record.lifestyleHabits.diet;
    _plMealPatternController.text = record.lifestyleHabits.mealPattern;
    _plTeaCoffeeController.text = record.lifestyleHabits.teaCoffee;
    _plTobaccoController.text = record.lifestyleHabits.tobacco;
    _plAlcoholController.text = record.lifestyleHabits.alcohol;
    _plOtherSubstanceUseController.text = record.lifestyleHabits.otherSubstanceUse;
    _plPhysicalActivityController.text = record.lifestyleHabits.physicalActivity;
    _plOccupationWorkPatternController.text = record.lifestyleHabits.occupationWorkPattern;
    _plSedentaryBehaviourController.text = record.lifestyleHabits.sedentaryBehaviour;
    _plSleepRoutineController.text = record.lifestyleHabits.sleepRoutine;
    _plPersonalHygieneController.text = record.lifestyleHabits.personalHygiene;
    _plSocialHistoryController.text = record.lifestyleHabits.socialHistory;
    _plFinancialOccupationalStressorsController.text = record.lifestyleHabits.financialOccupationalStressors;
    _plOtherHabitsController.text = record.lifestyleHabits.otherHabits;

    // 11. Clinical Exam & Vitals
    _ceGeneralAppearanceController.text = record.clinicalExam.generalAppearance;
    _ceBuildNutritionController.text = record.clinicalExam.buildNutrition;
    _cePallorController.text = record.clinicalExam.pallor;
    _ceIcterusController.text = record.clinicalExam.icterus;
    _ceCyanosisController.text = record.clinicalExam.cyanosis;
    _ceClubbingController.text = record.clinicalExam.clubbing;
    _ceLymphadenopathyController.text = record.clinicalExam.lymphadenopathy;
    _ceOedemaController.text = record.clinicalExam.oedema;
    _ceTemperatureController.text = record.clinicalExam.temperature;
    _cePulseController.text = record.clinicalExam.pulse;
    _ceBloodPressureController.text = record.clinicalExam.bloodPressure;
    _ceRespiratoryRateController.text = record.clinicalExam.respiratoryRate;
    _ceSpO2Controller.text = record.clinicalExam.spo2;
    _ceWeightController.text = record.clinicalExam.weightKg;
    _ceHeightController.text = record.clinicalExam.heightCm;
    _ceBMIController.text = record.clinicalExam.bmi;
    _ceCVSExaminationController.text = record.clinicalExam.cvsExamination;
    _ceRespiratoryExaminationController.text = record.clinicalExam.respiratoryExamination;
    _ceAbdominalExaminationController.text = record.clinicalExam.abdominalExamination;
    _ceCNSExaminationController.text = record.clinicalExam.cnsExamination;
    _ceMusculoskeletalExaminationController.text = record.clinicalExam.musculoskeletalExamination;
    _ceSkinExaminationController.text = record.clinicalExam.skinExamination;
    _ceENTOralExaminationController.text = record.clinicalExam.entOralExamination;
    _ceOtherExaminationFindingsController.text = record.clinicalExam.otherExaminationFindings;

    // 12. Miasmatic Analysis
    if (record.miasmaticAnalysis.dominantMiasm.isNotEmpty) _maPredominantMiasm = record.miasmaticAnalysis.dominantMiasm;
    _maSecondaryMixedMiasmController.text = record.miasmaticAnalysis.secondaryMixedMiasm;
    _maPsoricFeaturesController.text = record.miasmaticAnalysis.psoricFeatures;
    _maSycoticFeaturesController.text = record.miasmaticAnalysis.sycoticFeatures;
    _maSyphiliticFeaturesController.text = record.miasmaticAnalysis.syphiliticFeatures;
    _maTubercularFeaturesController.text = record.miasmaticAnalysis.tubercularFeatures;
    _maCancerinicFeaturesController.text = record.miasmaticAnalysis.cancerinicFeatures;
    _maOtherMiasmaticIndicatorsController.text = record.miasmaticAnalysis.otherMiasmaticIndicators;
    _maCharacteristicSymptomsSupportingMiasmController.text = record.miasmaticAnalysis.characteristicSymptoms;
    _maFinalMiasmaticInterpretationController.text = record.miasmaticAnalysis.finalMiasmaticInterpretation;

    // 13. Case Analysis
    _caTotalityOfSymptomsController.text = record.caseTotality.totalityOfSymptoms;
    _caCharacteristicSymptomsController.text = record.caseTotality.characteristicSymptoms;
    _caGeneralsController.text = record.caseTotality.generals;
    _caParticularsController.text = record.caseTotality.particulars;
    _caMentalGeneralsController.text = record.caseTotality.mentalGenerals;
    _caPhysicalGeneralsController.text = record.caseTotality.physicalGenerals;
    _caModalitiesController.text = record.caseTotality.modalities;
    _caConcomitantsController.text = record.caseTotality.concomitants;
    _caCausationController.text = record.caseTotality.causation;
    _caRepertoryUsedController.text = record.caseTotality.repertoryUsed;
    _caRubricsSelectedController.text = record.caseTotality.rubricsSelected;
    _caRepertorialResultController.text = record.caseTotality.repertorialResult;
    _caMateriaMedicaCorrelationController.text = record.caseTotality.materiaMedicaCorrelation;
    _caDifferentialRemediesController.text = record.caseTotality.differentialRemedies;
    _caFinalRemedySelectionRationaleController.text = record.caseTotality.finalRemedySelection;

    // 14. Diagnosis
    _diagProvisionalDiagnosisController.text = record.clinicalAssessment.provisionalDiagnosis;
    _diagFinalWorkingDiagnosisController.text = record.clinicalAssessment.finalWorkingDiagnosis;
    _diagDifferentialDiagnosisController.text = record.clinicalAssessment.differentialDiagnosis;
    _diagComorbiditiesController.text = record.clinicalAssessment.comorbidities;
    _diagRedFlagsReferralIndicationsController.text = record.clinicalAssessment.redFlagsReferrals;
    _diagClinicalRemarksController.text = record.clinicalAssessment.clinicalRemarks;

    // 15. Prescription
    _rxPrescriptionDateController.text = Formatters.displayFromDbDate(record.baselinePrescription.prescriptionDate);
    _rxRemedyController.text = record.baselinePrescription.remedyName;
    _rxPotencyController.text = record.baselinePrescription.potency;
    _rxDoseController.text = record.baselinePrescription.dose;
    _rxRepetitionFrequencyController.text = record.baselinePrescription.repetitionFrequency;
    if (record.baselinePrescription.route.isNotEmpty) _rxRouteController.text = record.baselinePrescription.route;
    if (record.baselinePrescription.pharmaceuticalForm.isNotEmpty) _rxPharmaceuticalFormController.text = record.baselinePrescription.pharmaceuticalForm;
    _rxQuantityDispensedController.text = record.baselinePrescription.quantityDispensed;
    _rxDietRegimenAdviceController.text = record.baselinePrescription.dietRegimenAdvice;
    _rxLifestyleAdviceController.text = record.baselinePrescription.lifestyleAdvice;
    _rxInvestigationsAdvisedController.text = record.baselinePrescription.investigationsAdvised;
    _rxReferralAdvisedController.text = record.baselinePrescription.referralAdvised;
    _rxPrescriptionRationaleController.text = record.baselinePrescription.prescriptionRationale;
    _rxPrescriptionNotesController.text = record.baselinePrescription.prescriptionNotes;

    // 16. Investigations
    _invInvestigationDateController.text = Formatters.displayFromDbDate(record.investigations.investigationDate);
    _invInvestigationNameController.text = record.investigations.investigationName;
    _invTypePanelController.text = record.investigations.typePanel;
    _invResultValueController.text = record.investigations.resultValue;
    _invUnitController.text = record.investigations.unit;
    _invReferenceRangeController.text = record.investigations.referenceRange;
    if (record.investigations.normalAbnormal.isNotEmpty) _invNormalAbnormalController.text = record.investigations.normalAbnormal;
    _invReportSummaryController.text = record.investigations.reportSummary;
    _invClinicalInterpretationController.text = record.investigations.clinicalInterpretation;
    _invReportReferenceController.text = record.investigations.reportReference;

    // 17. Follow-up
    _fuFollowUpDateController.text = Formatters.displayFromDbDate(record.followUpDetails.followUpDate);
    _fuIntervalSincePreviousVisitController.text = record.followUpDetails.intervalSincePreviousVisit;
    _fuOverallResponseController.text = record.followUpDetails.overallResponse;
    _fuChiefComplaintChangesController.text = record.followUpDetails.chiefComplaintChanges;
    _fuNewSymptomsController.text = record.followUpDetails.newSymptoms;
    _fuAggravationController.text = record.followUpDetails.aggravation;
    _fuImprovementController.text = record.followUpDetails.improvement;
    _fuGeneralSymptomsChangeController.text = record.followUpDetails.generalSymptomsChange;
    _fuMentalSymptomsChangeController.text = record.followUpDetails.mentalSymptomsChange;
    _fuSleepChangeController.text = record.followUpDetails.sleepChange;
    _fuAppetiteThirstChangeController.text = record.followUpDetails.appetiteThirstChange;
    _fuStoolUrineChangeController.text = record.followUpDetails.stoolUrineChange;
    _fuPerspirationChangeController.text = record.followUpDetails.perspirationChange;
    _fuEnergyChangeController.text = record.followUpDetails.energyChange;
    _fuAdverseNewSymptomsController.text = record.followUpDetails.adverseNewSymptoms;
    _fuFollowUpPrescriptionController.text = record.followUpDetails.followUpPrescription;
    _fuPotencyController.text = record.followUpDetails.potency;
    _fuDoseRepetitionController.text = record.followUpDetails.doseRepetition;
    _fuNextFollowUpController.text = Formatters.displayFromDbDate(record.followUpDetails.nextFollowUp);
    _fuFollowUpRemarksController.text = record.followUpDetails.followUpRemarks.isNotEmpty ? record.followUpDetails.followUpRemarks : record.followUpNotes;

    // 18. Outcome
    if (record.outcomeDetails.finalStatus.isNotEmpty) {
      _outFinalStatus = record.outcomeDetails.finalStatus;
    } else if (record.outcome.isNotEmpty) {
      _outFinalStatus = record.outcome;
    }
    _outDegreeOfImprovementController.text = record.outcomeDetails.degreeOfImprovement;
    _outTreatmentDurationController.text = record.outcomeDetails.treatmentDuration;
    _outReasonForDiscontinuationClosureController.text = record.outcomeDetails.reasonForDiscontinuation;
    _outLostToFollowUpController.text = record.outcomeDetails.lostToFollowUp;
    _outFinalOutcomeNotesController.text = record.outcomeDetails.finalOutcomeNotes;

    // 19. Documentation
    _docDataSourceController.text = record.documentation.dataSource;
    _docOriginalRegisterReferenceController.text = record.documentation.originalRegisterReference;
    _docTranscriptionNotesController.text = record.documentation.transcriptionNotes;
    _docUnclearInformationController.text = record.documentation.unclearInformation;

    for (final entry in _complaints) {
      _attachComplaintListeners(entry);
    }
    _isPopulating = false;
    _isDirty = false;
  }

  void _addComplaintBlock() {
    final entry = _ComplaintEntry();
    _attachComplaintListeners(entry);
    setState(() {
      _complaints.add(entry);
      _isDirty = true;
    });
    AppHaptics.light();
  }

  void _removeComplaintBlock(int index) {
    if (_complaints.length <= 1) return;
    setState(() {
      final removed = _complaints.removeAt(index);
      removed.dispose();
      _isDirty = true;
    });
    AppHaptics.selection();
  }

  void _jumpToSection(int index) {
    AppHaptics.selection();
    // If target section is collapsed, expand it automatically on jump
    if (_collapsedSections.contains(index)) {
      setState(() {
        _collapsedSections.remove(index);
      });
    }
    final keyContext = _sectionKeys[index].currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: Motion.base,
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  void _toggleSection(int index) {
    setState(() {
      if (_collapsedSections.contains(index)) {
        _collapsedSections.remove(index);
      } else {
        _collapsedSections.add(index);
      }
    });
    AppHaptics.light();
  }

  void _toggleAllSections() {
    setState(() {
      if (_collapsedSections.length == _sectionTitles.length) {
        _collapsedSections.clear();
      } else {
        _collapsedSections.addAll(List.generate(_sectionTitles.length, (i) => i));
      }
    });
    AppHaptics.selection();
  }

  Future<void> _saveRecord() async {
    setState(() => _saving = true);

    final record = MasterCaseRecordData(
      patientId: widget.patient.id,
      recordDate: DateTime.now(),
      identification: PatientIdentificationDetails(
        regNo: _regNoController.text.trim(),
        firstVisitDate: Formatters.toDbDateString(_firstVisitDateController.text),
        patientName: _patientNameController.text.trim(),
        age: _ageController.text.trim(),
        gender: _genderController.text.trim(),
        dob: Formatters.toDbDateString(_dobController.text),
        occupation: _occupationController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        maritalStatus: _maritalStatus,
      ),
      chiefComplaints: _complaints.map((c) => ChiefComplaintDetail(
        complaint: c.complaint.text.trim(),
        location: c.location.text.trim(),
        onset: c.onset.text.trim(),
        duration: c.duration.text.trim(),
        sensation: c.sensation.text.trim(),
        extensionRadiation: c.extensionRadiation.text.trim(),
        modalitiesAgg: c.agg.text.trim(),
        modalitiesAmel: c.amel.text.trim(),
        concomitants: c.concomitant.text.trim(),
        causation: c.causation.text.trim(),
        periodicity: c.periodicity.text.trim(),
        time: c.time.text.trim(),
        severity: c.severity,
        associatedSymptoms: c.associatedSymptoms.text.trim(),
      )).toList(),
      additionalComplaints: _additionalComplaintsController.text.trim(),
      hpi: HpiDetails(
        chronologicalDevelopment: _hpiChronoDevController.text.trim(),
        firstOccurrence: _hpiFirstOccurrenceController.text.trim(),
        progression: _hpiProgressionController.text.trim(),
        previousEpisodes: _hpiPreviousEpisodesController.text.trim(),
        previousTreatment: _hpiPreviousTreatmentController.text.trim(),
        responseToTreatment: _hpiResponseToTreatmentController.text.trim(),
        relevantPrecipitatingFactors: _hpiPrecipitatingFactorsController.text.trim(),
        otherRelevantHistory: _hpiOtherRelevantHistoryController.text.trim(),
      ),
      pastHistory: PastHistoryDetails(
        childhoodIllnesses: _pastChildhoodIllnessesController.text.trim(),
        majorIllnesses: _pastMajorIllnessesController.text.trim(),
        chronicDiseases: _pastChronicDiseasesController.text.trim(),
        surgeries: _pastSurgeriesController.text.trim(),
        injuriesTrauma: _pastInjuriesTraumaController.text.trim(),
        hospitalisations: _pastHospitalisationsController.text.trim(),
        infections: _pastInfectionsController.text.trim(),
        allergies: _pastAllergiesController.text.trim(),
        previousMedications: _pastPreviousMedicationsController.text.trim(),
        previousHomeopathicTreatment: _pastPrevHomeopathicTreatmentController.text.trim(),
        otherPastHistory: _pastOtherPastHistoryController.text.trim(),
      ),
      familyHistory: FamilyHistoryDetails(
        father: _familyFatherController.text.trim(),
        mother: _familyMotherController.text.trim(),
        siblings: _familySiblingsController.text.trim(),
        spouse: _familySpouseController.text.trim(),
        children: _familyChildrenController.text.trim(),
        grandparentsRelatives: _familyGrandparentsRelativesController.text.trim(),
        hereditaryDiseases: _familyHereditaryDiseasesController.text.trim(),
        majorFamilialDiseases: _familyMajorFamilialDiseasesController.text.trim(),
        psychiatricHistory: _familyPsychiatricHistoryController.text.trim(),
        otherFamilyHistory: _familyOtherFamilyHistoryController.text.trim(),
      ),
      developmentalHistory: DevelopmentalHistoryDetails(
        maternalHealth: _devMaternalHealthController.text.trim(),
        pregnancyComplications: _devPregnancyComplicationsController.text.trim(),
        maternalInfections: _devMaternalInfectionsController.text.trim(),
        maternalMedications: _devMaternalMedicationsController.text.trim(),
        antenatalCare: _devAntenatalCareController.text.trim(),
        nutritionDuringPregnancy: _devNutritionDuringPregnancyController.text.trim(),
        gestationalAge: _devGestationalAgeController.text.trim(),
        birthOrder: _devBirthOrderController.text.trim(),
        modeOfDelivery: _devModeOfDeliveryController.text.trim(),
        birthWeight: _devBirthWeightController.text.trim(),
        neonatalHistory: _devNeonatalHistoryController.text.trim(),
        breastfeeding: _devBreastfeedingController.text.trim(),
        developmentalMilestones: _devDevelopmentalMilestonesController.text.trim(),
        childhoodDevelopment: _devChildhoodDevelopmentController.text.trim(),
        otherBirthDevelopmentalHistory: _devOtherBirthDevelopmentalHistoryController.text.trim(),
      ),
      physicalGenerals: PhysicalGenerals(
        thermal: _pgHotChillyController.text.trim(),
        hotChilly: _pgHotChillyController.text.trim(),
        weatherPreference: _pgWeatherSeasonPreferenceController.text.trim(),
        sensitivityToTemperature: _pgSensitivityToTemperatureController.text.trim(),
        thirst: _pgThirstQuantityController.text.trim(),
        thirstFrequency: _pgThirstFrequencyController.text.trim(),
        thirstTiming: _pgThirstTimingController.text.trim(),
        appetite: _pgAppetiteController.text.trim(),
        hungerFasting: _pgHungerFastingController.text.trim(),
        cravings: _pgFoodDesiresController.text.trim(),
        aversions: _pgFoodAversionsController.text.trim(),
        intolerances: _pgFoodIntolerancesController.text.trim(),
        stool: _pgStoolDifficultiesModalitiesController.text.trim(),
        stoolFrequency: _pgStoolFrequencyController.text.trim(),
        stoolConsistency: _pgStoolConsistencyController.text.trim(),
        stoolColourOdour: _pgStoolColourOdourController.text.trim(),
        stoolDifficultiesModalities: _pgStoolDifficultiesModalitiesController.text.trim(),
        urine: _pgUrineFrequencyController.text.trim(),
        urineFrequency: _pgUrineFrequencyController.text.trim(),
        urineQuantity: _pgUrineQuantityController.text.trim(),
        urineColourOdour: _pgUrineColourOdourController.text.trim(),
        urinarySymptoms: _pgUrinarySymptomsController.text.trim(),
        perspiration: _pgPerspirationQuantityController.text.trim(),
        perspirationOdour: _pgPerspirationOdourController.text.trim(),
        perspirationTimingDistribution: _pgPerspirationTimingDistributionController.text.trim(),
        sleep: _pgSleepQuantityController.text.trim(),
        sleepQuantity: _pgSleepQuantityController.text.trim(),
        sleepQuality: _pgSleepQualityController.text.trim(),
        sleepPosition: _pgSleepPositionController.text.trim(),
        sleepOnset: _pgSleepOnsetController.text.trim(),
        sleepDisturbances: _pgSleepDisturbancesController.text.trim(),
        dreams: _pgDreamsGeneralController.text.trim(),
        dreamsRecurrentPeculiar: _pgDreamsRecurrentPeculiarController.text.trim(),
        energyVitality: _pgEnergyVitalityController.text.trim(),
        fatigue: _pgFatigueController.text.trim(),
        sexualHistory: _pgSexualHistoryController.text.trim(),
        menstrualHistory: _pgMenstrualHistoryController.text.trim(),
        obstetricHistory: _pgObstetricHistoryController.text.trim(),
        skinHairNails: _pgSkinHairNailsController.text.trim(),
        generalDischarges: _pgGeneralDischargesController.text.trim(),
        otherPhysicalGenerals: _pgOtherPhysicalGeneralsController.text.trim(),
      ),
      mentalGenerals: MentalGenerals(
        generalMentalState: _mgGeneralMentalEmotionalStateController.text.trim(),
        disposition: _mgDispositionController.text.trim(),
        irritability: _mgIrritabilityController.text.trim(),
        anger: _mgAngerController.text.trim(),
        anxiety: _mgAnxietyController.text.trim(),
        fears: _mgFearsController.text.trim(),
        specificFearsPhobias: _mgSpecificFearsPhobiasController.text.trim(),
        sadnessGrief: _mgSadnessGriefController.text.trim(),
        depression: _mgDepressionController.text.trim(),
        jealousy: _mgJealousyController.text.trim(),
        suspicion: _mgSuspicionController.text.trim(),
        companyDesireAversion: _mgCompanyDesireAversionController.text.trim(),
        desireForSolitude: _mgDesireForSolitudeController.text.trim(),
        desireForAttentionConsolation: _mgDesireForAttentionConsolationController.text.trim(),
        talkativenessQuietness: _mgTalkativenessQuietnessController.text.trim(),
        confidenceSelfEsteem: _mgConfidenceSelfEsteemController.text.trim(),
        willDetermination: _mgWillDeterminationController.text.trim(),
        indecision: _mgIndecisionController.text.trim(),
        memory: _mgMemoryController.text.trim(),
        concentration: _mgConcentrationController.text.trim(),
        workStudyResponse: _mgWorkStudyResponseController.text.trim(),
        restlessness: _mgRestlessnessController.text.trim(),
        responseToStress: _mgResponseToStressController.text.trim(),
        responseToContradictionOpposition: _mgResponseToContradictionOppositionController.text.trim(),
        responseToReprimand: _mgResponseToReprimandController.text.trim(),
        compulsionsObsessions: _mgCompulsionsObsessionsController.text.trim(),
        otherCharacteristicMentalSymptoms: _mgOtherCharacteristicMentalSymptomsController.text.trim(),
      ),
      lifestyleHabits: LifestyleHistoryDetails(
        diet: _plDietController.text.trim(),
        mealPattern: _plMealPatternController.text.trim(),
        teaCoffee: _plTeaCoffeeController.text.trim(),
        tobacco: _plTobaccoController.text.trim(),
        alcohol: _plAlcoholController.text.trim(),
        otherSubstanceUse: _plOtherSubstanceUseController.text.trim(),
        physicalActivity: _plPhysicalActivityController.text.trim(),
        occupationWorkPattern: _plOccupationWorkPatternController.text.trim(),
        sedentaryBehaviour: _plSedentaryBehaviourController.text.trim(),
        sleepRoutine: _plSleepRoutineController.text.trim(),
        personalHygiene: _plPersonalHygieneController.text.trim(),
        socialHistory: _plSocialHistoryController.text.trim(),
        financialOccupationalStressors: _plFinancialOccupationalStressorsController.text.trim(),
        otherHabits: _plOtherHabitsController.text.trim(),
      ),
      clinicalExam: ClinicalExamVitals(
        generalAppearance: _ceGeneralAppearanceController.text.trim(),
        buildNutrition: _ceBuildNutritionController.text.trim(),
        pallor: _cePallorController.text.trim(),
        icterus: _ceIcterusController.text.trim(),
        cyanosis: _ceCyanosisController.text.trim(),
        clubbing: _ceClubbingController.text.trim(),
        lymphadenopathy: _ceLymphadenopathyController.text.trim(),
        oedema: _ceOedemaController.text.trim(),
        temperature: _ceTemperatureController.text.trim(),
        pulse: _cePulseController.text.trim(),
        bloodPressure: _ceBloodPressureController.text.trim(),
        respiratoryRate: _ceRespiratoryRateController.text.trim(),
        spo2: _ceSpO2Controller.text.trim(),
        weightKg: _ceWeightController.text.trim(),
        heightCm: _ceHeightController.text.trim(),
        bmi: _ceBMIController.text.trim(),
        cvsExamination: _ceCVSExaminationController.text.trim(),
        respiratoryExamination: _ceRespiratoryExaminationController.text.trim(),
        abdominalExamination: _ceAbdominalExaminationController.text.trim(),
        cnsExamination: _ceCNSExaminationController.text.trim(),
        musculoskeletalExamination: _ceMusculoskeletalExaminationController.text.trim(),
        skinExamination: _ceSkinExaminationController.text.trim(),
        entOralExamination: _ceENTOralExaminationController.text.trim(),
        otherExaminationFindings: _ceOtherExaminationFindingsController.text.trim(),
      ),
      miasmaticAnalysis: MiasmaticAnalysis(
        dominantMiasm: _maPredominantMiasm,
        secondaryMixedMiasm: _maSecondaryMixedMiasmController.text.trim(),
        psoricFeatures: _maPsoricFeaturesController.text.trim(),
        sycoticFeatures: _maSycoticFeaturesController.text.trim(),
        syphiliticFeatures: _maSyphiliticFeaturesController.text.trim(),
        tubercularFeatures: _maTubercularFeaturesController.text.trim(),
        cancerinicFeatures: _maCancerinicFeaturesController.text.trim(),
        otherMiasmaticIndicators: _maOtherMiasmaticIndicatorsController.text.trim(),
        characteristicSymptoms: _maCharacteristicSymptomsSupportingMiasmController.text.trim(),
        finalMiasmaticInterpretation: _maFinalMiasmaticInterpretationController.text.trim(),
      ),
      caseTotality: CaseTotality(
        totalityOfSymptoms: _caTotalityOfSymptomsController.text.trim(),
        characteristicSymptoms: _caCharacteristicSymptomsController.text.trim(),
        generals: _caGeneralsController.text.trim(),
        particulars: _caParticularsController.text.trim(),
        mentalGenerals: _caMentalGeneralsController.text.trim(),
        physicalGenerals: _caPhysicalGeneralsController.text.trim(),
        modalities: _caModalitiesController.text.trim(),
        concomitants: _caConcomitantsController.text.trim(),
        causation: _caCausationController.text.trim(),
        repertoryUsed: _caRepertoryUsedController.text.trim(),
        rubricsSelected: _caRubricsSelectedController.text.trim(),
        repertorialResult: _caRepertorialResultController.text.trim(),
        materiaMedicaCorrelation: _caMateriaMedicaCorrelationController.text.trim(),
        differentialRemedies: _caDifferentialRemediesController.text.trim(),
        finalRemedySelection: _caFinalRemedySelectionRationaleController.text.trim(),
      ),
      clinicalAssessment: ClinicalAssessmentDetails(
        provisionalDiagnosis: _diagProvisionalDiagnosisController.text.trim(),
        finalWorkingDiagnosis: _diagFinalWorkingDiagnosisController.text.trim(),
        differentialDiagnosis: _diagDifferentialDiagnosisController.text.trim(),
        comorbidities: _diagComorbiditiesController.text.trim(),
        redFlagsReferrals: _diagRedFlagsReferralIndicationsController.text.trim(),
        clinicalRemarks: _diagClinicalRemarksController.text.trim(),
      ),
      baselinePrescription: PrescriptionPlanDetails(
        prescriptionDate: Formatters.toDbDateString(_rxPrescriptionDateController.text),
        remedyName: _rxRemedyController.text.trim(),
        potency: _rxPotencyController.text.trim(),
        dose: _rxDoseController.text.trim(),
        repetitionFrequency: _rxRepetitionFrequencyController.text.trim(),
        route: _rxRouteController.text.trim(),
        pharmaceuticalForm: _rxPharmaceuticalFormController.text.trim(),
        quantityDispensed: _rxQuantityDispensedController.text.trim(),
        dietRegimenAdvice: _rxDietRegimenAdviceController.text.trim(),
        lifestyleAdvice: _rxLifestyleAdviceController.text.trim(),
        investigationsAdvised: _rxInvestigationsAdvisedController.text.trim(),
        referralAdvised: _rxReferralAdvisedController.text.trim(),
        prescriptionRationale: _rxPrescriptionRationaleController.text.trim(),
        prescriptionNotes: _rxPrescriptionNotesController.text.trim(),
      ),
      investigations: InvestigationsPlanDetails(
        investigationDate: Formatters.toDbDateString(_invInvestigationDateController.text),
        investigationName: _invInvestigationNameController.text.trim(),
        typePanel: _invTypePanelController.text.trim(),
        resultValue: _invResultValueController.text.trim(),
        unit: _invUnitController.text.trim(),
        referenceRange: _invReferenceRangeController.text.trim(),
        normalAbnormal: _invNormalAbnormalController.text.trim(),
        reportSummary: _invReportSummaryController.text.trim(),
        clinicalInterpretation: _invClinicalInterpretationController.text.trim(),
        reportReference: _invReportReferenceController.text.trim(),
      ),
      followUpDetails: FollowUpDetails(
        followUpDate: Formatters.toDbDateString(_fuFollowUpDateController.text),
        intervalSincePreviousVisit: _fuIntervalSincePreviousVisitController.text.trim(),
        overallResponse: _fuOverallResponseController.text.trim(),
        chiefComplaintChanges: _fuChiefComplaintChangesController.text.trim(),
        newSymptoms: _fuNewSymptomsController.text.trim(),
        aggravation: _fuAggravationController.text.trim(),
        improvement: _fuImprovementController.text.trim(),
        generalSymptomsChange: _fuGeneralSymptomsChangeController.text.trim(),
        mentalSymptomsChange: _fuMentalSymptomsChangeController.text.trim(),
        sleepChange: _fuSleepChangeController.text.trim(),
        appetiteThirstChange: _fuAppetiteThirstChangeController.text.trim(),
        stoolUrineChange: _fuStoolUrineChangeController.text.trim(),
        perspirationChange: _fuPerspirationChangeController.text.trim(),
        energyChange: _fuEnergyChangeController.text.trim(),
        adverseNewSymptoms: _fuAdverseNewSymptomsController.text.trim(),
        followUpPrescription: _fuFollowUpPrescriptionController.text.trim(),
        potency: _fuPotencyController.text.trim(),
        doseRepetition: _fuDoseRepetitionController.text.trim(),
        nextFollowUp: Formatters.toDbDateString(_fuNextFollowUpController.text),
        followUpRemarks: _fuFollowUpRemarksController.text.trim(),
      ),
      followUpNotes: _fuFollowUpRemarksController.text.trim(),
      outcomeDetails: OutcomeDetails(
        finalStatus: _outFinalStatus,
        degreeOfImprovement: _outDegreeOfImprovementController.text.trim(),
        treatmentDuration: _outTreatmentDurationController.text.trim(),
        reasonForDiscontinuation: _outReasonForDiscontinuationClosureController.text.trim(),
        lostToFollowUp: _outLostToFollowUpController.text.trim(),
        finalOutcomeNotes: _outFinalOutcomeNotesController.text.trim(),
      ),
      outcome: _outFinalStatus,
      documentation: DocumentationDetails(
        dataSource: _docDataSourceController.text.trim(),
        originalRegisterReference: _docOriginalRegisterReferenceController.text.trim(),
        transcriptionNotes: _docTranscriptionNotesController.text.trim(),
        unclearInformation: _docUnclearInformationController.text.trim(),
      ),
    );

    try {
      await ref.read(caseRecordNotifierProvider.notifier).saveCaseRecord(record);
      AppHaptics.success();
      if (mounted) {
        setState(() => _isDirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case record saved successfully')),
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

        final isEditing = existingRecord != null;
        final title = isEditing ? 'Edit Case' : 'Case Taking';
        final saveLabel = isEditing ? 'Save Changes' : 'Save Case';
        final allCollapsed = _collapsedSections.length == _sectionTitles.length;

        return PopScope(
          canPop: !_isDirty || _saving,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final discard = await AppConfirmDialog.show(
              context,
              title: 'Unsaved Changes',
              message: 'You have unsaved changes. What would you like to do?',
              confirmLabel: 'Discard Changes',
              cancelLabel: 'Keep Editing',
              isDestructive: true,
            );
            if (discard == true && context.mounted) {
              setState(() => _isDirty = false);
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              actions: [
                IconButton(
                  icon: Icon(allCollapsed ? Icons.unfold_more : Icons.unfold_less),
                  tooltip: allCollapsed ? 'Expand All' : 'Collapse All',
                  onPressed: _toggleAllSections,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.md, left: Spacing.xs),
                  child: AppButton.primary(
                    label: saveLabel,
                    icon: Icons.check,
                    loading: _saving,
                    onPressed: _saving ? null : _saveRecord,
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // Sticky Quick Navigation Horizontal Bar
                _buildQuickJumpBar(),
                const Divider(height: 1),

                // Main Form ListView
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.xxl),
                    itemCount: _sectionTitles.length,
                    itemBuilder: (context, index) => _buildSectionByIndex(index),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickJumpBar() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      height: 48,
      color: scheme.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
        itemCount: _sectionTitles.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
        itemBuilder: (context, index) {
          final isCollapsed = _collapsedSections.contains(index);
          final numStr = (index + 1).toString().padLeft(2, '0');

          return InkWell(
            borderRadius: Radii.pillAll,
            onTap: () => _jumpToSection(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
              decoration: BoxDecoration(
                color: isCollapsed ? scheme.surfaceContainerHighest.withValues(alpha: 0.5) : scheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: Radii.pillAll,
                border: Border.all(
                  color: isCollapsed ? scheme.outlineVariant : scheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    numStr,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCollapsed ? scheme.onSurfaceVariant : scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sectionTitles[index],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCollapsed ? scheme.onSurfaceVariant : scheme.onPrimaryContainer,
                      fontWeight: isCollapsed ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionByIndex(int index) {
    switch (index) {
      case 0:
        return _buildSectionCard(
          index: 0,
          sectionNum: '01',
          title: 'Patient Identification',
          icon: Icons.badge_outlined,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(_regNoController, 'Registration No.', Icons.numbers)),
                const SizedBox(width: Spacing.md),
                Expanded(child: DateField(controller: _firstVisitDateController, label: 'First Visit Date')),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_patientNameController, 'Patient Full Name', Icons.person_outline),
            const SizedBox(height: Spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInput(_ageController, 'Age', Icons.cake_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: PickerField<String>(
                    label: 'Gender',
                    prefixIcon: Icons.wc_outlined,
                    value: _genderController.text.isNotEmpty ? _genderController.text : 'Male',
                    options: const [
                      PickerOption(value: 'Male', label: 'Male'),
                      PickerOption(value: 'Female', label: 'Female'),
                      PickerOption(value: 'Other', label: 'Other'),
                    ],
                    onChanged: (v) => setState(() => _genderController.text = v),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: PickerField<String>(
                    label: 'Marital Status',
                    prefixIcon: Icons.favorite_border,
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
                Expanded(child: DateField(controller: _dobController, label: 'Date of Birth')),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_occupationController, 'Occupation', Icons.work_outline)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(flex: 2, child: _buildInput(_addressController, 'Address / Locality', Icons.home_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(flex: 2, child: _buildInput(_phoneController, 'Phone Number', Icons.phone_outlined)),
              ],
            ),
          ],
        );

      case 1:
        return _buildSectionCard(
          index: 1,
          sectionNum: '02',
          title: 'Chief Complaints (${_complaints.length})',
          icon: Icons.healing_outlined,
          children: [
            for (int i = 0; i < _complaints.length; i++) ...[
              _buildComplaintCard(i),
              if (i < _complaints.length - 1) const SizedBox(height: Spacing.md),
            ],
            const SizedBox(height: Spacing.md),
            AppButton.outlined(
              label: 'Add Another Chief Complaint',
              icon: Icons.add,
              fullWidth: true,
              onPressed: _addComplaintBlock,
            ),
          ],
        );

      case 2:
        return _buildSectionCard(
          index: 2,
          sectionNum: '03',
          title: 'Additional Complaints',
          icon: Icons.note_add_outlined,
          children: [
            _buildInput(_additionalComplaintsController, 'Additional Complaints / Secondary Notes', Icons.notes_outlined, 3),
          ],
        );

      case 3:
        return _buildSectionCard(
          index: 3,
          sectionNum: '04',
          title: 'History of Present Illness (HPI)',
          icon: Icons.timeline_outlined,
          children: [
            _buildInput(_hpiChronoDevController, 'Chronological Development', Icons.show_chart, 2),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_hpiFirstOccurrenceController, 'First Occurrence', Icons.history)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_hpiProgressionController, 'Progression & Pace', Icons.trending_up)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_hpiPreviousEpisodesController, 'Previous Episodes', Icons.repeat),
            const SizedBox(height: Spacing.md),
            _buildInput(_hpiPreviousTreatmentController, 'Previous Treatment', Icons.medication_outlined),
            const SizedBox(height: Spacing.md),
            _buildInput(_hpiResponseToTreatmentController, 'Response to Previous Treatment', Icons.feedback_outlined),
            const SizedBox(height: Spacing.md),
            _buildInput(_hpiPrecipitatingFactorsController, 'Precipitating / Trigger Factors', Icons.psychology_outlined),
            const SizedBox(height: Spacing.md),
            _buildInput(_hpiOtherRelevantHistoryController, 'Other Relevant History', Icons.info_outline),
          ],
        );

      case 4:
        return _buildSectionCard(
          index: 4,
          sectionNum: '05',
          title: 'Past Medical History',
          icon: Icons.medical_information_outlined,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(_pastChildhoodIllnessesController, 'Childhood Illnesses', Icons.child_care)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pastMajorIllnessesController, 'Major Illnesses', Icons.coronavirus_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pastChronicDiseasesController, 'Chronic Diseases', Icons.health_and_safety_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pastSurgeriesController, 'Operations / Surgeries', Icons.local_hospital_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pastInjuriesTraumaController, 'Injuries / Trauma', Icons.personal_injury_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pastHospitalisationsController, 'Hospitalisations', Icons.hotel_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pastInfectionsController, 'Infections', Icons.pest_control_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pastAllergiesController, 'Allergies', Icons.warning_amber_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pastPreviousMedicationsController, 'Previous Medications', Icons.medication)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pastPrevHomeopathicTreatmentController, 'Previous Homeopathy', Icons.science_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_pastOtherPastHistoryController, 'Other Past History', Icons.description_outlined),
          ],
        );

      case 5:
        return _buildSectionCard(
          index: 5,
          sectionNum: '06',
          title: 'Family History',
          icon: Icons.groups_outlined,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(_familyFatherController, 'Father', Icons.person)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_familyMotherController, 'Mother', Icons.person_2)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_familySiblingsController, 'Siblings', Icons.group)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_familySpouseController, 'Spouse', Icons.favorite_border)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_familyChildrenController, 'Children', Icons.family_restroom)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_familyGrandparentsRelativesController, 'Grandparents & Other Relatives', Icons.elderly_outlined),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_familyHereditaryDiseasesController, 'Hereditary Diseases', Icons.biotech_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_familyMajorFamilialDiseasesController, 'Familial Diseases (HTN, DM, TB)', Icons.analytics_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_familyPsychiatricHistoryController, 'Psychiatric Family History', Icons.psychology_alt_outlined),
            const SizedBox(height: Spacing.md),
            _buildInput(_familyOtherFamilyHistoryController, 'Other Family History', Icons.notes),
          ],
        );

      case 6:
        return _buildSectionCard(
          index: 6,
          sectionNum: '07',
          title: 'Intrauterine & Developmental History',
          icon: Icons.child_friendly_outlined,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(_devMaternalHealthController, 'Maternal Health in Pregnancy', Icons.pregnant_woman)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_devPregnancyComplicationsController, 'Pregnancy Complications', Icons.report_problem_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_devMaternalInfectionsController, 'Maternal Infections', Icons.bug_report_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_devMaternalMedicationsController, 'Maternal Medications', Icons.medication_liquid)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_devAntenatalCareController, 'Antenatal Care', Icons.medical_services_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_devNutritionDuringPregnancyController, 'Maternal Nutrition', Icons.restaurant)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_devGestationalAgeController, 'Gestational Age / Term', Icons.access_time)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_devBirthOrderController, 'Birth Order', Icons.format_list_numbered)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_devModeOfDeliveryController, 'Mode of Delivery', Icons.local_hospital)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_devBirthWeightController, 'Birth Weight', Icons.monitor_weight_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_devNeonatalHistoryController, 'Neonatal History / Cry', Icons.baby_changing_station)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_devBreastfeedingController, 'Breastfeeding History', Icons.water_drop_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_devDevelopmentalMilestonesController, 'Milestones (Teething, Walking, Talking)', Icons.emoji_events_outlined),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_devChildhoodDevelopmentController, 'Childhood Development', Icons.school_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_devOtherBirthDevelopmentalHistoryController, 'Other Developmental Notes', Icons.more_horiz)),
              ],
            ),
          ],
        );

      case 7:
        return _buildSectionCard(
          index: 7,
          sectionNum: '08',
          title: 'Physical Generals',
          icon: Icons.accessibility_new_outlined,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PickerField<String>(
                    label: 'Thermal State',
                    value: _pgHotChillyController.text.isNotEmpty ? _pgHotChillyController.text : 'Ambithermal',
                    options: const [
                      PickerOption(value: 'Chilly', label: 'Chilly (Sensitive to Cold)'),
                      PickerOption(value: 'Hot', label: 'Hot (Sensitive to Heat)'),
                      PickerOption(value: 'Ambithermal', label: 'Ambithermal (Equal)'),
                    ],
                    onChanged: (v) => setState(() => _pgHotChillyController.text = v),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgWeatherSeasonPreferenceController, 'Weather / Season Preference', Icons.wb_sunny_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_pgSensitivityToTemperatureController, 'Temperature Sensitivities', Icons.thermostat_outlined),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgAppetiteController, 'Appetite', Icons.restaurant_menu)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgHungerFastingController, 'Hunger & Fasting', Icons.hourglass_empty)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgThirstQuantityController, 'Thirst Quantity', Icons.local_drink)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgThirstFrequencyController, 'Thirst Frequency', Icons.timelapse)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgThirstTimingController, 'Thirst Timing', Icons.schedule)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgFoodDesiresController, 'Cravings / Desires', Icons.favorite)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgFoodAversionsController, 'Food Aversions', Icons.do_not_disturb)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_pgFoodIntolerancesController, 'Food Intolerances & Aggravations', Icons.no_food),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgStoolFrequencyController, 'Stool Frequency', Icons.repeat)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgStoolConsistencyController, 'Stool Consistency', Icons.grain)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgStoolColourOdourController, 'Stool Colour / Odour', Icons.palette_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_pgStoolDifficultiesModalitiesController, 'Stool Difficulties & Modalities', Icons.airline_seat_legroom_reduced),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgUrineFrequencyController, 'Urine Frequency', Icons.speed)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgUrineQuantityController, 'Urine Quantity', Icons.opacity)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgUrineColourOdourController, 'Urine Colour / Odour', Icons.water)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_pgUrinarySymptomsController, 'Urinary Symptoms', Icons.water_drop),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgPerspirationQuantityController, 'Perspiration Quantity', Icons.dew_point)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgPerspirationOdourController, 'Perspiration Odour', Icons.air)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_pgPerspirationTimingDistributionController, 'Perspiration Timing & Distribution', Icons.map_outlined),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgSleepQuantityController, 'Sleep Hours', Icons.bedtime)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgSleepQualityController, 'Sleep Quality', Icons.hotel)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgSleepPositionController, 'Sleep Position', Icons.airline_seat_flat)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgSleepOnsetController, 'Sleep Onset', Icons.nights_stay)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgSleepDisturbancesController, 'Sleep Disturbances', Icons.alarm_off)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgDreamsGeneralController, 'Dreams (General)', Icons.cloud_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgDreamsRecurrentPeculiarController, 'Recurrent / Peculiar Dreams', Icons.auto_awesome)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgEnergyVitalityController, 'Energy & Vitality', Icons.bolt)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgFatigueController, 'Fatigue Modalities', Icons.battery_alert)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgSexualHistoryController, 'Sexual History', Icons.favorite_outline)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgMenstrualHistoryController, 'Menstrual History', Icons.calendar_month)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgObstetricHistoryController, 'Obstetric History', Icons.child_care)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgSkinHairNailsController, 'Skin, Hair & Nails', Icons.face)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_pgGeneralDischargesController, 'General Discharges', Icons.waterfall_chart)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_pgOtherPhysicalGeneralsController, 'Other Physical Generals', Icons.more_horiz)),
              ],
            ),
          ],
        );

      case 8:
        return _buildSectionCard(
          index: 8,
          sectionNum: '09',
          title: 'Mental & Emotional Generals',
          icon: Icons.psychology_outlined,
          children: [
            _buildInput(_mgGeneralMentalEmotionalStateController, 'General Mental & Emotional State', Icons.psychology, 2),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgDispositionController, 'Disposition / Nature', Icons.sentiment_satisfied)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgIrritabilityController, 'Irritability', Icons.sentiment_dissatisfied)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgAngerController, 'Anger & Temper', Icons.sentiment_very_dissatisfied)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgAnxietyController, 'Anxiety', Icons.healing)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgFearsController, 'Fears', Icons.visibility_off)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_mgSpecificFearsPhobiasController, 'Specific Fears & Phobias', Icons.warning),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgSadnessGriefController, 'Sadness & Grief', Icons.mood_bad)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgDepressionController, 'Depression', Icons.cloud)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgJealousyController, 'Jealousy & Envy', Icons.compare)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgSuspicionController, 'Suspicion', Icons.search)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgCompanyDesireAversionController, 'Company (Desire/Aversion)', Icons.groups)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgDesireForSolitudeController, 'Desire for Solitude', Icons.person_outline)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgDesireForAttentionConsolationController, 'Consolation Response', Icons.volunteer_activism)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgTalkativenessQuietnessController, 'Loquacity / Quietness', Icons.record_voice_over)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgConfidenceSelfEsteemController, 'Confidence / Self-Esteem', Icons.star_border)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgWillDeterminationController, 'Will & Determination', Icons.fitness_center)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgIndecisionController, 'Indecision & Doubt', Icons.help_outline)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgMemoryController, 'Memory & Recall', Icons.memory)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgConcentrationController, 'Concentration & Focus', Icons.center_focus_strong)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgWorkStudyResponseController, 'Work / Study Response', Icons.work_outline)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgRestlessnessController, 'Restlessness', Icons.directions_run)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgResponseToStressController, 'Stress Handling', Icons.spa)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgResponseToContradictionOppositionController, 'Reaction to Contradiction', Icons.gavel)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_mgResponseToReprimandController, 'Reaction to Reprimand', Icons.announcement)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_mgCompulsionsObsessionsController, 'Obsessions / Compulsions', Icons.sync)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_mgOtherCharacteristicMentalSymptomsController, 'Other Characteristic Mentals', Icons.psychology_alt),
          ],
        );

      case 9:
        return _buildSectionCard(
          index: 9,
          sectionNum: '10',
          title: 'Lifestyle, Habits & Environment',
          icon: Icons.local_cafe_outlined,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(_plDietController, 'Dietary Preference', Icons.restaurant)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_plMealPatternController, 'Meal Timings & Habits', Icons.schedule)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_plTeaCoffeeController, 'Tea / Coffee', Icons.coffee)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_plTobaccoController, 'Tobacco / Smoking', Icons.smoking_rooms)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_plAlcoholController, 'Alcohol Intake', Icons.local_bar)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_plOtherSubstanceUseController, 'Other Substance Use', Icons.medication)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_plPhysicalActivityController, 'Physical Activity', Icons.directions_walk)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_plOccupationWorkPatternController, 'Work Pattern & Shifts', Icons.work_history)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_plSedentaryBehaviourController, 'Sedentary Behaviour', Icons.chair)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_plSleepRoutineController, 'Sleep Routine', Icons.bedtime)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_plPersonalHygieneController, 'Personal Hygiene', Icons.clean_hands)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_plSocialHistoryController, 'Social & Living History', Icons.people_outline)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_plFinancialOccupationalStressorsController, 'Financial / Work Stressors', Icons.attach_money)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_plOtherHabitsController, 'Other Habits & Environment', Icons.more_horiz),
          ],
        );

      case 10:
        return _buildSectionCard(
          index: 10,
          sectionNum: '11',
          title: 'Clinical Examination & Vitals',
          icon: Icons.monitor_heart_outlined,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(_ceGeneralAppearanceController, 'General Appearance', Icons.person)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceBuildNutritionController, 'Build & Nutrition', Icons.fitness_center)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_ceBloodPressureController, 'Blood Pressure (mmHg)', Icons.speed)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_cePulseController, 'Pulse (bpm)', Icons.favorite)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceTemperatureController, 'Temperature (°F)', Icons.thermostat)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_ceRespiratoryRateController, 'Resp Rate (/min)', Icons.air)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceSpO2Controller, 'SpO2 (%)', Icons.bubble_chart)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceWeightController, 'Weight (kg)', Icons.scale)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_ceHeightController, 'Height (cm)', Icons.height)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceBMIController, 'BMI', Icons.calculate)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_cePallorController, 'Pallor', Icons.circle_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceIcterusController, 'Icterus', Icons.circle_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceCyanosisController, 'Cyanosis', Icons.circle_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_ceClubbingController, 'Clubbing', Icons.circle_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceLymphadenopathyController, 'Lymphadenopathy', Icons.circle_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceOedemaController, 'Oedema', Icons.circle_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_ceCVSExaminationController, 'Cardiovascular (CVS)', Icons.monitor_heart)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceRespiratoryExaminationController, 'Respiratory (RS)', Icons.air)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_ceAbdominalExaminationController, 'Abdomen (GIT)', Icons.airline_seat_flat_angled)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceCNSExaminationController, 'Central Nervous (CNS)', Icons.psychology)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_ceMusculoskeletalExaminationController, 'Musculoskeletal', Icons.accessibility)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceSkinExaminationController, 'Skin & Nails', Icons.pan_tool)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_ceENTOralExaminationController, 'ENT & Oral Cavity', Icons.hearing)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_ceOtherExaminationFindingsController, 'Other Findings', Icons.more_horiz)),
              ],
            ),
          ],
        );

      case 11:
        return _buildSectionCard(
          index: 11,
          sectionNum: '12',
          title: 'Miasmatic Analysis',
          icon: Icons.bubble_chart_outlined,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PickerField<String>(
                    label: 'Dominant Miasm',
                    value: _maPredominantMiasm,
                    options: const [
                      PickerOption(value: 'Psora', label: 'Psora (Functional)'),
                      PickerOption(value: 'Sycosis', label: 'Sycosis (Productive/Proliferative)'),
                      PickerOption(value: 'Tubercular', label: 'Tubercular (Suppurative/Recurrent)'),
                      PickerOption(value: 'Syphilitic', label: 'Syphilitic (Destructive/Degenerative)'),
                      PickerOption(value: 'Mixed Miasm', label: 'Mixed / Complex Miasm'),
                    ],
                    onChanged: (v) => setState(() => _maPredominantMiasm = v),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_maSecondaryMixedMiasmController, 'Secondary / Mixed Miasm', Icons.shuffle)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_maPsoricFeaturesController, 'Psoric Features', Icons.circle)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_maSycoticFeaturesController, 'Sycotic Features', Icons.circle)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_maSyphiliticFeaturesController, 'Syphilitic Features', Icons.circle)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_maTubercularFeaturesController, 'Tubercular Features', Icons.circle)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_maCancerinicFeaturesController, 'Cancerinic Features', Icons.circle)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_maOtherMiasmaticIndicatorsController, 'Other Miasm Indicators', Icons.more_horiz)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_maCharacteristicSymptomsSupportingMiasmController, 'Characteristic Supporting Symptoms', Icons.check_circle_outline, 2),
            const SizedBox(height: Spacing.md),
            _buildInput(_maFinalMiasmaticInterpretationController, 'Final Miasmatic Interpretation', Icons.auto_stories_outlined, 2),
          ],
        );

      case 12:
        return _buildSectionCard(
          index: 12,
          sectionNum: '13',
          title: 'Case Totality & Repertorisation',
          icon: Icons.menu_book_outlined,
          children: [
            _buildInput(_caTotalityOfSymptomsController, 'Totality of Symptoms', Icons.list_alt, 3),
            const SizedBox(height: Spacing.md),
            _buildInput(_caCharacteristicSymptomsController, 'Characteristic Symptoms (PQRS)', Icons.star_outline, 2),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_caGeneralsController, 'Generals', Icons.public)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_caParticularsController, 'Particulars', Icons.pin_drop)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_caMentalGeneralsController, 'Mental Generals', Icons.psychology)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_caPhysicalGeneralsController, 'Physical Generals', Icons.accessibility)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_caModalitiesController, 'Modalities (< / >)', Icons.swap_vert)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_caConcomitantsController, 'Concomitants', Icons.link)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_caCausationController, 'Causation / Origin', Icons.lightbulb_outline)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_caRepertoryUsedController, 'Repertory Used', Icons.library_books)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_caRubricsSelectedController, 'Selected Rubrics', Icons.bookmarks_outlined, 2),
            const SizedBox(height: Spacing.md),
            _buildInput(_caRepertorialResultController, 'Repertorial Result & Scores', Icons.assessment_outlined),
            const SizedBox(height: Spacing.md),
            _buildInput(_caMateriaMedicaCorrelationController, 'Materia Medica Correlation', Icons.menu_book),
            const SizedBox(height: Spacing.md),
            _buildInput(_caDifferentialRemediesController, 'Differential Remedies', Icons.compare_arrows),
            const SizedBox(height: Spacing.md),
            _buildInput(_caFinalRemedySelectionRationaleController, 'Final Selection Rationale', Icons.thumb_up_alt_outlined, 2),
          ],
        );

      case 13:
        return _buildSectionCard(
          index: 13,
          sectionNum: '14',
          title: 'Clinical Assessment & Diagnosis',
          icon: Icons.fact_check_outlined,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(_diagProvisionalDiagnosisController, 'Provisional Diagnosis', Icons.assignment_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_diagFinalWorkingDiagnosisController, 'Final Working Diagnosis', Icons.check_box_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_diagDifferentialDiagnosisController, 'Differential Diagnosis', Icons.mediation)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_diagComorbiditiesController, 'Comorbidities', Icons.health_and_safety)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_diagRedFlagsReferralIndicationsController, 'Red Flags & Referral Indications', Icons.warning_amber_rounded),
            const SizedBox(height: Spacing.md),
            _buildInput(_diagClinicalRemarksController, 'Clinical Remarks & Observations', Icons.comment_outlined, 2),
          ],
        );

      case 14:
        return _buildSectionCard(
          index: 14,
          sectionNum: '15',
          title: 'Baseline Prescription & Management',
          icon: Icons.medication_outlined,
          children: [
            Row(
              children: [
                Expanded(child: DateField(controller: _rxPrescriptionDateController, label: 'Prescription Date')),
                const SizedBox(width: Spacing.md),
                Expanded(flex: 2, child: _buildInput(_rxRemedyController, 'Remedy Prescribed', Icons.healing)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_rxPotencyController, 'Potency & Scale', Icons.science)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_rxDoseController, 'Dose', Icons.medical_information)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_rxRepetitionFrequencyController, 'Repetition Frequency', Icons.repeat)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_rxQuantityDispensedController, 'Quantity Dispensed', Icons.inventory_2_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_rxRouteController, 'Route', Icons.alt_route)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_rxPharmaceuticalFormController, 'Form (Globules/Drops)', Icons.medication_liquid)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_rxDietRegimenAdviceController, 'Diet & Regimen Advice', Icons.restaurant, 2),
            const SizedBox(height: Spacing.md),
            _buildInput(_rxLifestyleAdviceController, 'Lifestyle & Auxiliary Advice', Icons.nature_people, 2),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_rxInvestigationsAdvisedController, 'Investigations Advised', Icons.science_outlined)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_rxReferralAdvisedController, 'Referral Advised', Icons.transfer_within_a_station)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_rxPrescriptionRationaleController, 'Prescription Rationale', Icons.psychology),
            const SizedBox(height: Spacing.md),
            _buildInput(_rxPrescriptionNotesController, 'Prescription Notes', Icons.notes),
          ],
        );

      case 15:
        return _buildSectionCard(
          index: 15,
          sectionNum: '16',
          title: 'Investigations & Laboratory Findings',
          icon: Icons.biotech_outlined,
          children: [
            Row(
              children: [
                Expanded(child: DateField(controller: _invInvestigationDateController, label: 'Investigation Date')),
                const SizedBox(width: Spacing.md),
                Expanded(flex: 2, child: _buildInput(_invInvestigationNameController, 'Test / Panel Name', Icons.science)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_invTypePanelController, 'Type / Category', Icons.category)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_invResultValueController, 'Result Value', Icons.numbers)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_invUnitController, 'Unit', Icons.straighten)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInput(_invReferenceRangeController, 'Reference Range', Icons.compare_arrows)),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: PickerField<String>(
                    label: 'Status',
                    prefixIcon: Icons.check_circle_outline,
                    value: _invNormalAbnormalController.text.isNotEmpty ? _invNormalAbnormalController.text : 'Normal',
                    options: const [
                      PickerOption(value: 'Normal', label: 'Normal'),
                      PickerOption(value: 'Abnormal', label: 'Abnormal'),
                      PickerOption(value: 'Borderline', label: 'Borderline'),
                      PickerOption(value: 'Critical', label: 'Critical'),
                    ],
                    onChanged: (v) => setState(() => _invNormalAbnormalController.text = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_invReportSummaryController, 'Report Summary', Icons.summarize, 2),
            const SizedBox(height: Spacing.md),
            _buildInput(_invClinicalInterpretationController, 'Clinical Interpretation', Icons.insights),
            const SizedBox(height: Spacing.md),
            _buildInput(_invReportReferenceController, 'Report / Lab Reference No.', Icons.tag),
          ],
        );

      case 16:
        return _buildSectionCard(
          index: 16,
          sectionNum: '17',
          title: 'Follow-Up Details',
          icon: Icons.update_outlined,
          children: [
            Row(
              children: [
                Expanded(child: DateField(controller: _fuFollowUpDateController, label: 'Follow-Up Date')),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuIntervalSincePreviousVisitController, 'Interval', Icons.hourglass_bottom)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuOverallResponseController, 'Overall Response', Icons.thumb_up_alt_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_fuChiefComplaintChangesController, 'Chief Complaint Changes', Icons.change_circle_outlined, 2),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_fuImprovementController, 'Improvement Noted', Icons.trending_up)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuAggravationController, 'Aggravation Noted', Icons.trending_down)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_fuNewSymptomsController, 'New Symptoms Appeared', Icons.fiber_new_outlined),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_fuGeneralSymptomsChangeController, 'Generals Change', Icons.accessibility)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuMentalSymptomsChangeController, 'Mentals Change', Icons.psychology)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_fuSleepChangeController, 'Sleep Change', Icons.bedtime)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuAppetiteThirstChangeController, 'Appetite & Thirst Change', Icons.restaurant)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_fuStoolUrineChangeController, 'Bowels & Urine Change', Icons.water_drop)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuPerspirationChangeController, 'Perspiration Change', Icons.dew_point)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_fuEnergyChangeController, 'Energy Change', Icons.bolt)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuAdverseNewSymptomsController, 'Adverse / Unwanted Symptoms', Icons.warning_amber)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(flex: 2, child: _buildInput(_fuFollowUpPrescriptionController, 'Follow-Up Remedy', Icons.medication)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuPotencyController, 'Potency', Icons.science)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_fuDoseRepetitionController, 'Dose & Repetition', Icons.repeat)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: DateField(controller: _fuNextFollowUpController, label: 'Next Follow-Up Target')),
                const SizedBox(width: Spacing.md),
                Expanded(flex: 2, child: _buildInput(_fuFollowUpRemarksController, 'Follow-Up Remarks & Notes', Icons.comment)),
              ],
            ),
          ],
        );

      case 17:
        return _buildSectionCard(
          index: 17,
          sectionNum: '18',
          title: 'Outcome & Treatment Closure',
          icon: Icons.task_alt_outlined,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PickerField<String>(
                    label: 'Final Treatment Status',
                    value: _outFinalStatus,
                    options: const [
                      PickerOption(value: 'Under Active Treatment', label: 'Under Active Treatment'),
                      PickerOption(value: 'Ongoing', label: 'Ongoing Active Treatment'),
                      PickerOption(value: 'Recovered / Cured', label: 'Recovered / Cured'),
                      PickerOption(value: 'Improved', label: 'Significantly Improved'),
                      PickerOption(value: 'No Change', label: 'No Significant Change'),
                      PickerOption(value: 'Worse', label: 'Worse / Deteriorated'),
                      PickerOption(value: 'Discontinued', label: 'Discontinued / Closed'),
                      PickerOption(value: 'Lost to Follow-up', label: 'Lost to Follow-Up'),
                    ],
                    onChanged: (v) => setState(() => _outFinalStatus = v),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_outDegreeOfImprovementController, 'Degree of Improvement (%)', Icons.percent)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(child: _buildInput(_outTreatmentDurationController, 'Total Treatment Duration', Icons.timer)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_outReasonForDiscontinuationClosureController, 'Reason for Closure', Icons.cancel_outlined)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_outLostToFollowUpController, 'Lost to Follow-Up Details', Icons.person_off_outlined),
            const SizedBox(height: Spacing.md),
            _buildInput(_outFinalOutcomeNotesController, 'Final Outcome Summary & Clinical Notes', Icons.notes_outlined, 3),
          ],
        );

      case 18:
        return _buildSectionCard(
          index: 18,
          sectionNum: '19',
          title: 'Documentation & Archival Details',
          icon: Icons.inventory_outlined,
          children: [
            Row(
              children: [
                Expanded(child: _buildInput(_docDataSourceController, 'Data Source / Register Type', Icons.source)),
                const SizedBox(width: Spacing.md),
                Expanded(child: _buildInput(_docOriginalRegisterReferenceController, 'Original Register Ref', Icons.tag)),
              ],
            ),
            const SizedBox(height: Spacing.md),
            _buildInput(_docTranscriptionNotesController, 'Transcription Notes', Icons.edit_note, 2),
            const SizedBox(height: Spacing.md),
            _buildInput(_docUnclearInformationController, 'Unclear / Discrepant Information', Icons.help_outline),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSectionCard({
    required int index,
    required String sectionNum,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isCollapsed = _collapsedSections.contains(index);

    return Container(
      key: _sectionKeys[index],
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: AppCard(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _toggleSection(index),
              borderRadius: Radii.smAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
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
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Icon(
                      isCollapsed ? Icons.expand_more : Icons.expand_less,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (!isCollapsed) ...[
              const SizedBox(height: Spacing.sm),
              const Divider(height: 1),
              const SizedBox(height: Spacing.md),
              ...children,
            ],
          ],
        ),
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
          _buildInput(entry.complaint, 'Complaint', Icons.healing),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.location, 'Location', Icons.place_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.sensation, 'Sensation / Character', Icons.touch_app_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.onset, 'Onset', Icons.play_arrow_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.duration, 'Duration', Icons.timer_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.agg, 'Aggravation (< Modality)', Icons.arrow_upward_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.amel, 'Amelioration (> Modality)', Icons.arrow_downward_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.extensionRadiation, 'Radiation / Extension', Icons.alt_route_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.concomitant, 'Concomitants', Icons.link)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.causation, 'Causation / Origin', Icons.psychology_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.periodicity, 'Periodicity', Icons.event_repeat_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInput(entry.time, 'Time Modality', Icons.alarm_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: PickerField<String>(
                  label: 'Severity',
                  prefixIcon: Icons.speed,
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
          const SizedBox(height: Spacing.md),
          _buildInput(entry.associatedSymptoms, 'Associated Symptoms', Icons.summarize_outlined),
        ],
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, [
    IconData? icon,
    int maxLines = 1,
  ]) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: scheme.onSurfaceVariant)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
