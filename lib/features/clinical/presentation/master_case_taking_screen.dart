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

  // 1. Patient Identification (10 fields)
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

  // 7. Intrauterine, Birth & Developmental History (15 fields)
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

  // 8. Physical Generals - Complete (38 fields)
  String _pgThermalState = 'Ambithermal';
  final _pgHotChillyController = TextEditingController();
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

  // 9. Mental Generals - Complete (27 fields)
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

  // 10. Personal & Lifestyle History (14 fields)
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

  // 11. Clinical Examination (24 fields)
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
  String _maPredominantMiasm = 'Mixed / Dynamic';
  final _maSecondaryMixedMiasmController = TextEditingController();
  final _maPsoricFeaturesController = TextEditingController();
  final _maSycoticFeaturesController = TextEditingController();
  final _maSyphiliticFeaturesController = TextEditingController();
  final _maTubercularFeaturesController = TextEditingController();
  final _maCancerinicFeaturesController = TextEditingController();
  final _maOtherMiasmaticIndicatorsController = TextEditingController();
  final _maCharacteristicSymptomsSupportingMiasmController = TextEditingController();
  final _maFinalMiasmaticInterpretationController = TextEditingController();

  // 13. Case Analysis (15 fields)
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

  // 14. Diagnosis / Clinical Assessment (6 fields)
  final _diagProvisionalDiagnosisController = TextEditingController();
  final _diagFinalWorkingDiagnosisController = TextEditingController();
  final _diagDifferentialDiagnosisController = TextEditingController();
  final _diagComorbiditiesController = TextEditingController();
  final _diagRedFlagsReferralIndicationsController = TextEditingController();
  final _diagClinicalRemarksController = TextEditingController();

  // 15. Prescription (14 fields)
  final _rxPrescriptionDateController = TextEditingController();
  final _rxRemedyController = TextEditingController();
  final _rxPotencyController = TextEditingController();
  final _rxDoseController = TextEditingController();
  final _rxRepetitionFrequencyController = TextEditingController();
  final _rxRouteController = TextEditingController();
  final _rxPharmaceuticalFormController = TextEditingController();
  final _rxQuantityDispensedController = TextEditingController();
  final _rxDietRegimenAdviceController = TextEditingController();
  final _rxLifestyleAdviceController = TextEditingController();
  final _rxInvestigationsAdvisedController = TextEditingController();
  final _rxReferralAdvisedController = TextEditingController();
  final _rxPrescriptionRationaleController = TextEditingController();
  final _rxPrescriptionNotesController = TextEditingController();

  // 16. Investigation (10 fields)
  final _invInvestigationDateController = TextEditingController();
  final _invInvestigationNameController = TextEditingController();
  final _invTypePanelController = TextEditingController();
  final _invResultValueController = TextEditingController();
  final _invUnitController = TextEditingController();
  final _invReferenceRangeController = TextEditingController();
  final _invNormalAbnormalController = TextEditingController();
  final _invReportSummaryController = TextEditingController();
  final _invClinicalInterpretationController = TextEditingController();
  final _invReportReferenceController = TextEditingController();

  // 17. Follow-up (20 fields)
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

  // 18. Outcome (6 fields)
  String _outFinalStatus = 'Under Active Treatment';
  final _outDegreeOfImprovementController = TextEditingController();
  final _outTreatmentDurationController = TextEditingController();
  final _outReasonForDiscontinuationClosureController = TextEditingController();
  final _outLostToFollowUpController = TextEditingController();
  final _outFinalOutcomeNotesController = TextEditingController();

  // 19. Documentation (4 fields)
  final _docDataSourceController = TextEditingController();
  final _docOriginalRegisterReferenceController = TextEditingController();
  final _docTranscriptionNotesController = TextEditingController();
  final _docUnclearInformationController = TextEditingController();

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
    _docDataSourceController.text = 'Original handwritten clinic register / dictated case record';
    _docOriginalRegisterReferenceController.text = 'Registration No. ${widget.patient.serialNo.isNotEmpty ? widget.patient.serialNo : widget.patient.patientCode}';
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

    // 1. Identification
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

    // 7. Dev History
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
    _pgThermalState = record.physicalGenerals.thermal;
    _pgHotChillyController.text = record.physicalGenerals.hotChilly;
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
    _pgStoolDifficultiesModalitiesController.text = record.physicalGenerals.stoolDifficultiesModalities;
    _pgUrineFrequencyController.text = record.physicalGenerals.urineFrequency;
    _pgUrineQuantityController.text = record.physicalGenerals.urineQuantity;
    _pgUrineColourOdourController.text = record.physicalGenerals.urineColourOdour;
    _pgUrinarySymptomsController.text = record.physicalGenerals.urinarySymptoms;
    _pgPerspirationQuantityController.text = record.physicalGenerals.perspiration;
    _pgPerspirationOdourController.text = record.physicalGenerals.perspirationOdour;
    _pgPerspirationTimingDistributionController.text = record.physicalGenerals.perspirationTimingDistribution;
    _pgSleepQuantityController.text = record.physicalGenerals.sleepQuantity;
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

    // 11. Clinical Exam
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
    _maPredominantMiasm = record.miasmaticAnalysis.dominantMiasm;
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
    _rxPrescriptionDateController.text = record.baselinePrescription.prescriptionDate;
    _rxRemedyController.text = record.baselinePrescription.remedyName;
    _rxPotencyController.text = record.baselinePrescription.potency;
    _rxDoseController.text = record.baselinePrescription.dose;
    _rxRepetitionFrequencyController.text = record.baselinePrescription.repetitionFrequency;
    _rxRouteController.text = record.baselinePrescription.route;
    _rxPharmaceuticalFormController.text = record.baselinePrescription.pharmaceuticalForm;
    _rxQuantityDispensedController.text = record.baselinePrescription.quantityDispensed;
    _rxDietRegimenAdviceController.text = record.baselinePrescription.dietRegimenAdvice;
    _rxLifestyleAdviceController.text = record.baselinePrescription.lifestyleAdvice;
    _rxInvestigationsAdvisedController.text = record.baselinePrescription.investigationsAdvised;
    _rxReferralAdvisedController.text = record.baselinePrescription.referralAdvised;
    _rxPrescriptionRationaleController.text = record.baselinePrescription.prescriptionRationale;
    _rxPrescriptionNotesController.text = record.baselinePrescription.prescriptionNotes;

    // 16. Investigations
    _invInvestigationDateController.text = record.investigations.investigationDate;
    _invInvestigationNameController.text = record.investigations.investigationName;
    _invTypePanelController.text = record.investigations.typePanel;
    _invResultValueController.text = record.investigations.resultValue;
    _invUnitController.text = record.investigations.unit;
    _invReferenceRangeController.text = record.investigations.referenceRange;
    _invNormalAbnormalController.text = record.investigations.normalAbnormal;
    _invReportSummaryController.text = record.investigations.reportSummary;
    _invClinicalInterpretationController.text = record.investigations.clinicalInterpretation;
    _invReportReferenceController.text = record.investigations.reportReference;

    // 17. Follow-up
    _fuFollowUpDateController.text = record.followUpDetails.followUpDate;
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
    _fuNextFollowUpController.text = record.followUpDetails.nextFollowUp;
    _fuFollowUpRemarksController.text = record.followUpDetails.followUpRemarks.isNotEmpty ? record.followUpDetails.followUpRemarks : record.followUpNotes;

    // 18. Outcome
    _outFinalStatus = record.outcomeDetails.finalStatus.isNotEmpty ? record.outcomeDetails.finalStatus : record.outcome;
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
        thermal: _pgThermalState,
        hotChilly: _pgHotChillyController.text.trim().isNotEmpty ? _pgHotChillyController.text.trim() : _pgThermalState,
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
        prescriptionDate: _rxPrescriptionDateController.text.trim(),
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
        investigationDate: _invInvestigationDateController.text.trim(),
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
        followUpDate: _fuFollowUpDateController.text.trim(),
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
        nextFollowUp: _fuNextFollowUpController.text.trim(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete Master Case Record saved successfully!')),
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
            title: Text('Complete Case Taking • ${widget.patient.name}'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: FilledButton.icon(
                  onPressed: _saving ? null : _saveRecord,
                  icon: _saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Case'),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              // 1. PATIENT IDENTIFICATION
              _buildSectionCard(
                sectionNum: '01',
                title: '1. Patient Identification',
                icon: Icons.badge_outlined,
                subtitle: 'Demographics, contact & registration details',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput(_regNoController, 'Registration Number (e.g. 001)', Icons.numbers)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_firstVisitDateController, 'Date of First Visit', Icons.calendar_today_outlined)),
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

              // 2. CHIEF COMPLAINTS
              _buildSectionCard(
                sectionNum: '02',
                title: '2. Chief Complaints (${_complaints.length} Relational Block${_complaints.length > 1 ? 's' : ''})',
                icon: Icons.healing_outlined,
                subtitle: 'Presenting complaints with location, onset, duration, sensation, modalities & severity',
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

              // 3. ADDITIONAL COMPLAINTS
              _buildSectionCard(
                sectionNum: '03',
                title: '3. Additional Complaints',
                icon: Icons.note_add_outlined,
                subtitle: 'Other concomitant or secondary physical complaints dictated',
                children: [
                  _buildInput(_additionalComplaintsController, 'Additional Complaint / Notes', Icons.notes, 2),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 4. HISTORY OF PRESENT ILLNESS
              _buildSectionCard(
                sectionNum: '04',
                title: '4. History of Present Illness (HPI)',
                icon: Icons.history_edu_outlined,
                subtitle: 'Chronological development, onset, progression, previous episodes & prior treatments',
                children: [
                  _buildInput(_hpiChronoDevController, 'Chronological Development', Icons.timeline, 2),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_hpiFirstOccurrenceController, 'First Occurrence', Icons.event_repeat)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_hpiProgressionController, 'Progression', Icons.trending_up)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_hpiPreviousEpisodesController, 'Previous Episodes', Icons.repeat),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_hpiPreviousTreatmentController, 'Previous Treatment (e.g. Thuja -> Rhus tox -> Kalmia -> Nux Vomica)', Icons.medication_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_hpiResponseToTreatmentController, 'Response to Previous Treatment', Icons.rate_review_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_hpiPrecipitatingFactorsController, 'Relevant Precipitating Factors (Cold air, work posture, etc.)', Icons.psychology_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_hpiOtherRelevantHistoryController, 'Other Relevant History', Icons.info_outline),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 5. PAST MEDICAL HISTORY
              _buildSectionCard(
                sectionNum: '05',
                title: '5. Past History',
                icon: Icons.medical_services_outlined,
                subtitle: 'Childhood illnesses, major diseases, surgeries, trauma, allergies & treatments',
                children: [
                  _buildInput(_pastChildhoodIllnessesController, 'Childhood Illnesses', Icons.child_care_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastMajorIllnessesController, 'Major Illnesses', Icons.coronavirus_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastChronicDiseasesController, 'Chronic Diseases (e.g. Uncontrolled Type 2 Diabetes Mellitus)', Icons.health_and_safety_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastSurgeriesController, 'Operations / Surgeries', Icons.local_hospital_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastInjuriesTraumaController, 'Injuries / Trauma', Icons.personal_injury_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastHospitalisationsController, 'Hospitalisations', Icons.hotel_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastInfectionsController, 'Infections', Icons.bug_report_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastAllergiesController, 'Allergies', Icons.warning_amber_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastPreviousMedicationsController, 'Previous Medications', Icons.medication_liquid_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastPrevHomeopathicTreatmentController, 'Previous Homeopathic Treatment', Icons.history),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pastOtherPastHistoryController, 'Other Past History (History of rectal abscess, frequent gastric trouble)', Icons.description_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 6. FAMILY MEDICAL HISTORY
              _buildSectionCard(
                sectionNum: '06',
                title: '6. Family History',
                icon: Icons.family_restroom_outlined,
                subtitle: 'Father, mother, siblings, spouse, children, grandparents, hereditary & psychiatric history',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput(_familyFatherController, 'Father', Icons.man_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_familyMotherController, 'Mother', Icons.woman_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_familySiblingsController, 'Siblings', Icons.people_outline)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_familySpouseController, 'Spouse', Icons.favorite_outline)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_familyChildrenController, 'Children', Icons.child_friendly_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familyGrandparentsRelativesController, 'Grandparents / Other Relatives', Icons.group_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familyHereditaryDiseasesController, 'Hereditary Diseases', Icons.hub_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familyMajorFamilialDiseasesController, 'Diabetes / Hypertension / TB / Cancer / Other Relevant Diseases', Icons.biotech_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familyPsychiatricHistoryController, 'Mental / Psychiatric Family History', Icons.psychology_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_familyOtherFamilyHistoryController, 'Other Family History', Icons.info_outline),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 7. INTRAUTERINE, BIRTH & DEVELOPMENTAL HISTORY
              _buildSectionCard(
                sectionNum: '07',
                title: '7. Intrauterine, Birth & Developmental History',
                icon: Icons.sentiment_satisfied_alt_outlined,
                subtitle: 'Maternal pregnancy health, delivery mode, milestones, breastfeeding & development',
                children: [
                  _buildInput(_devMaternalHealthController, 'Maternal Health During Pregnancy', Icons.pregnant_woman_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_devPregnancyComplicationsController, 'Pregnancy Complications', Icons.medical_information_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_devMaternalInfectionsController, 'Maternal Infections', Icons.coronavirus_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_devMaternalMedicationsController, 'Maternal Medications', Icons.medication_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_devAntenatalCareController, 'Antenatal Care', Icons.health_and_safety_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_devNutritionDuringPregnancyController, 'Nutrition During Pregnancy', Icons.restaurant_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_devGestationalAgeController, 'Gestational Age', Icons.calendar_month_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_devBirthOrderController, 'Birth Order', Icons.format_list_numbered_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_devModeOfDeliveryController, 'Mode of Delivery', Icons.child_friendly_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_devBirthWeightController, 'Birth Weight', Icons.scale_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_devNeonatalHistoryController, 'Neonatal History', Icons.baby_changing_station_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_devBreastfeedingController, 'Breastfeeding', Icons.water_drop_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_devDevelopmentalMilestonesController, 'Developmental Milestones', Icons.directions_walk_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_devChildhoodDevelopmentController, 'Childhood Development', Icons.school_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_devOtherBirthDevelopmentalHistoryController, 'Other Birth / Developmental History', Icons.description_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 8. PHYSICAL GENERALS — COMPLETE
              _buildSectionCard(
                sectionNum: '08',
                title: '8. Physical Generals – Complete',
                icon: Icons.accessibility_new_outlined,
                subtitle: 'Thermal state, thirst, appetite, cravings, aversions, stool, urine, sweat, sleep & discharges',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PickerField<String>(
                          label: 'Thermal State',
                          value: _pgThermalState,
                          options: const [
                            PickerOption(value: 'Hot', label: 'Hot'),
                            PickerOption(value: 'Chilly', label: 'Chilly'),
                            PickerOption(value: 'Ambithermal', label: 'Ambithermal'),
                          ],
                          onChanged: (v) => setState(() => _pgThermalState = v),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgHotChillyController, 'Hot / Chilly', Icons.thermostat_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgWeatherSeasonPreferenceController, 'Weather / Season Preference (Prefers winter)', Icons.wb_sunny_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgSensitivityToTemperatureController, 'Sensitivity to Temperature', Icons.device_thermostat_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgThirstQuantityController, 'Thirst – Quantity (Profuse; drinks a lot)', Icons.water_drop_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgThirstFrequencyController, 'Thirst – Frequency', Icons.schedule)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgThirstTimingController, 'Thirst – Timing', Icons.alarm)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgAppetiteController, 'Appetite (Good)', Icons.restaurant_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgHungerFastingController, 'Hunger / Fasting', Icons.alarm_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgFoodDesiresController, 'Food Desires (Sweet; tea; fruits; fresh fish; rice)', Icons.fastfood_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgFoodAversionsController, 'Food Aversions', Icons.no_food_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgFoodIntolerancesController, 'Food Intolerances', Icons.warning_amber_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgStoolFrequencyController, 'Stool – Frequency', Icons.format_list_bulleted_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgStoolConsistencyController, 'Stool – Consistency', Icons.grain_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgStoolColourOdourController, 'Stool – Colour / Odour', Icons.palette_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgStoolDifficultiesModalitiesController, 'Stool – Difficulties / Modalities (History of tight/hard stool)', Icons.airline_seat_legroom_reduced_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgUrineFrequencyController, 'Urine – Frequency', Icons.water_damage_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgUrineQuantityController, 'Urine – Quantity', Icons.water_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgUrineColourOdourController, 'Urine – Colour / Odour', Icons.color_lens_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgUrinarySymptomsController, 'Urinary Symptoms', Icons.bloodtype_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgPerspirationQuantityController, 'Perspiration – Quantity (Profuse)', Icons.waterfall_chart_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgPerspirationOdourController, 'Perspiration – Odour (Offensive)', Icons.air_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgPerspirationTimingDistributionController, 'Perspiration – Timing / Distribution', Icons.timelapse)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgSleepQuantityController, 'Sleep – Quantity', Icons.bedtime_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgSleepQualityController, 'Sleep – Quality', Icons.hotel_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgSleepPositionController, 'Sleep – Position', Icons.airline_seat_flat_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgSleepOnsetController, 'Sleep – Onset', Icons.access_time_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgSleepDisturbancesController, 'Sleep – Disturbances (Sleep disturbed due to excessive gas)', Icons.nights_stay_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgDreamsGeneralController, 'Dreams – General', Icons.cloud_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgDreamsRecurrentPeculiarController, 'Dreams – Recurrent / Peculiar', Icons.auto_awesome_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgEnergyVitalityController, 'Energy / Vitality', Icons.bolt_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgFatigueController, 'Fatigue', Icons.battery_charging_full_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_pgSexualHistoryController, 'Sexual History', Icons.wc_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgMenstrualHistoryController, 'Menstrual History', Icons.water_drop_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_pgObstetricHistoryController, 'Obstetric History', Icons.pregnant_woman_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgSkinHairNailsController, 'Skin / Hair / Nails', Icons.brush_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgGeneralDischargesController, 'General Discharges', Icons.opacity_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_pgOtherPhysicalGeneralsController, "Other Physical Generals (Burning eyes; headache associated with [unclear: 'can't tolerate'])", Icons.info_outline),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 9. MENTAL GENERALS — COMPLETE
              _buildSectionCard(
                sectionNum: '09',
                title: '9. Mental Generals – Complete',
                icon: Icons.psychology_outlined,
                subtitle: 'Disposition, anger, fears, depression, intellect, will, memory & emotional modalities',
                children: [
                  _buildInput(_mgGeneralMentalEmotionalStateController, 'General Mental / Emotional State', Icons.psychology),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_mgDispositionController, 'Disposition', Icons.person_search_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgIrritabilityController, 'Irritability', Icons.sentiment_dissatisfied_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgAngerController, 'Anger', Icons.sentiment_very_dissatisfied_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgAnxietyController, 'Anxiety', Icons.crisis_alert_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgFearsController, 'Fears', Icons.warning_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgSpecificFearsPhobiasController, 'Specific Fears / Phobias', Icons.shield_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgSadnessGriefController, 'Sadness / Grief', Icons.sentiment_neutral_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgDepressionController, 'Depression', Icons.sentiment_very_dissatisfied)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgJealousyController, 'Jealousy', Icons.visibility_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgSuspicionController, 'Suspicion', Icons.find_in_page_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgCompanyDesireAversionController, 'Company – Desire / Aversion', Icons.groups_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgDesireForSolitudeController, 'Desire for Solitude', Icons.person_outline)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgDesireForAttentionConsolationController, 'Desire for Attention / Consolation', Icons.favorite_outline)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgTalkativenessQuietnessController, 'Talkativeness / Quietness', Icons.record_voice_over_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgConfidenceSelfEsteemController, 'Confidence / Self-esteem', Icons.psychology_alt_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgWillDeterminationController, 'Will / Determination', Icons.fitness_center_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgIndecisionController, 'Indecision', Icons.help_outline)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgMemoryController, 'Memory', Icons.memory_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgConcentrationController, 'Concentration', Icons.center_focus_strong_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgWorkStudyResponseController, 'Work / Study Response', Icons.school_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgRestlessnessController, 'Restlessness', Icons.directions_run_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_mgResponseToStressController, 'Response to Stress', Icons.electric_bolt_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_mgResponseToContradictionOppositionController, 'Response to Contradiction / Opposition', Icons.compare_arrows_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_mgResponseToReprimandController, 'Response to Reprimand', Icons.announcement_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_mgCompulsionsObsessionsController, 'Compulsions / Obsessions', Icons.repeat_on_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_mgOtherCharacteristicMentalSymptomsController, 'Other Characteristic Mental Symptoms', Icons.notes_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 10. PERSONAL & LIFESTYLE HISTORY
              _buildSectionCard(
                sectionNum: '10',
                title: '10. Personal & Lifestyle History',
                icon: Icons.self_improvement_outlined,
                subtitle: 'Diet, habits, tea, tobacco, alcohol, exercise, occupation, routine & stressors',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput(_plDietController, 'Diet', Icons.restaurant_menu_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_plMealPatternController, 'Meal Pattern (Irregular meal habit)', Icons.schedule)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_plTeaCoffeeController, 'Tea / Coffee', Icons.coffee_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_plTobaccoController, 'Tobacco', Icons.smoking_rooms_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_plAlcoholController, 'Alcohol', Icons.local_bar_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_plOtherSubstanceUseController, 'Other Substance Use', Icons.medication_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_plPhysicalActivityController, 'Physical Activity (Limited / sedentary work pattern; advised to increase)', Icons.fitness_center_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_plOccupationWorkPatternController, 'Occupation / Work Pattern (Tailor; predominantly sedentary work)', Icons.work_history_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_plSedentaryBehaviourController, 'Sedentary Behaviour', Icons.chair_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_plSleepRoutineController, 'Sleep Routine', Icons.bedtime_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_plPersonalHygieneController, 'Personal Hygiene', Icons.wash_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_plSocialHistoryController, 'Social History', Icons.account_tree_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_plFinancialOccupationalStressorsController, 'Financial / Occupational Stressors', Icons.attach_money_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_plOtherHabitsController, 'Other Habits', Icons.info_outline),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 11. CLINICAL EXAMINATION
              _buildSectionCard(
                sectionNum: '11',
                title: '11. Clinical Examination',
                icon: Icons.monitor_heart_outlined,
                subtitle: 'Appearance, vitals, BP, pulse, temp, BMI, systemic exams, ENT & oral exam',
                children: [
                  Row(
                    children: [
                      Expanded(child: _ceBuildNutritionController.text.isNotEmpty ? _buildInput(_ceGeneralAppearanceController, 'General Appearance', Icons.person_outline) : _buildInput(_ceGeneralAppearanceController, 'General Appearance', Icons.person_outline)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceBuildNutritionController, 'Build / Nutrition', Icons.accessibility_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_cePallorController, 'Pallor', Icons.visibility_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceIcterusController, 'Icterus', Icons.remove_red_eye_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceCyanosisController, 'Cyanosis', Icons.palette_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceClubbingController, 'Clubbing', Icons.back_hand_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_ceLymphadenopathyController, 'Lymphadenopathy', Icons.hub_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceOedemaController, 'Oedema', Icons.water_drop_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_ceTemperatureController, 'Temperature (°F)', Icons.thermostat_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_cePulseController, 'Pulse (bpm)', Icons.favorite)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceBloodPressureController, 'Blood Pressure', Icons.speed)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceRespiratoryRateController, 'Respiratory Rate', Icons.air)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceSpO2Controller, 'SpO2 (%)', Icons.bloodtype_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_ceWeightController, 'Weight (kg)', Icons.scale_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceHeightController, 'Height (cm)', Icons.height)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_ceBMIController, 'BMI', Icons.calculate_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_ceCVSExaminationController, 'CVS Examination', Icons.favorite_border_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_ceRespiratoryExaminationController, 'Respiratory Examination', Icons.air_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_ceAbdominalExaminationController, 'Abdominal Examination', Icons.bubble_chart_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_ceCNSExaminationController, 'CNS Examination', Icons.psychology_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_ceMusculoskeletalExaminationController, 'Musculoskeletal Examination', Icons.accessibility_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_ceSkinExaminationController, 'Skin Examination', Icons.brush_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_ceENTOralExaminationController, 'ENT / Oral Examination (Tongue: flat, wart-like eruption; throat dry; forehead wart)', Icons.hearing_outlined, 2),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_ceOtherExaminationFindingsController, 'Other Examination Findings', Icons.health_and_safety_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 12. MIASMATIC ANALYSIS
              _buildSectionCard(
                sectionNum: '12',
                title: '12. Miasmatic Analysis',
                icon: Icons.biotech_outlined,
                subtitle: 'Predominant miasm, psoric, sycotic, syphilitic, tubercular, cancerinic features & interpretation',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PickerField<String>(
                          label: 'Predominant Miasm',
                          value: _maPredominantMiasm,
                          options: const [
                            PickerOption(value: 'Psora', label: 'Psora'),
                            PickerOption(value: 'Sycosis', label: 'Sycosis'),
                            PickerOption(value: 'Syphilis', label: 'Syphilis'),
                            PickerOption(value: 'Tubercular', label: 'Tubercular'),
                            PickerOption(value: 'Cancerinic', label: 'Cancerinic'),
                            PickerOption(value: 'Mixed / Dynamic', label: 'Mixed / Dynamic'),
                          ],
                          onChanged: (v) => setState(() => _maPredominantMiasm = v),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_maSecondaryMixedMiasmController, 'Secondary / Mixed Miasm', Icons.merge_type_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_maPsoricFeaturesController, 'Psoric Features', Icons.grain),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_maSycoticFeaturesController, 'Sycotic Features', Icons.bubble_chart_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_maSyphiliticFeaturesController, 'Syphilitic Features', Icons.warning_amber_rounded),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_maTubercularFeaturesController, 'Tubercular Features', Icons.air_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_maCancerinicFeaturesController, 'Cancerinic Features', Icons.coronavirus_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_maOtherMiasmaticIndicatorsController, 'Other Miasmatic Indicators (Wart-like eruptions noted)', Icons.fact_check_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_maCharacteristicSymptomsSupportingMiasmController, 'Characteristic Symptoms Supporting Miasm', Icons.assignment_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_maFinalMiasmaticInterpretationController, 'Final Miasmatic Interpretation', Icons.summarize_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 13. CASE ANALYSIS
              _buildSectionCard(
                sectionNum: '13',
                title: '13. Case Analysis',
                icon: Icons.auto_awesome_outlined,
                subtitle: 'Totality of symptoms, repertory used, selected rubrics, results & remedy selection',
                children: [
                  _buildInput(_caTotalityOfSymptomsController, 'Totality of Symptoms', Icons.summarize_outlined, 3),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_caCharacteristicSymptomsController, 'Characteristic Symptoms', Icons.star_outline, 2),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_caGeneralsController, 'Generals', Icons.list_alt_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_caParticularsController, 'Particulars', Icons.checklist)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_caMentalGeneralsController, 'Mental Generals', Icons.psychology_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_caPhysicalGeneralsController, 'Physical Generals', Icons.accessibility_new_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_caModalitiesController, 'Modalities', Icons.compare_arrows)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_caConcomitantsController, 'Concomitants', Icons.alt_route)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_caCausationController, 'Causation', Icons.psychology),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_caRepertoryUsedController, 'Repertory Used', Icons.book_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_caRubricsSelectedController, 'Rubrics Selected', Icons.menu_book_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_caRepertorialResultController, 'Repertorial Result', Icons.assessment_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_caMateriaMedicaCorrelationController, 'Materia Medica Correlation', Icons.library_books_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_caDifferentialRemediesController, 'Differential Remedies', Icons.compare_arrows_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_caFinalRemedySelectionRationaleController, 'Final Remedy Selection / Rationale (e.g. Nux Vomica prescribed on third visit)', Icons.check_circle_outline, 2),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 14. DIAGNOSIS / CLINICAL ASSESSMENT
              _buildSectionCard(
                sectionNum: '14',
                title: '14. Diagnosis / Clinical Assessment',
                icon: Icons.assignment_turned_in_outlined,
                subtitle: 'Provisional & working diagnosis, differential, comorbidities, red flags & remarks',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput(_diagProvisionalDiagnosisController, 'Provisional Diagnosis', Icons.help_outline)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_diagFinalWorkingDiagnosisController, 'Final / Working Diagnosis (Known uncontrolled Type 2 Diabetes Mellitus)', Icons.check_circle_outline)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_diagDifferentialDiagnosisController, 'Differential Diagnosis', Icons.alt_route_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_diagComorbiditiesController, 'Comorbidities (Gastric complaints; rectal abscess history)', Icons.healing_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_diagRedFlagsReferralIndicationsController, 'Red Flags / Referral Indications', Icons.warning_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_diagClinicalRemarksController, 'Clinical Remarks (Advised to control blood sugar and increase physical activity)', Icons.comment_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 15. PRESCRIPTION
              _buildSectionCard(
                sectionNum: '15',
                title: '15. Prescription',
                icon: Icons.receipt_long_outlined,
                subtitle: 'Prescription date, remedy, potency, dose, repetition, route, form, advice & rationale',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput(_rxPrescriptionDateController, 'Prescription Date', Icons.calendar_today_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(flex: 2, child: _buildInput(_rxRemedyController, 'Remedy', Icons.medication_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxPotencyController, 'Potency', Icons.numbers)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_rxDoseController, 'Dose', Icons.pin_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxRepetitionFrequencyController, 'Repetition / Frequency', Icons.schedule)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxRouteController, 'Route', Icons.alt_route)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_rxPharmaceuticalFormController, 'Pharmaceutical Form', Icons.science_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxQuantityDispensedController, 'Quantity Dispensed', Icons.inventory_2_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_rxDietRegimenAdviceController, 'Diet / Regimen Advice (Control blood sugar; increase physical activity)', Icons.no_food_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_rxLifestyleAdviceController, 'Lifestyle Advice (Increase physical activity; control blood sugar)', Icons.directions_run_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_rxInvestigationsAdvisedController, 'Investigations Advised', Icons.biotech_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_rxReferralAdvisedController, 'Referral Advised', Icons.share_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_rxPrescriptionRationaleController, 'Prescription Rationale', Icons.lightbulb_outline),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_rxPrescriptionNotesController, 'Prescription Notes (Patient reported no improvement/no relief after earlier prescriptions)', Icons.notes),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 16. INVESTIGATION
              _buildSectionCard(
                sectionNum: '16',
                title: '16. Investigation',
                icon: Icons.science_outlined,
                subtitle: 'Investigation date, name, panel, result/value, unit, reference range, normal/abnormal & report reference',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput(_invInvestigationDateController, 'Investigation Date', Icons.calendar_today_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(flex: 2, child: _buildInput(_invInvestigationNameController, 'Investigation Name (FBS, PPBS, RBS, X-Ray, etc.)', Icons.checklist_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_invTypePanelController, 'Type / Panel', Icons.grid_view)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_invResultValueController, 'Result / Value', Icons.numbers)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_invUnitController, 'Unit (mg/dL, %)', Icons.straighten_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_invReferenceRangeController, 'Reference Range', Icons.swap_horiz_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_invNormalAbnormalController, 'Normal / Abnormal', Icons.rule_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_invReportSummaryController, 'Report Summary', Icons.summarize_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_invClinicalInterpretationController, 'Clinical Interpretation', Icons.query_stats_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_invReportReferenceController, 'Report Reference', Icons.link_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 17. FOLLOW-UP
              _buildSectionCard(
                sectionNum: '17',
                title: '17. Follow-up',
                icon: Icons.event_note_outlined,
                subtitle: 'Date-wise follow-up logs with response, symptoms change, prescription & remarks',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput(_fuFollowUpDateController, 'Follow-up Date', Icons.calendar_today_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuIntervalSincePreviousVisitController, 'Interval Since Previous Visit', Icons.timelapse)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuOverallResponseController, 'Overall Response', Icons.rate_review_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_fuChiefComplaintChangesController, 'Chief Complaint Changes', Icons.change_circle_outlined),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_fuNewSymptomsController, 'New Symptoms', Icons.add_circle_outline)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuAggravationController, 'Aggravation', Icons.arrow_upward_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuImprovementController, 'Improvement', Icons.arrow_downward_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_fuGeneralSymptomsChangeController, 'General Symptoms Change', Icons.accessibility_new_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuMentalSymptomsChangeController, 'Mental Symptoms Change', Icons.psychology_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_fuSleepChangeController, 'Sleep Change', Icons.bedtime_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuAppetiteThirstChangeController, 'Appetite / Thirst Change', Icons.restaurant_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuStoolUrineChangeController, 'Stool / Urine Change', Icons.water_drop_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_fuPerspirationChangeController, 'Perspiration Change', Icons.waterfall_chart_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuEnergyChangeController, 'Energy Change', Icons.bolt_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuAdverseNewSymptomsController, 'Adverse / New Symptoms', Icons.warning_amber_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildInput(_fuFollowUpPrescriptionController, 'Follow-up Prescription', Icons.medication_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuPotencyController, 'Potency', Icons.numbers)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_fuDoseRepetitionController, 'Dose / Repetition', Icons.schedule)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_fuNextFollowUpController, 'Next Follow-up', Icons.event_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_fuFollowUpRemarksController, 'Follow-up Remarks (Patient continued to report gastric trouble, flatulence, gas escape)', Icons.notes_outlined, 2),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 18. OUTCOME
              _buildSectionCard(
                sectionNum: '18',
                title: '18. Outcome',
                icon: Icons.task_alt_outlined,
                subtitle: 'Final status, degree of improvement, duration & closure notes',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: PickerField<String>(
                          label: 'Final Status',
                          value: _outFinalStatus,
                          options: const [
                            PickerOption(value: 'Under Active Treatment', label: 'Under Active Treatment'),
                            PickerOption(value: 'Improved', label: 'Improved'),
                            PickerOption(value: 'Resolved', label: 'Resolved'),
                            PickerOption(value: 'Stable', label: 'Stable'),
                            PickerOption(value: 'Discontinued', label: 'Discontinued'),
                            PickerOption(value: 'Lost to Follow-up', label: 'Lost to Follow-up'),
                            PickerOption(value: 'Referred', label: 'Referred'),
                          ],
                          onChanged: (v) => setState(() => _outFinalStatus = v),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_outDegreeOfImprovementController, 'Degree of Improvement', Icons.trending_up)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(child: _buildInput(_outTreatmentDurationController, 'Treatment Duration', Icons.timelapse)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_outReasonForDiscontinuationClosureController, 'Reason for Discontinuation / Closure', Icons.cancel_outlined)),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: _buildInput(_outLostToFollowUpController, 'Lost to Follow-up', Icons.person_off_outlined)),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_outFinalOutcomeNotesController, 'Final Outcome Notes', Icons.description_outlined),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // 19. DOCUMENTATION
              _buildSectionCard(
                sectionNum: '19',
                title: '19. Documentation',
                icon: Icons.source_outlined,
                subtitle: 'Data source, register reference, transcription notes and unclear flags',
                children: [
                  _buildInput(_docDataSourceController, 'Data Source', Icons.source),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_docOriginalRegisterReferenceController, 'Original Register Reference', Icons.bookmark_border),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_docTranscriptionNotesController, 'Transcription Notes', Icons.description_outlined),
                  const SizedBox(height: Spacing.md),
                  _buildInput(_docUnclearInformationController, 'Unclear Information', Icons.help_outline),
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
          _buildInput(entry.complaint, 'Complaint (e.g. Pain in right hip)', Icons.healing),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.location, 'Location (e.g. Right hip)', Icons.place_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.onset, 'Onset', Icons.play_arrow_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.duration, 'Duration', Icons.timer_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.sensation, 'Sensation / Character', Icons.touch_app_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.extensionRadiation, 'Extension / Radiation', Icons.alt_route_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.agg, 'Aggravation', Icons.arrow_upward_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.amel, 'Amelioration', Icons.arrow_downward_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.concomitant, 'Concomitants', Icons.alt_route_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.causation, 'Causation / Exciting Cause', Icons.psychology_outlined)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildInput(entry.periodicity, 'Periodicity', Icons.event_repeat_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildInput(entry.time, 'Time', Icons.alarm_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: PickerField<String>(
                  label: 'Severity',
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
