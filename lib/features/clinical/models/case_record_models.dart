import 'dart:convert';

// 1. PATIENT IDENTIFICATION
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

// 2. CHIEF COMPLAINTS
class ChiefComplaintDetail {
  final String complaint;
  final String location;
  final String onset;
  final String duration;
  final String sensation;
  final String extensionRadiation;
  final String modalitiesAgg;
  final String modalitiesAmel;
  final String concomitants;
  final String causation;
  final String periodicity;
  final String time;
  final String severity;
  final String associatedSymptoms;

  const ChiefComplaintDetail({
    this.complaint = '',
    this.location = '',
    this.onset = '',
    this.duration = '',
    this.sensation = '',
    this.extensionRadiation = '',
    this.modalitiesAgg = '',
    this.modalitiesAmel = '',
    this.concomitants = '',
    this.causation = '',
    this.periodicity = '',
    this.time = '',
    this.severity = 'Moderate',
    this.associatedSymptoms = '',
  });

  Map<String, dynamic> toJson() => {
        'complaint': complaint,
        'location': location,
        'onset': onset,
        'duration': duration,
        'sensation': sensation,
        'extensionRadiation': extensionRadiation,
        'modalitiesAgg': modalitiesAgg,
        'modalitiesAmel': modalitiesAmel,
        'concomitants': concomitants,
        'causation': causation,
        'periodicity': periodicity,
        'time': time,
        'severity': severity,
        'associatedSymptoms': associatedSymptoms,
      };

  factory ChiefComplaintDetail.fromJson(Map<String, dynamic> json) =>
      ChiefComplaintDetail(
        complaint: json['complaint'] as String? ?? '',
        location: json['location'] as String? ?? '',
        onset: json['onset'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
        sensation: json['sensation'] as String? ?? '',
        extensionRadiation: json['extensionRadiation'] as String? ?? '',
        modalitiesAgg: json['modalitiesAgg'] as String? ?? '',
        modalitiesAmel: json['modalitiesAmel'] as String? ?? '',
        concomitants: json['concomitants'] as String? ?? '',
        causation: json['causation'] as String? ?? '',
        periodicity: json['periodicity'] as String? ?? '',
        time: json['time'] as String? ?? '',
        severity: json['severity'] as String? ?? 'Moderate',
        associatedSymptoms: json['associatedSymptoms'] as String? ?? '',
      );
}

// 4. HISTORY OF PRESENT ILLNESS (HPI)
class HpiDetails {
  final String chronologicalDevelopment;
  final String firstOccurrence;
  final String progression;
  final String previousEpisodes;
  final String previousTreatment;
  final String responseToTreatment;
  final String relevantPrecipitatingFactors;
  final String otherRelevantHistory;

  const HpiDetails({
    this.chronologicalDevelopment = '',
    this.firstOccurrence = '',
    this.progression = '',
    this.previousEpisodes = '',
    this.previousTreatment = '',
    this.responseToTreatment = '',
    this.relevantPrecipitatingFactors = '',
    this.otherRelevantHistory = '',
  });

  // Backward compatibility getters
  String get previousTreatments => previousTreatment;
  String get precipitatingFactors => relevantPrecipitatingFactors;

  Map<String, dynamic> toJson() => {
        'chronologicalDevelopment': chronologicalDevelopment,
        'firstOccurrence': firstOccurrence,
        'progression': progression,
        'previousEpisodes': previousEpisodes,
        'previousTreatment': previousTreatment,
        'responseToTreatment': responseToTreatment,
        'relevantPrecipitatingFactors': relevantPrecipitatingFactors,
        'otherRelevantHistory': otherRelevantHistory,
      };

  factory HpiDetails.fromJson(Map<String, dynamic> json) => HpiDetails(
        chronologicalDevelopment: json['chronologicalDevelopment'] as String? ?? json['progression'] as String? ?? '',
        firstOccurrence: json['firstOccurrence'] as String? ?? '',
        progression: json['progression'] as String? ?? json['chronologicalDevelopment'] as String? ?? '',
        previousEpisodes: json['previousEpisodes'] as String? ?? '',
        previousTreatment: json['previousTreatment'] as String? ?? json['previousTreatments'] as String? ?? '',
        responseToTreatment: json['responseToTreatment'] as String? ?? '',
        relevantPrecipitatingFactors: json['relevantPrecipitatingFactors'] as String? ?? json['precipitatingFactors'] as String? ?? '',
        otherRelevantHistory: json['otherRelevantHistory'] as String? ?? '',
      );

  factory HpiDetails.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const HpiDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('hpi')) {
          return HpiDetails.fromJson(decoded['hpi'] as Map<String, dynamic>);
        }
        return HpiDetails.fromJson(decoded);
      }
    } catch (_) {}
    return HpiDetails(chronologicalDevelopment: raw);
  }
}

// 5. PAST HISTORY
class PastHistoryDetails {
  final String childhoodIllnesses;
  final String majorIllnesses;
  final String chronicDiseases;
  final String surgeries;
  final String injuriesTrauma;
  final String hospitalisations;
  final String infections;
  final String allergies;
  final String previousMedications;
  final String previousHomeopathicTreatment;
  final String otherPastHistory;

  const PastHistoryDetails({
    this.childhoodIllnesses = '',
    this.majorIllnesses = '',
    this.chronicDiseases = '',
    this.surgeries = '',
    this.injuriesTrauma = '',
    this.hospitalisations = '',
    this.infections = '',
    this.allergies = '',
    this.previousMedications = '',
    this.previousHomeopathicTreatment = '',
    this.otherPastHistory = '',
  });

  String get previousTreatments => previousHomeopathicTreatment;

  Map<String, dynamic> toJson() => {
        'childhoodIllnesses': childhoodIllnesses,
        'majorIllnesses': majorIllnesses,
        'chronicDiseases': chronicDiseases,
        'surgeries': surgeries,
        'injuriesTrauma': injuriesTrauma,
        'hospitalisations': hospitalisations,
        'infections': infections,
        'allergies': allergies,
        'previousMedications': previousMedications,
        'previousHomeopathicTreatment': previousHomeopathicTreatment,
        'otherPastHistory': otherPastHistory,
      };

  factory PastHistoryDetails.fromJson(Map<String, dynamic> json) =>
      PastHistoryDetails(
        childhoodIllnesses: json['childhoodIllnesses'] as String? ?? '',
        majorIllnesses: json['majorIllnesses'] as String? ?? '',
        chronicDiseases: json['chronicDiseases'] as String? ?? '',
        surgeries: json['surgeries'] as String? ?? '',
        injuriesTrauma: json['injuriesTrauma'] as String? ?? '',
        hospitalisations: json['hospitalisations'] as String? ?? '',
        infections: json['infections'] as String? ?? '',
        allergies: json['allergies'] as String? ?? '',
        previousMedications: json['previousMedications'] as String? ?? '',
        previousHomeopathicTreatment: json['previousHomeopathicTreatment'] as String? ?? json['previousTreatments'] as String? ?? '',
        otherPastHistory: json['otherPastHistory'] as String? ?? '',
      );

  factory PastHistoryDetails.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const PastHistoryDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return PastHistoryDetails.fromJson(decoded);
    } catch (_) {}
    return PastHistoryDetails(chronicDiseases: raw);
  }
}

// 6. FAMILY HISTORY
class FamilyHistoryDetails {
  final String father;
  final String mother;
  final String siblings;
  final String spouse;
  final String children;
  final String grandparentsRelatives;
  final String hereditaryDiseases;
  final String majorFamilialDiseases;
  final String psychiatricHistory;
  final String otherFamilyHistory;

  const FamilyHistoryDetails({
    this.father = '',
    this.mother = '',
    this.siblings = '',
    this.spouse = '',
    this.children = '',
    this.grandparentsRelatives = '',
    this.hereditaryDiseases = '',
    this.majorFamilialDiseases = '',
    this.psychiatricHistory = '',
    this.otherFamilyHistory = '',
  });

  String get siblingsChildren => '$siblings $children'.trim();

  Map<String, dynamic> toJson() => {
        'father': father,
        'mother': mother,
        'siblings': siblings,
        'spouse': spouse,
        'children': children,
        'grandparentsRelatives': grandparentsRelatives,
        'hereditaryDiseases': hereditaryDiseases,
        'majorFamilialDiseases': majorFamilialDiseases,
        'psychiatricHistory': psychiatricHistory,
        'otherFamilyHistory': otherFamilyHistory,
      };

  factory FamilyHistoryDetails.fromJson(Map<String, dynamic> json) =>
      FamilyHistoryDetails(
        father: json['father'] as String? ?? '',
        mother: json['mother'] as String? ?? '',
        siblings: json['siblings'] as String? ?? json['siblingsChildren'] as String? ?? '',
        spouse: json['spouse'] as String? ?? '',
        children: json['children'] as String? ?? '',
        grandparentsRelatives: json['grandparentsRelatives'] as String? ?? '',
        hereditaryDiseases: json['hereditaryDiseases'] as String? ?? '',
        majorFamilialDiseases: json['majorFamilialDiseases'] as String? ?? '',
        psychiatricHistory: json['psychiatricHistory'] as String? ?? '',
        otherFamilyHistory: json['otherFamilyHistory'] as String? ?? '',
      );

  factory FamilyHistoryDetails.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const FamilyHistoryDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return FamilyHistoryDetails.fromJson(decoded);
    } catch (_) {}
    return FamilyHistoryDetails(hereditaryDiseases: raw);
  }
}

// 7. INTRAUTERINE, BIRTH & DEVELOPMENTAL HISTORY
class DevelopmentalHistoryDetails {
  final String maternalHealth;
  final String pregnancyComplications;
  final String maternalInfections;
  final String maternalMedications;
  final String antenatalCare;
  final String nutritionDuringPregnancy;
  final String gestationalAge;
  final String birthOrder;
  final String modeOfDelivery;
  final String birthWeight;
  final String neonatalHistory;
  final String breastfeeding;
  final String developmentalMilestones;
  final String childhoodDevelopment;
  final String otherBirthDevelopmentalHistory;

  const DevelopmentalHistoryDetails({
    this.maternalHealth = '',
    this.pregnancyComplications = '',
    this.maternalInfections = '',
    this.maternalMedications = '',
    this.antenatalCare = '',
    this.nutritionDuringPregnancy = '',
    this.gestationalAge = '',
    this.birthOrder = '',
    this.modeOfDelivery = '',
    this.birthWeight = '',
    this.neonatalHistory = '',
    this.breastfeeding = '',
    this.developmentalMilestones = '',
    this.childhoodDevelopment = '',
    this.otherBirthDevelopmentalHistory = '',
  });

  String get deliveryComplications => modeOfDelivery;
  String get milestonesDentition => developmentalMilestones;
  String get vaccinationNeonatal => neonatalHistory;
  String get otherDevelopmentalNotes => otherBirthDevelopmentalHistory;

  Map<String, dynamic> toJson() => {
        'maternalHealth': maternalHealth,
        'pregnancyComplications': pregnancyComplications,
        'maternalInfections': maternalInfections,
        'maternalMedications': maternalMedications,
        'antenatalCare': antenatalCare,
        'nutritionDuringPregnancy': nutritionDuringPregnancy,
        'gestationalAge': gestationalAge,
        'birthOrder': birthOrder,
        'modeOfDelivery': modeOfDelivery,
        'birthWeight': birthWeight,
        'neonatalHistory': neonatalHistory,
        'breastfeeding': breastfeeding,
        'developmentalMilestones': developmentalMilestones,
        'childhoodDevelopment': childhoodDevelopment,
        'otherBirthDevelopmentalHistory': otherBirthDevelopmentalHistory,
      };

  factory DevelopmentalHistoryDetails.fromJson(Map<String, dynamic> json) =>
      DevelopmentalHistoryDetails(
        maternalHealth: json['maternalHealth'] as String? ?? '',
        pregnancyComplications: json['pregnancyComplications'] as String? ?? '',
        maternalInfections: json['maternalInfections'] as String? ?? '',
        maternalMedications: json['maternalMedications'] as String? ?? '',
        antenatalCare: json['antenatalCare'] as String? ?? '',
        nutritionDuringPregnancy: json['nutritionDuringPregnancy'] as String? ?? '',
        gestationalAge: json['gestationalAge'] as String? ?? '',
        birthOrder: json['birthOrder'] as String? ?? '',
        modeOfDelivery: json['modeOfDelivery'] as String? ?? json['deliveryComplications'] as String? ?? '',
        birthWeight: json['birthWeight'] as String? ?? '',
        neonatalHistory: json['neonatalHistory'] as String? ?? '',
        breastfeeding: json['breastfeeding'] as String? ?? '',
        developmentalMilestones: json['developmentalMilestones'] as String? ?? json['milestonesDentition'] as String? ?? '',
        childhoodDevelopment: json['childhoodDevelopment'] as String? ?? '',
        otherBirthDevelopmentalHistory: json['otherBirthDevelopmentalHistory'] as String? ?? json['otherDevelopmentalNotes'] as String? ?? '',
      );

  factory DevelopmentalHistoryDetails.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const DevelopmentalHistoryDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return DevelopmentalHistoryDetails.fromJson(decoded);
    } catch (_) {}
    return DevelopmentalHistoryDetails(maternalHealth: raw);
  }
}

// 8. PHYSICAL GENERALS
class PhysicalGenerals {
  final String thermal;
  final String hotChilly;
  final String weatherPreference;
  final String sensitivityToTemperature;
  final String thirst;
  final String thirstFrequency;
  final String thirstTiming;
  final String appetite;
  final String hungerFasting;
  final String cravings;
  final String aversions;
  final String intolerances;
  final String stool;
  final String stoolFrequency;
  final String stoolConsistency;
  final String stoolColourOdour;
  final String stoolDifficultiesModalities;
  final String urine;
  final String urineFrequency;
  final String urineQuantity;
  final String urineColourOdour;
  final String urinarySymptoms;
  final String perspiration;
  final String perspirationOdour;
  final String perspirationTimingDistribution;
  final String sleep;
  final String sleepQuantity;
  final String sleepQuality;
  final String sleepPosition;
  final String sleepOnset;
  final String sleepDisturbances;
  final String dreams;
  final String dreamsRecurrentPeculiar;
  final String energyVitality;
  final String fatigue;
  final String sexualHistory;
  final String menstrualHistory;
  final String obstetricHistory;
  final String skinHairNails;
  final String generalDischarges;
  final String otherPhysicalGenerals;

  const PhysicalGenerals({
    this.thermal = 'Ambithermal',
    this.hotChilly = 'Ambithermal',
    this.weatherPreference = '',
    this.sensitivityToTemperature = '',
    this.thirst = '',
    this.thirstFrequency = '',
    this.thirstTiming = '',
    this.appetite = '',
    this.hungerFasting = '',
    this.cravings = '',
    this.aversions = '',
    this.intolerances = '',
    this.stool = '',
    this.stoolFrequency = '',
    this.stoolConsistency = '',
    this.stoolColourOdour = '',
    this.stoolDifficultiesModalities = '',
    this.urine = '',
    this.urineFrequency = '',
    this.urineQuantity = '',
    this.urineColourOdour = '',
    this.urinarySymptoms = '',
    this.perspiration = '',
    this.perspirationOdour = '',
    this.perspirationTimingDistribution = '',
    this.sleep = '',
    this.sleepQuantity = '',
    this.sleepQuality = '',
    this.sleepPosition = '',
    this.sleepOnset = '',
    this.sleepDisturbances = '',
    this.dreams = '',
    this.dreamsRecurrentPeculiar = '',
    this.energyVitality = '',
    this.fatigue = '',
    this.sexualHistory = '',
    this.menstrualHistory = '',
    this.obstetricHistory = '',
    this.skinHairNails = '',
    this.generalDischarges = '',
    this.otherPhysicalGenerals = '',
  });

  String get thirstFrequencyTiming => '$thirstFrequency $thirstTiming'.trim();
  String get stoolFrequencyConsistency => '$stoolFrequency $stoolConsistency'.trim();
  String get perspirationOdourTiming => '$perspirationOdour $perspirationTimingDistribution'.trim();
  String get sleepQualityDisturbances => '$sleepQuality $sleepDisturbances'.trim();
  String get energyFatigue => '$energyVitality $fatigue'.trim();
  String get sexualMenstrualObstetric => '$sexualHistory $menstrualHistory $obstetricHistory'.trim();

  Map<String, dynamic> toJson() => {
        'thermal': thermal,
        'hotChilly': hotChilly,
        'weatherPreference': weatherPreference,
        'sensitivityToTemperature': sensitivityToTemperature,
        'thirst': thirst,
        'thirstFrequency': thirstFrequency,
        'thirstTiming': thirstTiming,
        'appetite': appetite,
        'hungerFasting': hungerFasting,
        'cravings': cravings,
        'aversions': aversions,
        'intolerances': intolerances,
        'stool': stool,
        'stoolFrequency': stoolFrequency,
        'stoolConsistency': stoolConsistency,
        'stoolColourOdour': stoolColourOdour,
        'stoolDifficultiesModalities': stoolDifficultiesModalities,
        'urine': urine,
        'urineFrequency': urineFrequency,
        'urineQuantity': urineQuantity,
        'urineColourOdour': urineColourOdour,
        'urinarySymptoms': urinarySymptoms,
        'perspiration': perspiration,
        'perspirationOdour': perspirationOdour,
        'perspirationTimingDistribution': perspirationTimingDistribution,
        'sleep': sleep,
        'sleepQuantity': sleepQuantity,
        'sleepQuality': sleepQuality,
        'sleepPosition': sleepPosition,
        'sleepOnset': sleepOnset,
        'sleepDisturbances': sleepDisturbances,
        'dreams': dreams,
        'dreamsRecurrentPeculiar': dreamsRecurrentPeculiar,
        'energyVitality': energyVitality,
        'fatigue': fatigue,
        'sexualHistory': sexualHistory,
        'menstrualHistory': menstrualHistory,
        'obstetricHistory': obstetricHistory,
        'skinHairNails': skinHairNails,
        'generalDischarges': generalDischarges,
        'otherPhysicalGenerals': otherPhysicalGenerals,
      };

  factory PhysicalGenerals.fromJson(Map<String, dynamic> json) =>
      PhysicalGenerals(
        thermal: json['thermal'] as String? ?? 'Ambithermal',
        hotChilly: json['hotChilly'] as String? ?? 'Ambithermal',
        weatherPreference: json['weatherPreference'] as String? ?? '',
        sensitivityToTemperature: json['sensitivityToTemperature'] as String? ?? '',
        thirst: json['thirst'] as String? ?? '',
        thirstFrequency: json['thirstFrequency'] as String? ?? '',
        thirstTiming: json['thirstTiming'] as String? ?? '',
        appetite: json['appetite'] as String? ?? '',
        hungerFasting: json['hungerFasting'] as String? ?? '',
        cravings: json['cravings'] as String? ?? '',
        aversions: json['aversions'] as String? ?? '',
        intolerances: json['intolerances'] as String? ?? '',
        stool: json['stool'] as String? ?? '',
        stoolFrequency: json['stoolFrequency'] as String? ?? '',
        stoolConsistency: json['stoolConsistency'] as String? ?? '',
        stoolColourOdour: json['stoolColourOdour'] as String? ?? '',
        stoolDifficultiesModalities: json['stoolDifficultiesModalities'] as String? ?? '',
        urine: json['urine'] as String? ?? '',
        urineFrequency: json['urineFrequency'] as String? ?? '',
        urineQuantity: json['urineQuantity'] as String? ?? '',
        urineColourOdour: json['urineColourOdour'] as String? ?? '',
        urinarySymptoms: json['urinarySymptoms'] as String? ?? '',
        perspiration: json['perspiration'] as String? ?? '',
        perspirationOdour: json['perspirationOdour'] as String? ?? '',
        perspirationTimingDistribution: json['perspirationTimingDistribution'] as String? ?? '',
        sleep: json['sleep'] as String? ?? '',
        sleepQuantity: json['sleepQuantity'] as String? ?? '',
        sleepQuality: json['sleepQuality'] as String? ?? '',
        sleepPosition: json['sleepPosition'] as String? ?? '',
        sleepOnset: json['sleepOnset'] as String? ?? '',
        sleepDisturbances: json['sleepDisturbances'] as String? ?? '',
        dreams: json['dreams'] as String? ?? '',
        dreamsRecurrentPeculiar: json['dreamsRecurrentPeculiar'] as String? ?? '',
        energyVitality: json['energyVitality'] as String? ?? '',
        fatigue: json['fatigue'] as String? ?? '',
        sexualHistory: json['sexualHistory'] as String? ?? '',
        menstrualHistory: json['menstrualHistory'] as String? ?? '',
        obstetricHistory: json['obstetricHistory'] as String? ?? '',
        skinHairNails: json['skinHairNails'] as String? ?? '',
        generalDischarges: json['generalDischarges'] as String? ?? '',
        otherPhysicalGenerals: json['otherPhysicalGenerals'] as String? ?? '',
      );

  factory PhysicalGenerals.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const PhysicalGenerals();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return PhysicalGenerals.fromJson(decoded);
    } catch (_) {}
    return PhysicalGenerals(thermal: raw);
  }
}

// 9. MENTAL GENERALS
class MentalGenerals {
  final String generalMentalState;
  final String disposition;
  final String irritability;
  final String anger;
  final String anxiety;
  final String fears;
  final String specificFearsPhobias;
  final String sadnessGrief;
  final String depression;
  final String jealousy;
  final String suspicion;
  final String companyDesireAversion;
  final String desireForSolitude;
  final String desireForAttentionConsolation;
  final String talkativenessQuietness;
  final String confidenceSelfEsteem;
  final String willDetermination;
  final String indecision;
  final String memory;
  final String concentration;
  final String workStudyResponse;
  final String restlessness;
  final String responseToStress;
  final String responseToContradictionOpposition;
  final String responseToReprimand;
  final String compulsionsObsessions;
  final String otherCharacteristicMentalSymptoms;

  const MentalGenerals({
    this.generalMentalState = '',
    this.disposition = '',
    this.irritability = '',
    this.anger = '',
    this.anxiety = '',
    this.fears = '',
    this.specificFearsPhobias = '',
    this.sadnessGrief = '',
    this.depression = '',
    this.jealousy = '',
    this.suspicion = '',
    this.companyDesireAversion = '',
    this.desireForSolitude = '',
    this.desireForAttentionConsolation = '',
    this.talkativenessQuietness = '',
    this.confidenceSelfEsteem = '',
    this.willDetermination = '',
    this.indecision = '',
    this.memory = '',
    this.concentration = '',
    this.workStudyResponse = '',
    this.restlessness = '',
    this.responseToStress = '',
    this.responseToContradictionOpposition = '',
    this.responseToReprimand = '',
    this.compulsionsObsessions = '',
    this.otherCharacteristicMentalSymptoms = '',
  });

  String get irritabilityAnger => '$irritability $anger'.trim();
  String get anxietyFears => '$anxiety $fears'.trim();
  String get sadnessGriefDepression => '$sadnessGrief $depression'.trim();
  String get jealousySuspicion => '$jealousy $suspicion'.trim();
  String get companySolitude => '$companyDesireAversion $desireForSolitude'.trim();
  String get attentionConsolation => desireForAttentionConsolation;
  String get consolationReaction => desireForAttentionConsolation;
  String get confidenceWillIndecision => '$confidenceSelfEsteem $willDetermination $indecision'.trim();
  String get memoryConcentration => '$memory $concentration'.trim();
  String get restlessnessWorkStudy => '$restlessness $workStudyResponse'.trim();
  String get stressResponse => responseToStress;
  String get responseToContradictionReprimand => '$responseToContradictionOpposition $responseToReprimand'.trim();

  Map<String, dynamic> toJson() => {
        'generalMentalState': generalMentalState,
        'disposition': disposition,
        'irritability': irritability,
        'anger': anger,
        'anxiety': anxiety,
        'fears': fears,
        'specificFearsPhobias': specificFearsPhobias,
        'sadnessGrief': sadnessGrief,
        'depression': depression,
        'jealousy': jealousy,
        'suspicion': suspicion,
        'companyDesireAversion': companyDesireAversion,
        'desireForSolitude': desireForSolitude,
        'desireForAttentionConsolation': desireForAttentionConsolation,
        'talkativenessQuietness': talkativenessQuietness,
        'confidenceSelfEsteem': confidenceSelfEsteem,
        'willDetermination': willDetermination,
        'indecision': indecision,
        'memory': memory,
        'concentration': concentration,
        'workStudyResponse': workStudyResponse,
        'restlessness': restlessness,
        'responseToStress': responseToStress,
        'responseToContradictionOpposition': responseToContradictionOpposition,
        'responseToReprimand': responseToReprimand,
        'compulsionsObsessions': compulsionsObsessions,
        'otherCharacteristicMentalSymptoms': otherCharacteristicMentalSymptoms,
      };

  factory MentalGenerals.fromJson(Map<String, dynamic> json) => MentalGenerals(
        generalMentalState: json['generalMentalState'] as String? ?? '',
        disposition: json['disposition'] as String? ?? '',
        irritability: json['irritability'] as String? ?? '',
        anger: json['anger'] as String? ?? '',
        anxiety: json['anxiety'] as String? ?? '',
        fears: json['fears'] as String? ?? '',
        specificFearsPhobias: json['specificFearsPhobias'] as String? ?? '',
        sadnessGrief: json['sadnessGrief'] as String? ?? '',
        depression: json['depression'] as String? ?? '',
        jealousy: json['jealousy'] as String? ?? '',
        suspicion: json['suspicion'] as String? ?? '',
        companyDesireAversion: json['companyDesireAversion'] as String? ?? json['companySolitude'] as String? ?? '',
        desireForSolitude: json['desireForSolitude'] as String? ?? '',
        desireForAttentionConsolation: json['desireForAttentionConsolation'] as String? ?? json['consolationReaction'] as String? ?? json['attentionConsolation'] as String? ?? '',
        talkativenessQuietness: json['talkativenessQuietness'] as String? ?? '',
        confidenceSelfEsteem: json['confidenceSelfEsteem'] as String? ?? '',
        willDetermination: json['willDetermination'] as String? ?? '',
        indecision: json['indecision'] as String? ?? '',
        memory: json['memory'] as String? ?? '',
        concentration: json['concentration'] as String? ?? '',
        workStudyResponse: json['workStudyResponse'] as String? ?? '',
        restlessness: json['restlessness'] as String? ?? '',
        responseToStress: json['responseToStress'] as String? ?? json['stressResponse'] as String? ?? '',
        responseToContradictionOpposition: json['responseToContradictionOpposition'] as String? ?? '',
        responseToReprimand: json['responseToReprimand'] as String? ?? '',
        compulsionsObsessions: json['compulsionsObsessions'] as String? ?? '',
        otherCharacteristicMentalSymptoms: json['otherCharacteristicMentalSymptoms'] as String? ?? '',
      );

  factory MentalGenerals.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const MentalGenerals();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return MentalGenerals.fromJson(decoded);
    } catch (_) {}
    return MentalGenerals(disposition: raw);
  }
}

// 10. PERSONAL & LIFESTYLE HISTORY
class LifestyleHistoryDetails {
  final String diet;
  final String mealPattern;
  final String teaCoffee;
  final String tobacco;
  final String alcohol;
  final String otherSubstanceUse;
  final String physicalActivity;
  final String occupationWorkPattern;
  final String sedentaryBehaviour;
  final String sleepRoutine;
  final String personalHygiene;
  final String socialHistory;
  final String financialOccupationalStressors;
  final String otherHabits;

  const LifestyleHistoryDetails({
    this.diet = '',
    this.mealPattern = '',
    this.teaCoffee = '',
    this.tobacco = '',
    this.alcohol = '',
    this.otherSubstanceUse = '',
    this.physicalActivity = '',
    this.occupationWorkPattern = '',
    this.sedentaryBehaviour = '',
    this.sleepRoutine = '',
    this.personalHygiene = '',
    this.socialHistory = '',
    this.financialOccupationalStressors = '',
    this.otherHabits = '',
  });

  String get dietaryHabits => diet;
  String get habitsAddictions => '$teaCoffee $tobacco $alcohol'.trim();
  String get substanceUse => otherSubstanceUse;
  String get occupationalHazards => occupationWorkPattern;
  String get socialStressors => socialHistory;

  Map<String, dynamic> toJson() => {
        'diet': diet,
        'mealPattern': mealPattern,
        'teaCoffee': teaCoffee,
        'tobacco': tobacco,
        'alcohol': alcohol,
        'otherSubstanceUse': otherSubstanceUse,
        'physicalActivity': physicalActivity,
        'occupationWorkPattern': occupationWorkPattern,
        'sedentaryBehaviour': sedentaryBehaviour,
        'sleepRoutine': sleepRoutine,
        'personalHygiene': personalHygiene,
        'socialHistory': socialHistory,
        'financialOccupationalStressors': financialOccupationalStressors,
        'otherHabits': otherHabits,
      };

  factory LifestyleHistoryDetails.fromJson(Map<String, dynamic> json) =>
      LifestyleHistoryDetails(
        diet: json['diet'] as String? ?? json['dietaryHabits'] as String? ?? '',
        mealPattern: json['mealPattern'] as String? ?? '',
        teaCoffee: json['teaCoffee'] as String? ?? '',
        tobacco: json['tobacco'] as String? ?? '',
        alcohol: json['alcohol'] as String? ?? '',
        otherSubstanceUse: json['otherSubstanceUse'] as String? ?? json['substanceUse'] as String? ?? '',
        physicalActivity: json['physicalActivity'] as String? ?? '',
        occupationWorkPattern: json['occupationWorkPattern'] as String? ?? json['occupationalHazards'] as String? ?? '',
        sedentaryBehaviour: json['sedentaryBehaviour'] as String? ?? '',
        sleepRoutine: json['sleepRoutine'] as String? ?? '',
        personalHygiene: json['personalHygiene'] as String? ?? '',
        socialHistory: json['socialHistory'] as String? ?? json['socialStressors'] as String? ?? '',
        financialOccupationalStressors: json['financialOccupationalStressors'] as String? ?? '',
        otherHabits: json['otherHabits'] as String? ?? '',
      );

  factory LifestyleHistoryDetails.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const LifestyleHistoryDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return LifestyleHistoryDetails.fromJson(decoded);
    } catch (_) {}
    return LifestyleHistoryDetails(diet: raw);
  }
}

// 11. CLINICAL EXAMINATION
class ClinicalExamVitals {
  final String generalAppearance;
  final String buildNutrition;
  final String pallor;
  final String icterus;
  final String cyanosis;
  final String clubbing;
  final String lymphadenopathy;
  final String oedema;
  final String temperature;
  final String pulse;
  final String bloodPressure;
  final String respiratoryRate;
  final String spo2;
  final String weightKg;
  final String heightCm;
  final String bmi;
  final String cvsExamination;
  final String respiratoryExamination;
  final String abdominalExamination;
  final String cnsExamination;
  final String musculoskeletalExamination;
  final String skinExamination;
  final String entOralExamination;
  final String otherExaminationFindings;

  const ClinicalExamVitals({
    this.generalAppearance = '',
    this.buildNutrition = '',
    this.pallor = '',
    this.icterus = '',
    this.cyanosis = '',
    this.clubbing = '',
    this.lymphadenopathy = '',
    this.oedema = '',
    this.temperature = '',
    this.pulse = '',
    this.bloodPressure = '',
    this.respiratoryRate = '',
    this.spo2 = '',
    this.weightKg = '',
    this.heightCm = '',
    this.bmi = '',
    this.cvsExamination = '',
    this.respiratoryExamination = '',
    this.abdominalExamination = '',
    this.cnsExamination = '',
    this.musculoskeletalExamination = '',
    this.skinExamination = '',
    this.entOralExamination = '',
    this.otherExaminationFindings = '',
  });

  String get bp => bloodPressure;
  String get pallorIcterus => '$pallor $icterus'.trim();
  String get cyanosisClubbingOedemaLymph => '$cyanosis $clubbing $oedema $lymphadenopathy'.trim();
  String get cvsRespiratoryExam => '$cvsExamination $respiratoryExamination'.trim();
  String get abdominalCnsExam => '$abdominalExamination $cnsExamination'.trim();
  String get musculoskeletalSkinExam => '$musculoskeletalExamination $skinExamination'.trim();
  String get tongueExam => entOralExamination;
  String get entOralExam => entOralExamination;
  String get systemicFindings => otherExaminationFindings;

  Map<String, dynamic> toJson() => {
        'generalAppearance': generalAppearance,
        'buildNutrition': buildNutrition,
        'pallor': pallor,
        'icterus': icterus,
        'cyanosis': cyanosis,
        'clubbing': clubbing,
        'lymphadenopathy': lymphadenopathy,
        'oedema': oedema,
        'temperature': temperature,
        'pulse': pulse,
        'bloodPressure': bloodPressure,
        'respiratoryRate': respiratoryRate,
        'spo2': spo2,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'bmi': bmi,
        'cvsExamination': cvsExamination,
        'respiratoryExamination': respiratoryExamination,
        'abdominalExamination': abdominalExamination,
        'cnsExamination': cnsExamination,
        'musculoskeletalExamination': musculoskeletalExamination,
        'skinExamination': skinExamination,
        'entOralExamination': entOralExamination,
        'otherExaminationFindings': otherExaminationFindings,
      };

  factory ClinicalExamVitals.fromJson(Map<String, dynamic> json) =>
      ClinicalExamVitals(
        generalAppearance: json['generalAppearance'] as String? ?? '',
        buildNutrition: json['buildNutrition'] as String? ?? '',
        pallor: json['pallor'] as String? ?? '',
        icterus: json['icterus'] as String? ?? '',
        cyanosis: json['cyanosis'] as String? ?? '',
        clubbing: json['clubbing'] as String? ?? '',
        lymphadenopathy: json['lymphadenopathy'] as String? ?? '',
        oedema: json['oedema'] as String? ?? '',
        temperature: json['temperature'] as String? ?? '',
        pulse: json['pulse'] as String? ?? '',
        bloodPressure: json['bloodPressure'] as String? ?? json['bp'] as String? ?? '',
        respiratoryRate: json['respiratoryRate'] as String? ?? '',
        spo2: json['spo2'] as String? ?? '',
        weightKg: json['weightKg'] as String? ?? '',
        heightCm: json['heightCm'] as String? ?? '',
        bmi: json['bmi'] as String? ?? '',
        cvsExamination: json['cvsExamination'] as String? ?? '',
        respiratoryExamination: json['respiratoryExamination'] as String? ?? '',
        abdominalExamination: json['abdominalExamination'] as String? ?? '',
        cnsExamination: json['cnsExamination'] as String? ?? '',
        musculoskeletalExamination: json['musculoskeletalExamination'] as String? ?? '',
        skinExamination: json['skinExamination'] as String? ?? '',
        entOralExamination: json['entOralExamination'] as String? ?? json['tongueExam'] as String? ?? '',
        otherExaminationFindings: json['otherExaminationFindings'] as String? ?? json['systemicFindings'] as String? ?? '',
      );

  factory ClinicalExamVitals.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const ClinicalExamVitals();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return ClinicalExamVitals.fromJson(decoded);
    } catch (_) {}
    return ClinicalExamVitals(otherExaminationFindings: raw);
  }
}

// 12. MIASMATIC ANALYSIS
class MiasmaticAnalysis {
  final String dominantMiasm;
  final String secondaryMixedMiasm;
  final String psoricFeatures;
  final String sycoticFeatures;
  final String syphiliticFeatures;
  final String tubercularFeatures;
  final String cancerinicFeatures;
  final String otherMiasmaticIndicators;
  final String characteristicSymptoms;
  final String finalMiasmaticInterpretation;

  const MiasmaticAnalysis({
    this.dominantMiasm = 'Mixed / Dynamic',
    this.secondaryMixedMiasm = '',
    this.psoricFeatures = '',
    this.sycoticFeatures = '',
    this.syphiliticFeatures = '',
    this.tubercularFeatures = '',
    this.cancerinicFeatures = '',
    this.otherMiasmaticIndicators = '',
    this.characteristicSymptoms = '',
    this.finalMiasmaticInterpretation = '',
  });

  Map<String, dynamic> toJson() => {
        'dominantMiasm': dominantMiasm,
        'secondaryMixedMiasm': secondaryMixedMiasm,
        'psoricFeatures': psoricFeatures,
        'sycoticFeatures': sycoticFeatures,
        'syphiliticFeatures': syphiliticFeatures,
        'tubercularFeatures': tubercularFeatures,
        'cancerinicFeatures': cancerinicFeatures,
        'otherMiasmaticIndicators': otherMiasmaticIndicators,
        'characteristicSymptoms': characteristicSymptoms,
        'finalMiasmaticInterpretation': finalMiasmaticInterpretation,
      };

  factory MiasmaticAnalysis.fromJson(Map<String, dynamic> json) =>
      MiasmaticAnalysis(
        dominantMiasm: json['dominantMiasm'] as String? ?? 'Mixed / Dynamic',
        secondaryMixedMiasm: json['secondaryMixedMiasm'] as String? ?? '',
        psoricFeatures: json['psoricFeatures'] as String? ?? '',
        sycoticFeatures: json['sycoticFeatures'] as String? ?? '',
        syphiliticFeatures: json['syphiliticFeatures'] as String? ?? '',
        tubercularFeatures: json['tubercularFeatures'] as String? ?? '',
        cancerinicFeatures: json['cancerinicFeatures'] as String? ?? '',
        otherMiasmaticIndicators: json['otherMiasmaticIndicators'] as String? ?? '',
        characteristicSymptoms: json['characteristicSymptoms'] as String? ?? '',
        finalMiasmaticInterpretation: json['finalMiasmaticInterpretation'] as String? ?? '',
      );

  factory MiasmaticAnalysis.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const MiasmaticAnalysis();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return MiasmaticAnalysis.fromJson(decoded);
    } catch (_) {}
    return MiasmaticAnalysis(dominantMiasm: raw);
  }
}

// 13. CASE ANALYSIS
class CaseTotality {
  final String totalityOfSymptoms;
  final String characteristicSymptoms;
  final String generals;
  final String particulars;
  final String mentalGenerals;
  final String physicalGenerals;
  final String modalities;
  final String concomitants;
  final String causation;
  final String repertoryUsed;
  final String rubricsSelected;
  final String repertorialResult;
  final String materiaMedicaCorrelation;
  final String differentialRemedies;
  final String finalRemedySelection;
  final String potency;
  final String justification;

  const CaseTotality({
    this.totalityOfSymptoms = '',
    this.characteristicSymptoms = '',
    this.generals = '',
    this.particulars = '',
    this.mentalGenerals = '',
    this.physicalGenerals = '',
    this.modalities = '',
    this.concomitants = '',
    this.causation = '',
    this.repertoryUsed = '',
    this.rubricsSelected = '',
    this.repertorialResult = '',
    this.materiaMedicaCorrelation = '',
    this.differentialRemedies = '',
    this.finalRemedySelection = '',
    this.potency = '200CH',
    this.justification = '',
  });

  String get selectedRemedy => finalRemedySelection;
  String get generalsParticulars => '$generals $particulars'.trim();

  Map<String, dynamic> toJson() => {
        'totalityOfSymptoms': totalityOfSymptoms,
        'characteristicSymptoms': characteristicSymptoms,
        'generals': generals,
        'particulars': particulars,
        'mentalGenerals': mentalGenerals,
        'physicalGenerals': physicalGenerals,
        'modalities': modalities,
        'concomitants': concomitants,
        'causation': causation,
        'repertoryUsed': repertoryUsed,
        'rubricsSelected': rubricsSelected,
        'repertorialResult': repertorialResult,
        'materiaMedicaCorrelation': materiaMedicaCorrelation,
        'differentialRemedies': differentialRemedies,
        'finalRemedySelection': finalRemedySelection,
        'potency': potency,
        'justification': justification,
      };

  factory CaseTotality.fromJson(Map<String, dynamic> json) => CaseTotality(
        totalityOfSymptoms: json['totalityOfSymptoms'] as String? ?? '',
        characteristicSymptoms: json['characteristicSymptoms'] as String? ?? '',
        generals: json['generals'] as String? ?? '',
        particulars: json['particulars'] as String? ?? '',
        mentalGenerals: json['mentalGenerals'] as String? ?? '',
        physicalGenerals: json['physicalGenerals'] as String? ?? '',
        modalities: json['modalities'] as String? ?? '',
        concomitants: json['concomitants'] as String? ?? '',
        causation: json['causation'] as String? ?? '',
        repertoryUsed: json['repertoryUsed'] as String? ?? '',
        rubricsSelected: json['rubricsSelected'] as String? ?? '',
        repertorialResult: json['repertorialResult'] as String? ?? '',
        materiaMedicaCorrelation: json['materiaMedicaCorrelation'] as String? ?? '',
        differentialRemedies: json['differentialRemedies'] as String? ?? '',
        finalRemedySelection: json['finalRemedySelection'] as String? ?? json['selectedRemedy'] as String? ?? '',
        potency: json['potency'] as String? ?? '200CH',
        justification: json['justification'] as String? ?? '',
      );

  factory CaseTotality.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const CaseTotality();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('caseTotality')) {
          return CaseTotality.fromJson(decoded['caseTotality'] as Map<String, dynamic>);
        }
        return CaseTotality.fromJson(decoded);
      }
    } catch (_) {}
    return CaseTotality(finalRemedySelection: raw);
  }
}

// 14. DIAGNOSIS / CLINICAL ASSESSMENT
class ClinicalAssessmentDetails {
  final String provisionalDiagnosis;
  final String finalWorkingDiagnosis;
  final String differentialDiagnosis;
  final String comorbidities;
  final String redFlagsReferrals;
  final String clinicalRemarks;

  const ClinicalAssessmentDetails({
    this.provisionalDiagnosis = '',
    this.finalWorkingDiagnosis = '',
    this.differentialDiagnosis = '',
    this.comorbidities = '',
    this.redFlagsReferrals = '',
    this.clinicalRemarks = '',
  });

  Map<String, dynamic> toJson() => {
        'provisionalDiagnosis': provisionalDiagnosis,
        'finalWorkingDiagnosis': finalWorkingDiagnosis,
        'differentialDiagnosis': differentialDiagnosis,
        'comorbidities': comorbidities,
        'redFlagsReferrals': redFlagsReferrals,
        'clinicalRemarks': clinicalRemarks,
      };

  factory ClinicalAssessmentDetails.fromJson(Map<String, dynamic> json) =>
      ClinicalAssessmentDetails(
        provisionalDiagnosis: json['provisionalDiagnosis'] as String? ?? '',
        finalWorkingDiagnosis: json['finalWorkingDiagnosis'] as String? ?? '',
        differentialDiagnosis: json['differentialDiagnosis'] as String? ?? '',
        comorbidities: json['comorbidities'] as String? ?? '',
        redFlagsReferrals: json['redFlagsReferrals'] as String? ?? '',
        clinicalRemarks: json['clinicalRemarks'] as String? ?? '',
      );

  factory ClinicalAssessmentDetails.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const ClinicalAssessmentDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('assessment')) {
          return ClinicalAssessmentDetails.fromJson(decoded['assessment'] as Map<String, dynamic>);
        }
        return ClinicalAssessmentDetails.fromJson(decoded);
      }
    } catch (_) {}
    return ClinicalAssessmentDetails(finalWorkingDiagnosis: raw);
  }
}

// 15. PRESCRIPTION
class PrescriptionPlanDetails {
  final String prescriptionDate;
  final String remedyName;
  final String potency;
  final String dose;
  final String repetitionFrequency;
  final String route;
  final String pharmaceuticalForm;
  final String quantityDispensed;
  final String dietRegimenAdvice;
  final String lifestyleAdvice;
  final String investigationsAdvised;
  final String referralAdvised;
  final String prescriptionRationale;
  final String prescriptionNotes;

  const PrescriptionPlanDetails({
    this.prescriptionDate = '',
    this.remedyName = '',
    this.potency = '',
    this.dose = '',
    this.repetitionFrequency = '',
    this.route = '',
    this.pharmaceuticalForm = '',
    this.quantityDispensed = '',
    this.dietRegimenAdvice = '',
    this.lifestyleAdvice = '',
    this.investigationsAdvised = '',
    this.referralAdvised = '',
    this.prescriptionRationale = '',
    this.prescriptionNotes = '',
  });

  String get dosageForm => pharmaceuticalForm;
  String get doseCount => dose;
  String get frequency => repetitionFrequency;
  String get duration => '';
  String get instructions => dietRegimenAdvice;
  String get dietaryAdvice => dietRegimenAdvice;
  String get referralAdvice => referralAdvised;
  String get rationale => prescriptionRationale;
  String get notes => prescriptionNotes;

  Map<String, dynamic> toJson() => {
        'prescriptionDate': prescriptionDate,
        'remedyName': remedyName,
        'potency': potency,
        'dose': dose,
        'repetitionFrequency': repetitionFrequency,
        'route': route,
        'pharmaceuticalForm': pharmaceuticalForm,
        'quantityDispensed': quantityDispensed,
        'dietRegimenAdvice': dietRegimenAdvice,
        'lifestyleAdvice': lifestyleAdvice,
        'investigationsAdvised': investigationsAdvised,
        'referralAdvised': referralAdvised,
        'prescriptionRationale': prescriptionRationale,
        'prescriptionNotes': prescriptionNotes,
      };

  factory PrescriptionPlanDetails.fromJson(Map<String, dynamic> json) =>
      PrescriptionPlanDetails(
        prescriptionDate: json['prescriptionDate'] as String? ?? '',
        remedyName: json['remedyName'] as String? ?? '',
        potency: json['potency'] as String? ?? '',
        dose: json['dose'] as String? ?? json['doseCount'] as String? ?? '',
        repetitionFrequency: json['repetitionFrequency'] as String? ?? json['frequency'] as String? ?? '',
        route: json['route'] as String? ?? '',
        pharmaceuticalForm: json['pharmaceuticalForm'] as String? ?? json['dosageForm'] as String? ?? '',
        quantityDispensed: json['quantityDispensed'] as String? ?? '',
        dietRegimenAdvice: json['dietRegimenAdvice'] as String? ?? json['dietaryAdvice'] as String? ?? json['instructions'] as String? ?? '',
        lifestyleAdvice: json['lifestyleAdvice'] as String? ?? '',
        investigationsAdvised: json['investigationsAdvised'] as String? ?? '',
        referralAdvised: json['referralAdvised'] as String? ?? json['referralAdvice'] as String? ?? '',
        prescriptionRationale: json['prescriptionRationale'] as String? ?? json['rationale'] as String? ?? '',
        prescriptionNotes: json['prescriptionNotes'] as String? ?? json['notes'] as String? ?? '',
      );

  factory PrescriptionPlanDetails.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const PrescriptionPlanDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return PrescriptionPlanDetails.fromJson(decoded);
    } catch (_) {}
    return PrescriptionPlanDetails(remedyName: raw);
  }
}

// 16. INVESTIGATION
class InvestigationsPlanDetails {
  final String investigationDate;
  final String investigationName;
  final String typePanel;
  final String resultValue;
  final String unit;
  final String referenceRange;
  final String normalAbnormal;
  final String reportSummary;
  final String clinicalInterpretation;
  final String reportReference;

  const InvestigationsPlanDetails({
    this.investigationDate = '',
    this.investigationName = '',
    this.typePanel = '',
    this.resultValue = '',
    this.unit = '',
    this.referenceRange = '',
    this.normalAbnormal = '',
    this.reportSummary = '',
    this.clinicalInterpretation = '',
    this.reportReference = '',
  });

  String get testsAdvised => investigationName;
  String get resultsInterpretation => clinicalInterpretation;

  Map<String, dynamic> toJson() => {
        'investigationDate': investigationDate,
        'investigationName': investigationName,
        'typePanel': typePanel,
        'resultValue': resultValue,
        'unit': unit,
        'referenceRange': referenceRange,
        'normalAbnormal': normalAbnormal,
        'reportSummary': reportSummary,
        'clinicalInterpretation': clinicalInterpretation,
        'reportReference': reportReference,
      };

  factory InvestigationsPlanDetails.fromJson(Map<String, dynamic> json) =>
      InvestigationsPlanDetails(
        investigationDate: json['investigationDate'] as String? ?? '',
        investigationName: json['investigationName'] as String? ?? json['testsAdvised'] as String? ?? '',
        typePanel: json['typePanel'] as String? ?? '',
        resultValue: json['resultValue'] as String? ?? '',
        unit: json['unit'] as String? ?? '',
        referenceRange: json['referenceRange'] as String? ?? '',
        normalAbnormal: json['normalAbnormal'] as String? ?? '',
        reportSummary: json['reportSummary'] as String? ?? '',
        clinicalInterpretation: json['clinicalInterpretation'] as String? ?? json['resultsInterpretation'] as String? ?? '',
        reportReference: json['reportReference'] as String? ?? '',
      );

  factory InvestigationsPlanDetails.fromString(String? raw) {
    if (raw == null || raw.isEmpty) return const InvestigationsPlanDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return InvestigationsPlanDetails.fromJson(decoded);
    } catch (_) {}
    return InvestigationsPlanDetails(investigationName: raw);
  }
}

// 17. FOLLOW-UP
class FollowUpDetails {
  final String followUpDate;
  final String intervalSincePreviousVisit;
  final String overallResponse;
  final String chiefComplaintChanges;
  final String newSymptoms;
  final String aggravation;
  final String improvement;
  final String generalSymptomsChange;
  final String mentalSymptomsChange;
  final String sleepChange;
  final String appetiteThirstChange;
  final String stoolUrineChange;
  final String perspirationChange;
  final String energyChange;
  final String adverseNewSymptoms;
  final String followUpPrescription;
  final String potency;
  final String doseRepetition;
  final String nextFollowUp;
  final String followUpRemarks;

  const FollowUpDetails({
    this.followUpDate = '',
    this.intervalSincePreviousVisit = '',
    this.overallResponse = '',
    this.chiefComplaintChanges = '',
    this.newSymptoms = '',
    this.aggravation = '',
    this.improvement = '',
    this.generalSymptomsChange = '',
    this.mentalSymptomsChange = '',
    this.sleepChange = '',
    this.appetiteThirstChange = '',
    this.stoolUrineChange = '',
    this.perspirationChange = '',
    this.energyChange = '',
    this.adverseNewSymptoms = '',
    this.followUpPrescription = '',
    this.potency = '',
    this.doseRepetition = '',
    this.nextFollowUp = '',
    this.followUpRemarks = '',
  });

  Map<String, dynamic> toJson() => {
        'followUpDate': followUpDate,
        'intervalSincePreviousVisit': intervalSincePreviousVisit,
        'overallResponse': overallResponse,
        'chiefComplaintChanges': chiefComplaintChanges,
        'newSymptoms': newSymptoms,
        'aggravation': aggravation,
        'improvement': improvement,
        'generalSymptomsChange': generalSymptomsChange,
        'mentalSymptomsChange': mentalSymptomsChange,
        'sleepChange': sleepChange,
        'appetiteThirstChange': appetiteThirstChange,
        'stoolUrineChange': stoolUrineChange,
        'perspirationChange': perspirationChange,
        'energyChange': energyChange,
        'adverseNewSymptoms': adverseNewSymptoms,
        'followUpPrescription': followUpPrescription,
        'potency': potency,
        'doseRepetition': doseRepetition,
        'nextFollowUp': nextFollowUp,
        'followUpRemarks': followUpRemarks,
      };

  factory FollowUpDetails.fromJson(Map<String, dynamic> json) => FollowUpDetails(
        followUpDate: json['followUpDate'] as String? ?? '',
        intervalSincePreviousVisit: json['intervalSincePreviousVisit'] as String? ?? '',
        overallResponse: json['overallResponse'] as String? ?? '',
        chiefComplaintChanges: json['chiefComplaintChanges'] as String? ?? '',
        newSymptoms: json['newSymptoms'] as String? ?? '',
        aggravation: json['aggravation'] as String? ?? '',
        improvement: json['improvement'] as String? ?? '',
        generalSymptomsChange: json['generalSymptomsChange'] as String? ?? '',
        mentalSymptomsChange: json['mentalSymptomsChange'] as String? ?? '',
        sleepChange: json['sleepChange'] as String? ?? '',
        appetiteThirstChange: json['appetiteThirstChange'] as String? ?? '',
        stoolUrineChange: json['stoolUrineChange'] as String? ?? '',
        perspirationChange: json['perspirationChange'] as String? ?? '',
        energyChange: json['energyChange'] as String? ?? '',
        adverseNewSymptoms: json['adverseNewSymptoms'] as String? ?? '',
        followUpPrescription: json['followUpPrescription'] as String? ?? '',
        potency: json['potency'] as String? ?? '',
        doseRepetition: json['doseRepetition'] as String? ?? '',
        nextFollowUp: json['nextFollowUp'] as String? ?? '',
        followUpRemarks: json['followUpRemarks'] as String? ?? '',
      );
}

// 18. OUTCOME
class OutcomeDetails {
  final String finalStatus;
  final String degreeOfImprovement;
  final String treatmentDuration;
  final String reasonForDiscontinuation;
  final String lostToFollowUp;
  final String finalOutcomeNotes;

  const OutcomeDetails({
    this.finalStatus = 'Under Active Treatment',
    this.degreeOfImprovement = '',
    this.treatmentDuration = '',
    this.reasonForDiscontinuation = '',
    this.lostToFollowUp = '',
    this.finalOutcomeNotes = '',
  });

  Map<String, dynamic> toJson() => {
        'finalStatus': finalStatus,
        'degreeOfImprovement': degreeOfImprovement,
        'treatmentDuration': treatmentDuration,
        'reasonForDiscontinuation': reasonForDiscontinuation,
        'lostToFollowUp': lostToFollowUp,
        'finalOutcomeNotes': finalOutcomeNotes,
      };

  factory OutcomeDetails.fromJson(Map<String, dynamic> json) => OutcomeDetails(
        finalStatus: json['finalStatus'] as String? ?? 'Under Active Treatment',
        degreeOfImprovement: json['degreeOfImprovement'] as String? ?? '',
        treatmentDuration: json['treatmentDuration'] as String? ?? '',
        reasonForDiscontinuation: json['reasonForDiscontinuation'] as String? ?? '',
        lostToFollowUp: json['lostToFollowUp'] as String? ?? '',
        finalOutcomeNotes: json['finalOutcomeNotes'] as String? ?? '',
      );
}

// 19. DOCUMENTATION
class DocumentationDetails {
  final String dataSource;
  final String originalRegisterReference;
  final String transcriptionNotes;
  final String unclearInformation;

  const DocumentationDetails({
    this.dataSource = '',
    this.originalRegisterReference = '',
    this.transcriptionNotes = '',
    this.unclearInformation = '',
  });

  Map<String, dynamic> toJson() => {
        'dataSource': dataSource,
        'originalRegisterReference': originalRegisterReference,
        'transcriptionNotes': transcriptionNotes,
        'unclearInformation': unclearInformation,
      };

  factory DocumentationDetails.fromJson(Map<String, dynamic> json) =>
      DocumentationDetails(
        dataSource: json['dataSource'] as String? ?? '',
        originalRegisterReference: json['originalRegisterReference'] as String? ?? '',
        transcriptionNotes: json['transcriptionNotes'] as String? ?? '',
        unclearInformation: json['unclearInformation'] as String? ?? '',
      );
}

class MasterCaseRecordData {
  final String? id;
  final String patientId;
  final DateTime recordDate;
  final PatientIdentificationDetails identification;
  final List<ChiefComplaintDetail> chiefComplaints;
  final String additionalComplaints;
  final HpiDetails hpi;
  final PastHistoryDetails pastHistory;
  final FamilyHistoryDetails familyHistory;
  final DevelopmentalHistoryDetails developmentalHistory;
  final PhysicalGenerals physicalGenerals;
  final MentalGenerals mentalGenerals;
  final LifestyleHistoryDetails lifestyleHabits;
  final ClinicalExamVitals clinicalExam;
  final MiasmaticAnalysis miasmaticAnalysis;
  final CaseTotality caseTotality;
  final ClinicalAssessmentDetails clinicalAssessment;
  final PrescriptionPlanDetails baselinePrescription;
  final InvestigationsPlanDetails investigations;
  final FollowUpDetails followUpDetails;
  final String followUpNotes;
  final OutcomeDetails outcomeDetails;
  final String outcome;
  final DocumentationDetails documentation;

  const MasterCaseRecordData({
    this.id,
    required this.patientId,
    required this.recordDate,
    this.identification = const PatientIdentificationDetails(),
    this.chiefComplaints = const [],
    this.additionalComplaints = '',
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
    this.clinicalAssessment = const ClinicalAssessmentDetails(),
    this.baselinePrescription = const PrescriptionPlanDetails(),
    this.investigations = const InvestigationsPlanDetails(),
    this.followUpDetails = const FollowUpDetails(),
    this.followUpNotes = '',
    this.outcomeDetails = const OutcomeDetails(),
    this.outcome = 'Under Active Treatment',
    this.documentation = const DocumentationDetails(),
  });

  String get identificationJson => jsonEncode(identification.toJson());
  String get chiefComplaintsJson => jsonEncode(chiefComplaints.map((c) => c.toJson()).toList());
  String get hpiPackedJson => jsonEncode({
        'hpi': hpi.toJson(),
        'additionalComplaints': additionalComplaints,
        'identification': identification.toJson(),
        'documentation': documentation.toJson(),
      });
  String get hpiJson => hpiPackedJson;
  String get pastHistoryJson => jsonEncode(pastHistory.toJson());
  String get familyHistoryJson => jsonEncode(familyHistory.toJson());
  String get developmentalHistoryJson => jsonEncode(developmentalHistory.toJson());
  String get physicalGeneralsJson => jsonEncode(physicalGenerals.toJson());
  String get mentalGeneralsJson => jsonEncode(mentalGenerals.toJson());
  String get lifestyleJson => jsonEncode(lifestyleHabits.toJson());
  String get clinicalExamJson => jsonEncode(clinicalExam.toJson());
  String get miasmaticAnalysisJson => jsonEncode(miasmaticAnalysis.toJson());
  String get caseTotalityPackedJson => jsonEncode({
        'caseTotality': caseTotality.toJson(),
        'assessment': clinicalAssessment.toJson(),
      });
  String get caseTotalityJson => caseTotalityPackedJson;
  String get baselinePrescriptionJson => jsonEncode(baselinePrescription.toJson());
  String get investigationsJson => jsonEncode(investigations.toJson());
  String get followUpPackedJson => jsonEncode(followUpDetails.toJson());
  String get outcomePackedJson => jsonEncode(outcomeDetails.toJson());
  String get documentationJson => jsonEncode(documentation.toJson());

  static List<ChiefComplaintDetail> parseChiefComplaints(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => ChiefComplaintDetail.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  static PatientIdentificationDetails parseIdentification(String? raw) {
    if (raw == null || raw.isEmpty) return const PatientIdentificationDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('identification')) {
          return PatientIdentificationDetails.fromJson(decoded['identification'] as Map<String, dynamic>);
        }
        return PatientIdentificationDetails.fromJson(decoded);
      }
    } catch (_) {}
    return const PatientIdentificationDetails();
  }

  static String parseAdditionalComplaints(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> && decoded.containsKey('additionalComplaints')) {
        return decoded['additionalComplaints'] as String? ?? '';
      }
    } catch (_) {}
    return '';
  }

  static DocumentationDetails parseDocumentation(String? raw) {
    if (raw == null || raw.isEmpty) return const DocumentationDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('documentation')) {
          return DocumentationDetails.fromJson(decoded['documentation'] as Map<String, dynamic>);
        }
        return DocumentationDetails.fromJson(decoded);
      }
    } catch (_) {}
    return const DocumentationDetails();
  }

  static HpiDetails parseHpi(String? raw) {
    if (raw == null || raw.isEmpty) return const HpiDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('hpi')) {
          return HpiDetails.fromJson(decoded['hpi'] as Map<String, dynamic>);
        }
        return HpiDetails.fromJson(decoded);
      }
    } catch (_) {}
    return HpiDetails(chronologicalDevelopment: raw);
  }

  static PastHistoryDetails parsePastHistory(String? raw) => PastHistoryDetails.fromString(raw);
  static FamilyHistoryDetails parseFamilyHistory(String? raw) => FamilyHistoryDetails.fromString(raw);
  static DevelopmentalHistoryDetails parseDevHistory(String? raw) => DevelopmentalHistoryDetails.fromString(raw);
  static PhysicalGenerals parsePhysicalGenerals(String? raw) => PhysicalGenerals.fromString(raw);
  static MentalGenerals parseMentalGenerals(String? raw) => MentalGenerals.fromString(raw);
  static LifestyleHistoryDetails parseLifestyle(String? raw) => LifestyleHistoryDetails.fromString(raw);
  static ClinicalExamVitals parseClinicalExam(String? raw) => ClinicalExamVitals.fromString(raw);
  static MiasmaticAnalysis parseMiasmaticAnalysis(String? raw) => MiasmaticAnalysis.fromString(raw);
  static CaseTotality parseCaseTotality(String? raw) => CaseTotality.fromString(raw);
  static ClinicalAssessmentDetails parseAssessment(String? raw) => ClinicalAssessmentDetails.fromString(raw);
  static PrescriptionPlanDetails parsePrescription(String? raw) => PrescriptionPlanDetails.fromString(raw);
  static InvestigationsPlanDetails parseInvestigations(String? raw) => InvestigationsPlanDetails.fromString(raw);

  String get displayOutcome {
    final status = outcomeDetails.finalStatus.trim();
    if (status.isNotEmpty && !status.startsWith('{')) {
      return status;
    }
    final rawOutcome = outcome.trim();
    if (rawOutcome.isNotEmpty && !rawOutcome.startsWith('{')) {
      return rawOutcome;
    }
    return 'Under Active Treatment';
  }

  static FollowUpDetails parseFollowUp(String? raw) {
    if (raw == null || raw.isEmpty) return const FollowUpDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return FollowUpDetails.fromJson(decoded);
    } catch (_) {}
    return FollowUpDetails(followUpRemarks: raw);
  }

  static OutcomeDetails parseOutcome(String? raw) {
    if (raw == null || raw.isEmpty) return const OutcomeDetails();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return OutcomeDetails.fromJson(decoded);
    } catch (_) {}
    if (raw.startsWith('{')) return const OutcomeDetails();
    return OutcomeDetails(finalStatus: raw);
  }
}
