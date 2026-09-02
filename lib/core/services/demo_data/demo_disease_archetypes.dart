/// Medical archetypes representing real-world homeopathic clinical profiles.
class DiseaseArchetype {
  final String primaryDisease;
  final String chiefComplaint;
  final String location;
  final String side;
  final String onset;
  final String duration;
  final String sensation;
  final String aggravatingFactors;
  final String amelioratingFactors;
  final String concomitants;
  final String causation;
  final String periodicity;
  final int initialSeverity;

  // Case Taking / Generals
  final String thermal;
  final String thirst;
  final String appetite;
  final String sleep;
  final String mentalGenerals;
  final String miasm;
  final String pastHistory;
  final String familyHistory;

  // Prescription
  final String primaryRemedy;
  final String primaryPotency;
  final String followUpRemedy;
  final String followUpPotency;
  final String doseCount;
  final String frequency;
  final String vehicle;
  final String instructions;
  final String dietaryAdvice;
  final double medicineFee;

  // Lab Investigation
  final String testCategory;
  final String testName;
  final double? numericValue;
  final String? stringValue;
  final String? unit;
  final double? refMin;
  final double? refMax;
  final String flag;
  final String labName;
  final String testNotes;

  const DiseaseArchetype({
    required this.primaryDisease,
    required this.chiefComplaint,
    required this.location,
    required this.side,
    required this.onset,
    required this.duration,
    required this.sensation,
    required this.aggravatingFactors,
    required this.amelioratingFactors,
    required this.concomitants,
    required this.causation,
    required this.periodicity,
    required this.initialSeverity,
    required this.thermal,
    required this.thirst,
    required this.appetite,
    required this.sleep,
    required this.mentalGenerals,
    required this.miasm,
    required this.pastHistory,
    required this.familyHistory,
    required this.primaryRemedy,
    required this.primaryPotency,
    required this.followUpRemedy,
    required this.followUpPotency,
    required this.doseCount,
    required this.frequency,
    required this.vehicle,
    required this.instructions,
    required this.dietaryAdvice,
    required this.medicineFee,
    required this.testCategory,
    required this.testName,
    this.numericValue,
    this.stringValue,
    this.unit,
    this.refMin,
    this.refMax,
    required this.flag,
    required this.labName,
    required this.testNotes,
  });
}

class DemoArchetypes {
  static const List<DiseaseArchetype> all = [
    // 1. Joint Pain / Osteoarthritis
    DiseaseArchetype(
      primaryDisease: 'Joint Pain / Osteoarthritis',
      chiefComplaint:
          'Severe aching pain and stiffness in bilateral knee joints with cracking sounds on walking.',
      location: 'Bilateral knee joints and lumbar spine',
      side: 'Bilateral',
      onset: 'Gradual over 2 years',
      duration: '2 years, worse last 3 months',
      sensation: 'Stitching, tearing pain with intense morning stiffness',
      aggravatingFactors:
          '< First movement, < Cold damp weather, < Prolonged sitting, < Ascending stairs',
      amelioratingFactors:
          '> Continued gentle walking, > Warm fomentation, > Dry warm weather',
      concomitants: 'Swelling around patella and mild ankle edema in evenings',
      causation: 'Age-related wear & tear, previous knee sprain',
      periodicity: 'Aggravation during monsoon and winter seasons',
      initialSeverity: 8,
      thermal: 'Chilly patient, easily catches cold from draft',
      thirst: 'Thirst for small sips of warm water frequently',
      appetite: 'Moderate, prone to flatulence after pulses',
      sleep:
          'Restless sleep due to joint discomfort, frequent position changes',
      mentalGenerals:
          'Mild, weeping disposition, anxious about mobility and independence',
      miasm: 'Sycotic with Psoric background',
      pastHistory: 'History of chikungunya 4 years ago',
      familyHistory: 'Mother had severe rheumatoid arthritis and osteoporosis',
      primaryRemedy: 'Rhus Toxicodendron',
      primaryPotency: '200C',
      followUpRemedy: 'Calcarea Fluorica',
      followUpPotency: '6X',
      doseCount: '4 pills',
      frequency: 'BD (Twice daily)',
      vehicle: 'Sugar globules No. 30',
      instructions: 'Dissolve under tongue. Take 30 mins before meals.',
      dietaryAdvice:
          'Avoid sour foods, curds at night, and cold drinks. Daily gentle knee quadriceps exercises.',
      medicineFee: 350.0,
      testCategory: 'Imaging / Radiology',
      testName: 'Bilateral Knee X-Ray (AP & Lateral View)',
      stringValue: 'Grade 3 joint space narrowing with marginal osteophytes',
      flag: 'Abnormal',
      labName: 'Apollo Diagnostics Centre',
      testNotes:
          'Confirmed degenerative osteoarthritis with mild subchondral sclerosis.',
    ),

    // 2. Allergic Rhinitis / Dust Allergy
    DiseaseArchetype(
      primaryDisease: 'Allergic Rhinitis / Dust Allergy',
      chiefComplaint:
          'Paroxysmal sneezing (15-20 bouts) every morning with watery rhinorrhea and itchy palate.',
      location: 'Nose, eyes, and nasopharynx',
      side: 'Bilateral',
      onset: 'Sudden upon waking up',
      duration: '5 years chronic',
      sensation:
          'Tickling in nostrils, burning watery discharge causing redness of upper lip',
      aggravatingFactors:
          '< Dust exposure, < Morning draft of air, < Cold AC air, < Sweeping house',
      amelioratingFactors:
          '> Warm room, > Hot tea/steam inhalation, > Sun exposure',
      concomitants:
          'Lachrymation, mild frontal headache, and dark circles under eyes',
      causation: 'House dust mite sensitivity, sudden temperature shift',
      periodicity: 'Daily morning attacks between 6 AM and 8 AM',
      initialSeverity: 8,
      thermal: 'Extremely chilly, wraps up warmly even in mild weather',
      thirst: 'Thirsty for warm sips at short intervals',
      appetite: 'Good, fond of spicy food and warm soups',
      sleep: 'Disturbed due to blocked nose at night',
      mentalGenerals:
          'Fastidious, neat and tidy, anxious regarding health and cleanliness',
      miasm: 'Tubercular (Psoro-Sycotic)',
      pastHistory: 'Childhood eczema suppressed with steroid ointments',
      familyHistory: 'Father has chronic bronchial asthma',
      primaryRemedy: 'Arsenicum Album',
      primaryPotency: '30C',
      followUpRemedy: 'Tuberculinum',
      followUpPotency: '200C',
      doseCount: '4 pills',
      frequency: 'TDS (Three times daily)',
      vehicle: 'Sugar globules No. 30',
      instructions: 'Take 4 globules on clean tongue. Avoid camphor/raw onion.',
      dietaryAdvice:
          'Avoid refrigerated items, ice creams, and aerated drinks. Use dust covers on pillows.',
      medicineFee: 280.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Absolute Eosinophil Count (AEC)',
      numericValue: 680.0,
      unit: '/mcL',
      refMin: 40.0,
      refMax: 450.0,
      flag: 'High',
      labName: 'Suraksha Diagnostic Lab',
      testNotes: 'Elevated eosinophils indicating allergic diathesis.',
    ),

    // 3. Migraine / Chronic Headache
    DiseaseArchetype(
      primaryDisease: 'Migraine / Chronic Headache',
      chiefComplaint:
          'Unilateral right-sided throbbing, bursting headache starting over eye and extending to occiput.',
      location: 'Right temple, forehead, extending to neck',
      side: 'Right',
      onset: 'Gradual in morning, peaks at noon',
      duration: '4 years, attacks twice weekly',
      sensation:
          'Hammering, pulsating pain as if thousand hammers beating inside head',
      aggravatingFactors:
          '< Sun exposure, < Bright light, < Noise, < Mental exertion, < Skipping meals',
      amelioratingFactors:
          '> Lying in dark quiet room, > Hard pressure, > Sleep, > Cold compress',
      concomitants: 'Nausea, blurred vision with zigzag aura, photophobia',
      causation: 'Prolonged screen time, emotional grief, dehydration',
      periodicity:
          'Increases with sunrise, peaks at 12-1 PM, subsides at sunset',
      initialSeverity: 9,
      thermal: 'Hot patient, cannot tolerate sun heat',
      thirst: 'Excessive thirst for large quantities of cold water',
      appetite: 'Craves salty foods and pickles, hates bread and fatty meals',
      sleep: 'Sleep unrefreshing, dreams of thieves and robbers',
      mentalGenerals:
          'Introverted, reserved, grieves silently, < from consolation',
      miasm: 'Psoric',
      pastHistory: 'History of chronic anaemia 3 years back',
      familyHistory: 'Maternal aunt suffered from severe hemicrania',
      primaryRemedy: 'Natrum Muriaticum',
      primaryPotency: '200C',
      followUpRemedy: 'Sanguinaria Canadensis',
      followUpPotency: '30C',
      doseCount: '4 pills',
      frequency: 'BD (Twice daily)',
      vehicle: 'Sugar globules No. 30',
      instructions:
          'Take 4 pills early morning empty stomach and night before bed.',
      dietaryAdvice:
          'Maintain regular meal timings. Avoid aged cheese, dark chocolates, and prolonged screen strain.',
      medicineFee: 320.0,
      testCategory: 'Imaging / Radiology',
      testName: 'Brain MRI (Plain)',
      stringValue:
          'Normal brain parenchyma, no intracranial mass or vascular malformation',
      flag: 'Normal',
      labName: 'Peerless Hospital & Diagnostics',
      testNotes:
          'Rule out secondary intracranial pathology. Consistent with classic migraine.',
    ),

    // 4. Polycystic Ovarian Disease (PCOD)
    DiseaseArchetype(
      primaryDisease: 'Polycystic Ovarian Disease (PCOD)',
      chiefComplaint:
          'Irregular delayed menses (cycle 45-60 days), scanty flow, acne breakouts on chin and hirsutism.',
      location: 'Pelvis and lower abdomen',
      side: 'Bilateral',
      onset: 'Gradual over 1.5 years',
      duration: '18 months',
      sensation: 'Dull dragging heaviness in lower abdomen before periods',
      aggravatingFactors:
          '< Warm room, < Fatty foods, < Emotional stress, < Wet feet',
      amelioratingFactors:
          '> Open cool fresh air, > Gentle walking, > Consolation',
      concomitants:
          'Sudden weight gain (8 kg in 6 months), facial hair growth, mood swings',
      causation: 'Sedentary desk job, hormonal imbalance post exam stress',
      periodicity: 'Cycles delayed by 15-30 days every month',
      initialSeverity: 7,
      thermal: 'Warm patient, desires open air and windows open',
      thirst: 'Thirstless, drinks water only when forced',
      appetite:
          'Aversion to fats and butter, craves pastries and sweet desserts',
      sleep: 'Sleeps late, dreams of falling',
      mentalGenerals:
          'Gentle, yielding disposition, weeps easily while narrating complaints, seeks reassurance',
      miasm: 'Sycotic',
      pastHistory: 'History of recurrent tonsillitis in teenage',
      familyHistory: 'Sister diagnosed with hypothyroidism and PCOD',
      primaryRemedy: 'Pulsatilla Nigricans',
      primaryPotency: '200C',
      followUpRemedy: 'Sepia Officinalis',
      followUpPotency: '1M',
      doseCount: '4 pills',
      frequency: 'OD (Once daily in morning)',
      vehicle: 'Sugar globules No. 30',
      instructions: '4 globules in morning on empty stomach for 21 days.',
      dietaryAdvice:
          'Low glycemic index diet. Daily 45 minutes brisk walking. Eliminate refined sugars and dairy.',
      medicineFee: 400.0,
      testCategory: 'Imaging / Radiology',
      testName: 'Pelvic Ultrasound (USG)',
      stringValue:
          'Bilateral ovaries enlarged with multiple peripheral follicles (>12) and increased stromal echogenicity',
      flag: 'Abnormal',
      labName: 'Pulse Diagnostics Lab',
      testNotes:
          'Classic ultrasound appearance of bilateral polycystic ovarian morphology.',
    ),

    // 5. Hypothyroidism & Weight Gain
    DiseaseArchetype(
      primaryDisease: 'Hypothyroidism & Weight Gain',
      chiefComplaint:
          'Generalized sluggishness, chronic fatigue, cold intolerance, constipation, and unexplained weight gain.',
      location: 'Systemic / Thyroid gland',
      side: 'Central',
      onset: 'Gradual over 1 year',
      duration: '1 year',
      sensation: 'Feeling bloated, heavy, and lethargic all day long',
      aggravatingFactors: '< Cold weather, < Morning on waking, < Overexertion',
      amelioratingFactors: '> Warm covering, > Rest, > Afternoon naps',
      concomitants:
          'Dry scaly skin, diffuse hair thinning, puffy face around eyes in morning',
      causation: 'Autoimmune thyroiditis (Hashimoto\'s diathesis)',
      periodicity: 'Persistent daily lethargy',
      initialSeverity: 7,
      thermal: 'Extremely chilly, wears sweaters even during autumn',
      thirst: 'Moderate thirst for room-temperature liquids',
      appetite: 'Low appetite yet gaining weight easily',
      sleep: 'Hypersomnia, feels unrefreshed despite 9 hours sleep',
      mentalGenerals: 'Slow comprehension, memory lapses, low enthusiasm',
      miasm: 'Sycotic / Psoro-Sycotic',
      pastHistory: 'Recurrent throat infections in childhood',
      familyHistory: 'Mother and maternal grandmother both hypothyroid',
      primaryRemedy: 'Thyroidinum',
      primaryPotency: '3X (Trituration)',
      followUpRemedy: 'Calcarea Carbonica',
      followUpPotency: '200C',
      doseCount: '2 tablets',
      frequency: 'BD (Twice daily)',
      vehicle: 'Trituration Tablets',
      instructions: 'Chew 2 tablets twice daily 30 minutes before meals.',
      dietaryAdvice:
          'Include selenium-rich foods, iodized salt in moderation. Avoid raw cabbage, cauliflower, and soy.',
      medicineFee: 380.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Thyroid Function Profile (TSH, Free T3, Free T4)',
      numericValue: 8.95,
      unit: 'uIU/mL',
      refMin: 0.35,
      refMax: 4.94,
      flag: 'High',
      labName: 'Dr. Lal PathLabs',
      testNotes: 'Elevated TSH confirming subclinical primary hypothyroidism.',
    ),

    // 6. Hypertension & Arteriosclerosis
    DiseaseArchetype(
      primaryDisease: 'Hypertension & Arteriosclerosis',
      chiefComplaint:
          'Fluctuating high blood pressure (155/95 mmHg) with occipital heaviness and flushing of face.',
      location: 'Cardiovascular system / Occiput',
      side: 'Central',
      onset: 'Insidious over 3 years',
      duration: '3 years',
      sensation:
          'Throbbing pulsation in temples and neck arteries with mild dizziness',
      aggravatingFactors:
          '< Mental stress, < Physical exertion, < High salt intake, < Sleeplessness',
      amelioratingFactors:
          '> Quiet rest in semi-reclined position, > Fresh cool breeze',
      concomitants:
          'Occasional palpitation on climbing stairs, tinnitus in left ear',
      causation:
          'High-stress corporate job, family history of coronary disease',
      periodicity: 'BP spikes usually noted between 5 PM and 8 PM',
      initialSeverity: 7,
      thermal: 'Ambithermal, prefers well-ventilated rooms',
      thirst: 'Normal thirst for cold water',
      appetite: 'Tendency to overeat when stressed',
      sleep: 'Interrupted sleep, wakes up at 3 AM with anxious thoughts',
      mentalGenerals:
          'Ambitious, type-A personality, impatient, quick-tempered',
      miasm: 'Syphilitic / Sycotic',
      pastHistory: 'History of hyperlipidemia for 5 years',
      familyHistory: 'Father suffered myocardial infarction at age 58',
      primaryRemedy: 'Rauwolfia Serpentina',
      primaryPotency: 'Q (Mother Tincture)',
      followUpRemedy: 'Baryta Muriatica',
      followUpPotency: '30C',
      doseCount: '12 drops',
      frequency: 'BD in half cup water',
      vehicle: 'Aqua Distillata',
      instructions:
          'Take 12 drops in half cup of plain water twice daily after food.',
      dietaryAdvice:
          'Strict low sodium (<2g/day) DASH diet. Daily 30 mins aerobic walking. Practice deep breathing.',
      medicineFee: 420.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Lipid Profile (Total Cholesterol & Triglycerides)',
      numericValue: 245.0,
      unit: 'mg/dL',
      refMin: 125.0,
      refMax: 200.0,
      flag: 'High',
      labName: 'Apollo Diagnostics Centre',
      testNotes:
          'Hypercholesterolemia with elevated LDL (158 mg/dL) and borderline triglycerides (190 mg/dL).',
    ),

    // 7. GERD / Acid Peptic Disorder
    DiseaseArchetype(
      primaryDisease: 'GERD / Acid Peptic Disorder',
      chiefComplaint:
          'Retro-sternal burning heart-burn, sour waterbrash, and epigastric discomfort 1 hour after meals.',
      location: 'Epigastrium and esophagus',
      side: 'Central',
      onset: 'Subacute over 8 months',
      duration: '8 months',
      sensation:
          'Burning, sour acid regurgitation reaching the throat with painful bloating',
      aggravatingFactors:
          '< Spicy oily foods, < Coffee/tea, < Lying down immediately after eating, < Alcohol',
      amelioratingFactors:
          '> Cold milk, > Warm sips of water, > Sitting upright',
      concomitants:
          'Frequent burping with sour taste, nausea in morning, coated tongue',
      causation: 'Irregular eating habits, late-night dinners, stress',
      periodicity: 'Aggravation nightly around 11 PM - 1 AM after lying in bed',
      initialSeverity: 8,
      thermal: 'Chilly, sensitive to cold drafts',
      thirst: 'Small sips of water frequently',
      appetite: 'Hungry but afraid to eat due to subsequent burning pain',
      sleep: 'Sleep disturbed by acid reflux coughing',
      mentalGenerals:
          'Irritable, easily angered by contradiction, critical, workaholic',
      miasm: 'Psoric with Sycotic overlay',
      pastHistory: 'Chronic amoebiasis in past',
      familyHistory: 'Father had peptic ulcer disease',
      primaryRemedy: 'Nux Vomica',
      primaryPotency: '200C',
      followUpRemedy: 'Robinia Pseudacacia',
      followUpPotency: '30C',
      doseCount: '4 pills',
      frequency: 'Bedtime single dose',
      vehicle: 'Sugar globules No. 30',
      instructions: 'Take 4 globules at bedtime daily.',
      dietaryAdvice:
          'Do not lie down for 2 hours post meals. Elevate head of bed by 6 inches. Avoid tea, coffee, and fried snacks.',
      medicineFee: 260.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Serum Amylase & Liver Enzymes (SGPT/ALT)',
      numericValue: 38.0,
      unit: 'U/L',
      refMin: 0.0,
      refMax: 45.0,
      flag: 'Normal',
      labName: 'Suraksha Diagnostic Lab',
      testNotes:
          'Normal liver function. Upper GI endoscopy advised if symptoms persist.',
    ),

    // 8. Eczema & Atopic Dermatitis
    DiseaseArchetype(
      primaryDisease: 'Eczema & Atopic Dermatitis',
      chiefComplaint:
          'Dry, lichenified, itchy erythematous patches with peeling and occasional serous oozing on flexures.',
      location: 'Ante-cubital fossae, popliteal fossae, and hands',
      side: 'Bilateral',
      onset: 'Chronic recurrent since 3 years',
      duration: '3 years',
      sensation:
          'Intolerable burning itching making the patient scratch until it bleeds',
      aggravatingFactors:
          '< Night in bed, < Washing with soap/water, < Woolen clothing, < Sweating',
      amelioratingFactors:
          '> Cool open air, > Gentle stroking, > Dry cool climate',
      concomitants: 'Dry brittle nails, intense thirst, offensive sweat',
      causation: 'Atopic diathesis, chemical exposure from detergents',
      periodicity: 'Severe flare-ups every change of season',
      initialSeverity: 8,
      thermal: 'Warm patient, throws off bed covers, burning palms and soles',
      thirst: 'Drinks large quantities of cold water at long intervals',
      appetite: 'Craves sweets, spicy food, hates milk',
      sleep: 'Restless due to nocturnal itching between 11 PM and 2 AM',
      mentalGenerals:
          'Philosophical, untidy, dislikes bathing, irritable when disturbed',
      miasm: 'Psoric (Pure Psora)',
      pastHistory: 'Suppressed ringworm infection 4 years ago',
      familyHistory: 'Mother has bronchial asthma and dust allergy',
      primaryRemedy: 'Sulphur',
      primaryPotency: '200C',
      followUpRemedy: 'Graphites',
      followUpPotency: '30C',
      doseCount: '4 pills',
      frequency: 'Weekly single dose (Sunday morning)',
      vehicle: 'Sugar globules No. 30',
      instructions: 'Take single dose on empty stomach once weekly.',
      dietaryAdvice:
          'Apply virgin coconut oil locally. Avoid synthetic soaps, eggs, and brinjal. Use cotton clothing.',
      medicineFee: 310.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Total Serum IgE Level',
      numericValue: 840.0,
      unit: 'IU/mL',
      refMin: 0.0,
      refMax: 100.0,
      flag: 'High',
      labName: 'Dr. Lal PathLabs',
      testNotes:
          'Markedly elevated total IgE confirming severe atopic dermatitis.',
    ),

    // 9. Renal Calculi (Kidney Stone)
    DiseaseArchetype(
      primaryDisease: 'Renal Calculi (Kidney Stone)',
      chiefComplaint:
          'Severe paroxysmal colicky pain in left flank radiating down along ureter to groin with dysuria.',
      location: 'Left loin to groin (ureteric course)',
      side: 'Left',
      onset: 'Sudden sharp onset 5 days ago',
      duration: '5 days acute episode on chronic history',
      sensation:
          'Excruciating sharp cutting, spasming pain with burning micturition',
      aggravatingFactors: '< Motion, < Jarring, < Pressure, < Standing erect',
      amelioratingFactors:
          '> Lying on painful side, > Warm application, > Passing urine',
      concomitants:
          'Nausea, cold clammy sweat, mild microscopic hematuria, urgent desire to urinate',
      causation: 'Low water intake, high dietary calcium oxalate consumption',
      periodicity: 'Spasms occur every 3-4 hours',
      initialSeverity: 9,
      thermal: 'Chilly, feels shiver during pain paroxysm',
      thirst: 'Desires warm drinks during pain',
      appetite: 'Suppressed due to nausea',
      sleep: 'Unable to sleep due to unbearable colic',
      mentalGenerals: 'Anxious, restless, moans with every spasm of pain',
      miasm: 'Sycotic',
      pastHistory: 'Passed small gravel in urine 1.5 years ago',
      familyHistory: 'Father had recurrent kidney stones',
      primaryRemedy: 'Berberis Vulgaris',
      primaryPotency: 'Q (Mother Tincture)',
      followUpRemedy: 'Lycopodium Clavatum',
      followUpPotency: '200C',
      doseCount: '15 drops',
      frequency: 'TDS in lukewarm water',
      vehicle: 'Aqua Distillata',
      instructions: '15 drops in half glass lukewarm water three times daily.',
      dietaryAdvice:
          'Drink 3.5 - 4 liters of filtered water daily. Avoid spinach, tomatoes with seeds, beets, and carbonated beverages.',
      medicineFee: 360.0,
      testCategory: 'Imaging / Radiology',
      testName: 'USG Kidney, Ureter & Bladder (KUB)',
      stringValue:
          'Single calculus measuring 5.8 mm in lower third of left ureter with mild hydroureteronephrosis',
      flag: 'Abnormal',
      labName: 'Pulse Diagnostics Lab',
      testNotes:
          'Left ureteric calculus suitable for medical expulsion therapy without surgical intervention.',
    ),

    // 10. Sciatica & Lumbar Spondylosis
    DiseaseArchetype(
      primaryDisease: 'Sciatica & Lumbar Spondylosis',
      chiefComplaint:
          'Sharp shooting pain from right lower back down posterior thigh to calf and heel with numbness.',
      location: 'L4-L5 lumbar region radiating down right lower limb',
      side: 'Right',
      onset: 'Acute onset after lifting heavy luggage 3 weeks ago',
      duration: '3 weeks',
      sensation:
          'Electric shock-like, shooting neuralgic pain with pins-and-needles numbness in right foot',
      aggravatingFactors:
          '< Forward bending, < Sitting on hard chair, < Coughing/sneezing, < Cold draft',
      amelioratingFactors:
          '> Lying flat on back with knees flexed, > Hard pressure, > Heat',
      concomitants:
          'Stiffness in lower lumbar muscles, inability to lift right leg past 45 degrees',
      causation:
          'Mechanical strain leading to L4-L5 disc bulge with nerve root compression',
      periodicity: 'Pain worse in morning on rising and after sitting 30 mins',
      initialSeverity: 9,
      thermal: 'Chilly, sensitive to AC and cold floors',
      thirst: 'Moderate, drinks room temperature water',
      appetite: 'Normal',
      sleep: 'Disturbed when turning in bed',
      mentalGenerals: 'Irritable from severe pain, wants to be left alone',
      miasm: 'Psoro-Sycotic',
      pastHistory: 'Chronic intermittent low back pain for 2 years',
      familyHistory: 'No specific spine disease',
      primaryRemedy: 'Colocynthis',
      primaryPotency: '200C',
      followUpRemedy: 'Hypericum Perforatum',
      followUpPotency: '200C',
      doseCount: '4 pills',
      frequency: 'TDS (Three times daily)',
      vehicle: 'Sugar globules No. 30',
      instructions: '4 globules on clean tongue. Avoid hard physical strain.',
      dietaryAdvice:
          'Avoid forward bending. Use ergonomic chair and lumbar support pillow. Sleep on firm mattress.',
      medicineFee: 330.0,
      testCategory: 'Imaging / Radiology',
      testName: 'MRI Lumbosacral Spine (L-S Spine)',
      stringValue:
          'Posterolateral disc protrusion at L4-L5 causing right exiting L4 and traversing L5 nerve root impingement',
      flag: 'Abnormal',
      labName: 'Peerless Hospital & Diagnostics',
      testNotes:
          'Confirmed right-sided L4-L5 radiculopathy with mild canal stenosis.',
    ),

    // 11. Piles & Anal Fissure
    DiseaseArchetype(
      primaryDisease: 'Piles & Anal Fissure',
      chiefComplaint:
          'Painful bleeding per rectum during defecation with severe burning pain lasting 2-3 hours after stool.',
      location: 'Anal canal / Rectum',
      side: 'Central',
      onset: 'Subacute 4 months',
      duration: '4 months',
      sensation:
          'Sharp cutting like glass shards passing through rectum, fullness like sticks in rectum',
      aggravatingFactors:
          '< Hard stool, < Straining, < Prolonged sitting, < Spicy food',
      amelioratingFactors: '> Warm sitz bath, > Soft stool, > Lying prone',
      concomitants:
          'Chronic constipation, bright red blood dripping into pan after stool',
      causation: 'Chronic constipation, low dietary fiber, sedentary habits',
      periodicity: 'Daily torment every morning after bowel movement',
      initialSeverity: 8,
      thermal: 'Warm patient with sluggish circulation',
      thirst: 'Low thirst',
      appetite: 'Poor appetite, afraid to eat due to fear of passing stool',
      sleep: 'Restless',
      mentalGenerals: 'Anxious, depressed about chronic anal pain, irritable',
      miasm: 'Sycotic / Syphilitic',
      pastHistory: 'History of fissure 2 years back',
      familyHistory: 'Mother had varicose veins and hemorrhoids',
      primaryRemedy: 'Ratanhia Peruviana',
      primaryPotency: '30C',
      followUpRemedy: 'Aesculus Hippocastanum',
      followUpPotency: '200C',
      doseCount: '4 pills',
      frequency: 'TDS (Three times daily)',
      vehicle: 'Sugar globules No. 30',
      instructions:
          'Take 4 globules 30 mins before meals. Take warm sitz bath twice daily.',
      dietaryAdvice:
          'High fiber diet with isabgol husk at bedtime. Drink 3 liters of water. Avoid chilies, fried food, and red meat.',
      medicineFee: 310.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Complete Blood Count (CBC) & Hemoglobin',
      numericValue: 11.2,
      unit: 'g/dL',
      refMin: 13.0,
      refMax: 17.0,
      flag: 'Low',
      labName: 'Suraksha Diagnostic Lab',
      testNotes:
          'Mild normocytic normochromic anemia secondary to chronic rectal blood loss.',
    ),

    // 12. Acne Vulgaris & Dandruff
    DiseaseArchetype(
      primaryDisease: 'Acne Vulgaris & Dandruff',
      chiefComplaint:
          'Persistent inflammatory papules, pustules, and dark post-acne blemishes across cheeks and forehead.',
      location: 'Face (cheeks, forehead, jawline) and scalp',
      side: 'Bilateral',
      onset: 'Gradual over 10 months',
      duration: '10 months',
      sensation: 'Tender painful lesions, itchy scalp with dry flaky dandruff',
      aggravatingFactors:
          '< Oily cosmetics, < Oily junk food, < Premenstrual period, < Humid weather',
      amelioratingFactors:
          '> Washing face with plain water, > Open cool breeze',
      concomitants:
          'Oily greasy facial skin with prominent comedones (blackheads)',
      causation: 'Sebaceous gland hyper-activity and hormonal fluctuations',
      periodicity: 'Worse 5-7 days prior to menstrual cycle',
      initialSeverity: 7,
      thermal: 'Ambithermal',
      thirst: 'Normal thirst',
      appetite: 'Craves fried snacks, chocolates, and fast foods',
      sleep: 'Sleeps late due to phone screen use',
      mentalGenerals:
          'Self-conscious about appearance, low confidence in social interactions',
      miasm: 'Psoro-Sycotic',
      pastHistory: 'No major past illness',
      familyHistory: 'Both parents had severe acne in youth',
      primaryRemedy: 'Berberis Aquifolium',
      primaryPotency: 'Q (Mother Tincture)',
      followUpRemedy: 'Hepar Sulphuris',
      followUpPotency: '200C',
      doseCount: '10 drops',
      frequency: 'BD in half cup water',
      vehicle: 'Aqua Distillata',
      instructions:
          '10 drops orally twice daily. Also apply diluted 1:1 with rosewater externally on blemishes at bedtime.',
      dietaryAdvice:
          'Drink 3 liters of water daily. Avoid dairy butter, cheese, chocolates, and oily roadside food.',
      medicineFee: 290.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Liver Function Test (LFT - SGPT & Bilirubin)',
      numericValue: 24.0,
      unit: 'U/L',
      refMin: 0.0,
      refMax: 40.0,
      flag: 'Normal',
      labName: 'Dr. Lal PathLabs',
      testNotes:
          'Normal liver biochemistry. Clear skin clearance expected within 8-12 weeks.',
    ),

    // 13. Chronic Bronchial Asthma
    DiseaseArchetype(
      primaryDisease: 'Chronic Bronchial Asthma',
      chiefComplaint:
          'Wheezing, chest tightness, and suffocative cough with difficulty in breathing especially at midnight.',
      location: 'Lungs and bronchi',
      side: 'Bilateral',
      onset: 'Recurrent attacks since childhood',
      duration: '6 years chronic',
      sensation:
          'Constriction as if chest banded tightly, cannot inhale enough air',
      aggravatingFactors:
          '< 1 AM - 3 AM, < Cold drinks, < Lying flat on back, < Smoke/fog, < Damp weather',
      amelioratingFactors:
          '> Sitting upright bending forward, > Warm sips of water, > Expectorating scanty mucus',
      concomitants:
          'Loud musical wheeze audible across room, rapid pulse, cold perspiration on forehead',
      causation:
          'Allergic hyper-responsiveness triggered by viral infection and cold air',
      periodicity: 'Attacks peak between midnight and 3 AM',
      initialSeverity: 8,
      thermal: 'Chilly patient, dreads winter and AC cold air',
      thirst: 'Frequent thirst for small quantities of warm water',
      appetite: 'Decreased during asthmatic paroxysm',
      sleep: 'Cannot sleep lying down, spends nights propped up with pillows',
      mentalGenerals:
          'Extreme restlessness, fear of suffocation and death during acute spasm',
      miasm: 'Tubercular (Psoro-Syphilitic)',
      pastHistory: 'Recurrent childhood bronchitis',
      familyHistory: 'Maternal grandfather had asthma and emphysema',
      primaryRemedy: 'Arsenicum Album',
      primaryPotency: '200C',
      followUpRemedy: 'Blatta Orientalis',
      followUpPotency: 'Q',
      doseCount: '4 pills',
      frequency: 'TDS (Three times daily)',
      vehicle: 'Sugar globules No. 30',
      instructions:
          '4 globules TDS. Keep Blatta Q 10 drops in warm water for SOS acute wheezing attacks.',
      dietaryAdvice:
          'Avoid refrigerated foods, bananas, ice creams, and cold drinks. Avoid smoke/perfumes.',
      medicineFee: 370.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Spirometry / Pulmonary Function Test (FEV1/FVC)',
      numericValue: 64.0,
      unit: '%',
      refMin: 75.0,
      refMax: 85.0,
      flag: 'Low',
      labName: 'Apollo Diagnostics Centre',
      testNotes:
          'Moderate reversible obstructive airway disease with significant post-bronchodilator response.',
    ),

    // 14. Irritable Bowel Syndrome (IBS)
    DiseaseArchetype(
      primaryDisease: 'Irritable Bowel Syndrome (IBS)',
      chiefComplaint:
          'Alternating constipation and diarrhea with lower abdominal cramping immediately after breakfast.',
      location: 'Colon and lower abdomen',
      side: 'Central',
      onset: 'Chronic over 2 years',
      duration: '2 years',
      sensation:
          'Cramping griping pain before stool, sensation of incomplete evacuation (never done feeling)',
      aggravatingFactors:
          '< Morning after breakfast, < Anticipatory anxiety/exams/meetings, < Dairy products',
      amelioratingFactors:
          '> Passing stool, > Passing flatus, > Warm tea, > Bending double',
      concomitants:
          'Excessive rumbling gas in abdomen, irritability, mild hemorrhoidal soreness',
      causation: 'Brain-gut axis dysregulation exacerbated by work stress',
      periodicity:
          'Urgent stool call within 15 minutes of first morning tea/meal',
      initialSeverity: 7,
      thermal: 'Chilly, intolerant to cold drinks',
      thirst: 'Desires warm beverages',
      appetite: 'Capricious, feels full after few mouthfuls',
      sleep: 'Sleep unrefreshing due to early morning bowel urgency',
      mentalGenerals:
          'Anxious, anticipatory nervousness before any public event or travel, hurried nature',
      miasm: 'Psoro-Sycotic',
      pastHistory: 'Acute gastroenteritis episode 2.5 years ago',
      familyHistory: 'Mother suffered from spastic colon and anxiety',
      primaryRemedy: 'Argentum Nitricum',
      primaryPotency: '200C',
      followUpRemedy: 'Nux Vomica',
      followUpPotency: '30C',
      doseCount: '4 pills',
      frequency: 'BD (Twice daily)',
      vehicle: 'Sugar globules No. 30',
      instructions: '4 pills before breakfast and bedtime.',
      dietaryAdvice:
          'Follow low-FODMAP diet. Avoid raw salads, whole milk, artificial sweeteners, and caffeine.',
      medicineFee: 300.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Stool Routine & Occult Blood Examination',
      stringValue:
          'No ova, cysts, parasites, or occult blood detected. Mucus present (+)',
      flag: 'Borderline',
      labName: 'Suraksha Diagnostic Lab',
      testNotes:
          'Negative for infection or IBD. Consistent with spastic colon / IBS.',
    ),

    // 15. Type 2 Diabetes Mellitus
    DiseaseArchetype(
      primaryDisease: 'Type 2 Diabetes Mellitus',
      chiefComplaint:
          'Uncontrolled blood sugars (FBS 178 mg/dL, HbA1c 8.4%) with polyuria at night and burning in soles.',
      location: 'Endocrine system / Peripheral nerves',
      side: 'Bilateral',
      onset: 'Diagnosed 4 years ago, poorly controlled recently',
      duration: '4 years',
      sensation:
          'Burning numbness and tingling (stocking-glove neuropathy) in bilateral feet at night',
      aggravatingFactors:
          '< Night in bed, < Carbohydrate heavy meals, < Sedentary weeks',
      amelioratingFactors:
          '> Uncovering feet in bed, > Gentle walking in morning',
      concomitants:
          'Frequent urination (3-4 times at night), slow wound healing, generalized fatigue',
      causation: 'Insulin resistance, obesity, genetic predisposition',
      periodicity: 'Persistent high readings',
      initialSeverity: 8,
      thermal: 'Hot patient, wants feet outside blanket',
      thirst: 'Polydipsia, drinks large volumes of water',
      appetite:
          'Polyphagia, ravenous hunger with craving for sweets and carbohydrates',
      sleep: 'Broken by nocturia',
      mentalGenerals:
          'Depressed about chronic illness, irritable, anxious about vision and kidneys',
      miasm: 'Sycotic / Syphilitic',
      pastHistory: 'Gestational diabetes 12 years ago',
      familyHistory: 'Both parents and elder brother are diabetic',
      primaryRemedy: 'Syzygium Jambolanum',
      primaryPotency: 'Q (Mother Tincture)',
      followUpRemedy: 'Cephalandra Indica',
      followUpPotency: 'Q',
      doseCount: '15 drops',
      frequency: 'TDS before meals',
      vehicle: 'Aqua Distillata',
      instructions:
          '15 drops in half cup water 15 minutes before breakfast, lunch, and dinner.',
      dietaryAdvice:
          'Strict diabetic diet. Zero refined sugar, white rice, or potatoes. Daily 45 mins brisk walk.',
      medicineFee: 440.0,
      testCategory: 'Blood / Biochemistry',
      testName: 'Glycated Hemoglobin (HbA1c) & Fasting Plasma Glucose',
      numericValue: 8.4,
      unit: '%',
      refMin: 4.0,
      refMax: 5.6,
      flag: 'High',
      labName: 'Dr. Lal PathLabs',
      testNotes:
          'Uncontrolled glycemic status. Target HbA1c < 7.0%. Fasting blood sugar 178 mg/dL.',
    ),
  ];
}
