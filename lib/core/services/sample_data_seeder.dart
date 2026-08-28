import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/id_generator.dart';
import '../../features/clinical/models/case_record_models.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/settings/providers/doctor_profile_provider.dart';

class SampleDataSeeder {
  static DateTime _slotTime(DateTime baseDay, int hour, int minute) {
    return DateTime(baseDay.year, baseDay.month, baseDay.day, hour, minute);
  }

  static Future<void> seedRealisticData(dynamic ref) async {
    final AppDatabase db = ref is WidgetRef
        ? ref.read(databaseProvider)
        : (ref is ProviderContainer
            ? ref.read(databaseProvider)
            : (ref as dynamic).read(databaseProvider) as AppDatabase);

    // 0. Clean all existing data completely
    await db.clearAllPracticeData();

    final now = DateTime.now();

    // 1. Doctor Profile & Onboarding Settings
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorNameKey,
            value: 'Dr. MD Zaid',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorFirstNameKey,
            value: 'MD',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorLastNameKey,
            value: 'Zaid',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorQualificationKey,
            value: 'BHMS, MD (Hom.)',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorRegNumberKey,
            value: 'WB-2018-98421',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorPhoneKey,
            value: '9830012345',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorEmailKey,
            value: 'dr.zaid@clinicpilot.com',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kOnboardingDoneKey,
            value: 'true',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal',
            value: '85000',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_new_patient_goal',
            value: '30',
            updatedAt: Value(now),
          ),
        );

    try {
      if (Hive.isBoxOpen('settings')) {
        final box = Hive.box('settings');
        box.put(kOnboardingDoneKey, true);
        box.put(kDoctorNameKey, 'Dr. MD Zaid');
        box.put(kDoctorFirstNameKey, 'MD');
        box.put(kDoctorLastNameKey, 'Zaid');
        box.put(kDoctorQualificationKey, 'BHMS, MD (Hom.)');
        box.put(kDoctorRegNumberKey, 'WB-2018-98421');
        box.put(kDoctorPhoneKey, '9830012345');
        box.put(kDoctorEmailKey, 'dr.zaid@clinicpilot.com');
      }
    } catch (_) {}

    // 2. 4 Practice Clinics (3 Physical + 1 Online)
    final clinic1Id = IdGenerator.generate();
    final clinic2Id = IdGenerator.generate();
    final clinic3Id = IdGenerator.generate();

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic1Id,
            name: 'City Care Homeo Clinic',
            address: const Value('14 Central Avenue, Market Complex'),
            phone: const Value('9830012345'),
            defaultConsultationFee: const Value(300.0),
            monthlyRent: const Value(5000.0),
            openDays: const Value('1,2,3,4,5,6'),
          ),
        );

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic2Id,
            name: 'Apex Health Center',
            address: const Value('82 Park Street, 2nd Floor'),
            phone: const Value('9830012346'),
            defaultConsultationFee: const Value(500.0),
            monthlyRent: const Value(8000.0),
            openDays: const Value('1,3,5'),
          ),
        );

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic3Id,
            name: 'Healing Touch Homoeo Care',
            address: const Value('5 Lake Road, Opposite Metro Gate 2'),
            phone: const Value('9830012347'),
            defaultConsultationFee: const Value(400.0),
            monthlyRent: const Value(6000.0),
            openDays: const Value('2,4,6'),
          ),
        );

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: 'clinic_online',
            name: 'Online / Teleconsultation',
            address: const Value('Digital / Remote Practice'),
            phone: const Value('9830012345'),
            defaultConsultationFee: const Value(350.0),
            monthlyRent: const Value(0.0),
            openDays: const Value('1,2,3,4,5,6,7'),
            colorHex: const Value('#7C3AED'),
          ),
        );

    // Save clinic targets
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinic1Id',
            value: '40000',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinic2Id',
            value: '25000',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinic3Id',
            value: '20000',
            updatedAt: Value(now),
          ),
        );

    // Save active clinic
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'active_clinic_id',
            value: clinic1Id,
            updatedAt: Value(now),
          ),
        );

    // 3. 25 Diverse Patients (18 In-Clinic + 7 Online)
    final patientsData = [
      // Physical Clinic 1 (City Care - 8 Patients)
      {
        'id': IdGenerator.generate(),
        'name': 'Tariq Mahmood',
        'phone': '9830112233',
        'email': 'tariq.mahmood@gmail.com',
        'age': 52,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Joint Pain / Osteoarthritis',
        'area': 'Central Avenue',
        'address': '14/2 Park Street',
        'occupation': 'Accountant',
        'code': 'P-2026-00001',
        'serial': '001',
        'marital': 'Married',
        'dob': '19740512',
        'remedy': 'Rhus Toxicodendron',
        'potency': '200C',
        'testName': 'Serum Uric Acid & Knee X-Ray',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Nusrat Jahan',
        'phone': '9830223344',
        'email': 'nusrat.jahan@yahoo.com',
        'age': 36,
        'gender': 'Female',
        'clinicId': clinic1Id,
        'disease': 'Migraine / Chronic Headache',
        'area': 'Salt Lake',
        'address': 'Sector 1, Block B',
        'occupation': 'School Teacher',
        'code': 'P-2026-00002',
        'serial': '002',
        'marital': 'Married',
        'dob': '19900824',
        'remedy': 'Natrum Muriaticum',
        'potency': '200C',
        'testName': 'Brain MRI & Vision Test',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Rashid Khan',
        'phone': '9830556677',
        'email': 'rashid.khan@gmail.com',
        'age': 60,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Hypertension & Arteriosclerosis',
        'area': 'Park Circus',
        'address': '7 Palm Avenue',
        'occupation': 'Retired Banker',
        'code': 'P-2026-00003',
        'serial': '003',
        'marital': 'Married',
        'dob': '19660210',
        'remedy': 'Rauwolfia Serpentina',
        'potency': 'Q (Mother Tincture)',
        'testName': 'Lipid Profile & ECG',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Zubair Ahmed',
        'phone': '9830990011',
        'email': 'zubair.ahmed@outlook.com',
        'age': 22,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Acne Vulgaris & Dandruff',
        'area': 'Bowbazar',
        'address': '31 BB Ganguly Street',
        'occupation': 'Software Engineer',
        'code': 'P-2026-00004',
        'serial': '004',
        'marital': 'Single',
        'dob': '20040719',
        'remedy': 'Berberis Aquifolium',
        'potency': 'Q',
        'testName': 'Liver Function Test (LFT)',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Arif Hossain',
        'phone': '9831556677',
        'email': 'arif.hossain@gmail.com',
        'age': 44,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Chronic Sinusitis & Nasal Polyps',
        'area': 'Chitpur',
        'address': '55 Rabindra Sarani',
        'occupation': 'Textile Merchant',
        'code': 'P-2026-00005',
        'serial': '005',
        'marital': 'Married',
        'dob': '19820311',
        'remedy': 'Teucrium Marum Verum',
        'potency': '200C',
        'testName': 'PNS X-Ray (Waters View)',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Wasim Akram',
        'phone': '9831990011',
        'email': 'wasim.akram@gmail.com',
        'age': 38,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Piles & Anal Fissure',
        'area': 'Tiretti Bazaar',
        'address': '18 Sun Yat Sen Street',
        'occupation': 'Wholesale Trader',
        'code': 'P-2026-00006',
        'serial': '006',
        'marital': 'Married',
        'dob': '19881105',
        'remedy': 'Aesculus Hippocastanum',
        'potency': '30C',
        'testName': 'Proctoscopy & CBC',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Shahid Iqbal',
        'phone': '9831112233',
        'email': '',
        'age': 48,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Sciatica & Lumbar Spondylosis',
        'area': 'Moulali',
        'address': '22 AJC Bose Road',
        'occupation': 'Store Manager',
        'code': 'P-2026-00007',
        'serial': '007',
        'marital': 'Married',
        'dob': '19780914',
        'remedy': 'Colocynthis',
        'potency': '200C',
        'testName': 'Lumbosacral Spine MRI',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Rehana Parveen',
        'phone': '9831223344',
        'email': 'rehana.parveen@gmail.com',
        'age': 34,
        'gender': 'Female',
        'clinicId': clinic1Id,
        'disease': 'Cervical Spondylosis & Vertigo',
        'area': 'Sealdah',
        'address': '9 Beliaghata Road',
        'occupation': 'Homemaker',
        'code': 'P-2026-00008',
        'serial': '008',
        'marital': 'Married',
        'dob': '19920130',
        'remedy': 'Conium Maculatum',
        'potency': '200C',
        'testName': 'Cervical Spine X-Ray',
        'type': 'clinic',
      },

      // Physical Clinic 2 (Apex Health - 6 Patients)
      {
        'id': IdGenerator.generate(),
        'name': 'Ayaan Ali',
        'phone': '9830334455',
        'email': 'parent.ayaan@gmail.com',
        'age': 8,
        'gender': 'Male',
        'clinicId': clinic2Id,
        'disease': 'Allergic Rhinitis / Dust Allergy',
        'area': 'Park Circus',
        'address': '12 Orient Row',
        'occupation': 'Student',
        'code': 'P-2026-00009',
        'serial': '001',
        'marital': 'Single',
        'dob': '20180315',
        'remedy': 'Arsenicum Album',
        'potency': '30C',
        'testName': 'Absolute Eosinophil Count (AEC)',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Farhana Begum',
        'phone': '9830445566',
        'email': 'farhana.b@gmail.com',
        'age': 29,
        'gender': 'Female',
        'clinicId': clinic2Id,
        'disease': 'Polycystic Ovarian Disease (PCOD)',
        'area': 'Ballygunge',
        'address': '45 Rowland Road',
        'occupation': 'HR Executive',
        'code': 'P-2026-00010',
        'serial': '002',
        'marital': 'Married',
        'dob': '19970903',
        'remedy': 'Pulsatilla Nigricans',
        'potency': '1M',
        'testName': 'Pelvic Ultrasound (USG)',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Yasmin Akhtar',
        'phone': '9830889900',
        'email': 'yasmin.akhtar@yahoo.com',
        'age': 41,
        'gender': 'Female',
        'clinicId': clinic2Id,
        'disease': 'Hypothyroidism & Weight Gain',
        'area': 'Gariahat',
        'address': '108 Rashbehari Avenue',
        'occupation': 'Professor',
        'code': 'P-2026-00011',
        'serial': '003',
        'marital': 'Married',
        'dob': '19850618',
        'remedy': 'Thyroidinum',
        'potency': '3X (Trituration)',
        'testName': 'Thyroid Profile (TSH, Free T3, T4)',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Tanveer Alam',
        'phone': '9831334455',
        'email': 'tanveer.alam@gmail.com',
        'age': 32,
        'gender': 'Male',
        'clinicId': clinic2Id,
        'disease': 'Renal Calculi (Kidney Stone)',
        'area': 'Alipore',
        'address': '17 Judges Court Road',
        'occupation': 'Architect',
        'code': 'P-2026-00012',
        'serial': '004',
        'marital': 'Married',
        'dob': '19940422',
        'remedy': 'Berberis Vulgaris',
        'potency': 'Q',
        'testName': 'USG KUB & Urine Routine',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Shabnam Bano',
        'phone': '9831445566',
        'email': 'shabnam.b@gmail.com',
        'age': 25,
        'gender': 'Female',
        'clinicId': clinic2Id,
        'disease': 'Hair Fall & Telogen Effluvium',
        'area': 'Bhawanipur',
        'address': '4 Harish Mukherjee Road',
        'occupation': 'Fashion Designer',
        'code': 'P-2026-00013',
        'serial': '005',
        'marital': 'Single',
        'dob': '20010814',
        'remedy': 'Wiesbaden',
        'potency': '200C',
        'testName': 'Serum Ferritin & Vitamin D3',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Sultana Begum',
        'phone': '9831889900',
        'email': '',
        'age': 55,
        'gender': 'Female',
        'clinicId': clinic2Id,
        'disease': 'Rheumatoid Arthritis & Morning Stiffness',
        'area': 'Tollygunge',
        'address': '26 Prince Anwar Shah Road',
        'occupation': 'Homemaker',
        'code': 'P-2026-00014',
        'serial': '006',
        'marital': 'Married',
        'dob': '19710329',
        'remedy': 'Causticum',
        'potency': '200C',
        'testName': 'RA Factor & Anti-CCP',
        'type': 'clinic',
      },

      // Physical Clinic 3 (Healing Touch - 4 Patients)
      {
        'id': IdGenerator.generate(),
        'name': 'Sana Fatima',
        'phone': '9830667788',
        'email': 'sana.fatima@gmail.com',
        'age': 19,
        'gender': 'Female',
        'clinicId': clinic3Id,
        'disease': 'Atopic Eczema / Dry Dermatitis',
        'area': 'Lake Gardens',
        'address': '182 Lake Gardens Block E',
        'occupation': 'College Student',
        'code': 'P-2026-00015',
        'serial': '001',
        'marital': 'Single',
        'dob': '20070417',
        'remedy': 'Graphites',
        'potency': '200C',
        'testName': 'Total Serum IgE Level',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Imran Shaikh',
        'phone': '9830778899',
        'email': 'imran.shaikh@gmail.com',
        'age': 45,
        'gender': 'Male',
        'clinicId': clinic3Id,
        'disease': 'GERD & Chronic Gastritis',
        'area': 'Jadavpur',
        'address': '84 Raja SC Mullick Road',
        'occupation': 'Civil Contractor',
        'code': 'P-2026-00016',
        'serial': '002',
        'marital': 'Married',
        'dob': '19811202',
        'remedy': 'Nux Vomica',
        'potency': '200C',
        'testName': 'Upper GI Endoscopy Report',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Meherun Nisa',
        'phone': '9831001122',
        'email': '',
        'age': 65,
        'gender': 'Female',
        'clinicId': clinic3Id,
        'disease': 'Bronchial Asthma & Wheezing',
        'area': 'Santoshpur',
        'address': '12 Avenue South',
        'occupation': 'Retired Headmistress',
        'code': 'P-2026-00017',
        'serial': '003',
        'marital': 'Widowed',
        'dob': '19610125',
        'remedy': 'Blatta Orientalis',
        'potency': 'Q',
        'testName': 'Spirometry (PFT) & Chest X-Ray',
        'type': 'clinic',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Nilofar Yasmin',
        'phone': '9831667788',
        'email': 'nilofar.y@gmail.com',
        'age': 28,
        'gender': 'Female',
        'clinicId': clinic3Id,
        'disease': 'Chronic Urticaria & Angioedema',
        'area': 'Kasba',
        'address': '51 Rajdanga Main Road',
        'occupation': 'Graphic Designer',
        'code': 'P-2026-00018',
        'serial': '004',
        'marital': 'Single',
        'dob': '19980516',
        'remedy': 'Apis Mellifica',
        'potency': '30C',
        'testName': 'Allergy Blood Panel',
        'type': 'clinic',
      },

      // Online / Teleconsultation (7 Patients across India & Global)
      {
        'id': IdGenerator.generate(),
        'name': 'Pooja Sharma',
        'phone': '9876543210',
        'email': 'pooja.sharma@patna.org',
        'age': 28,
        'gender': 'Female',
        'clinicId': 'clinic_online',
        'disease': 'Alopecia Areata & Hair Thinning',
        'area': 'Patna, Bihar',
        'address': 'Boring Road, Patna',
        'occupation': 'Bank PO',
        'code': 'P-2026-00019',
        'serial': 'ONL-00001',
        'marital': 'Married',
        'dob': '19980210',
        'remedy': 'Phosphorus',
        'potency': '200C',
        'testName': 'Serum Ferritin & Scalp Trichoscopy',
        'type': 'online',
        'medium': 'WhatsApp Video Call',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Rohini Deshmukh',
        'phone': '9822012345',
        'email': 'rohini.deshmukh@gmail.com',
        'age': 31,
        'gender': 'Female',
        'clinicId': 'clinic_online',
        'disease': 'PCOD & Hormonal Acne',
        'area': 'Pune, Maharashtra',
        'address': 'Kothrud, Pune',
        'occupation': 'IT Lead',
        'code': 'P-2026-00020',
        'serial': 'ONL-00002',
        'marital': 'Single',
        'dob': '19950714',
        'remedy': 'Sepia Officinalis',
        'potency': '200C',
        'testName': 'Hormone Panel (LH/FSH, DHEA-S)',
        'type': 'online',
        'medium': 'Google Meet / Zoom',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Tariq Al-Mansoor',
        'phone': '971501234567',
        'email': 'tariq.mansoor@emirates.ae',
        'age': 46,
        'gender': 'Male',
        'clinicId': 'clinic_online',
        'disease': 'Chronic Acid Reflux & Hiatus Hernia',
        'area': 'Dubai, UAE',
        'address': 'Downtown Dubai',
        'occupation': 'Business Executive',
        'code': 'P-2026-00021',
        'serial': 'ONL-00003',
        'marital': 'Married',
        'dob': '19800412',
        'remedy': 'Robinia Pseudacacia',
        'potency': '30C',
        'testName': 'Barium Swallow & 24h pH Study',
        'type': 'online',
        'medium': 'WhatsApp Video Call',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'David Miller',
        'phone': '', // Privacy / Google Meet Patient
        'email': 'david.miller@londonhealth.uk',
        'age': 39,
        'gender': 'Male',
        'clinicId': 'clinic_online',
        'disease': 'Generalised Anxiety & Chronic Insomnia',
        'area': 'London, United Kingdom',
        'address': 'Kensington, London',
        'occupation': 'Financial Analyst',
        'code': 'P-2026-00022',
        'serial': 'ONL-00004',
        'marital': 'Single',
        'dob': '19871020',
        'remedy': 'Passiflora Incarnata',
        'potency': 'Q',
        'testName': 'Sleep Study (Polysomnography)',
        'type': 'online',
        'medium': 'Google Meet / Zoom',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Ananya Sengupta',
        'phone': '9845012345',
        'email': 'ananya.s@bengaluru.in',
        'age': 33,
        'gender': 'Female',
        'clinicId': 'clinic_online',
        'disease': 'Dyshidrotic Eczema on Palms',
        'area': 'Bengaluru, Karnataka',
        'address': 'Indiranagar, Bengaluru',
        'occupation': 'Product Designer',
        'code': 'P-2026-00023',
        'serial': 'ONL-00005',
        'marital': 'Married',
        'dob': '19930805',
        'remedy': 'Mezereum',
        'potency': '200C',
        'testName': 'Skin Patch Allergy Test',
        'type': 'online',
        'medium': 'Google Meet / Zoom',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Dr. Sameer Verma',
        'phone': '9811012345',
        'email': 'sameer.verma@aiims.edu',
        'age': 50,
        'gender': 'Male',
        'clinicId': 'clinic_online',
        'disease': 'Cervical Radiculopathy & Arm Numbness',
        'area': 'New Delhi',
        'address': 'Hauz Khas, New Delhi',
        'occupation': 'Surgeon',
        'code': 'P-2026-00024',
        'serial': 'ONL-00006',
        'marital': 'Married',
        'dob': '19760630',
        'remedy': 'Hypericum Perforatum',
        'potency': '1M',
        'testName': 'EMG / Nerve Conduction Study',
        'type': 'online',
        'medium': 'Phone Call',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Fatima Al-Zahra',
        'phone': '9849012345',
        'email': 'fatima.zahra@hyderabad.in',
        'age': 27,
        'gender': 'Female',
        'clinicId': 'clinic_online',
        'disease': 'Recurrent Allergic Sinusitis',
        'area': 'Hyderabad, Telangana',
        'address': 'Banjara Hills, Hyderabad',
        'occupation': 'Architect',
        'code': 'P-2026-00025',
        'serial': 'ONL-00007',
        'marital': 'Single',
        'dob': '19991118',
        'remedy': 'Lemna Minor',
        'potency': '30C',
        'testName': 'Diagnostic Nasal Endoscopy',
        'type': 'online',
        'medium': 'WhatsApp Video Call',
      },
    ];

    // Insert Patients & Clinical Records
    for (int i = 0; i < patientsData.length; i++) {
      final p = patientsData[i];
      final pId = p['id'] as String;
      final cId = p['clinicId'] as String;
      final name = p['name'] as String;
      final phone = p['phone'] as String;
      final email = p['email'] as String?;
      final age = p['age'] as int;
      final gender = p['gender'] as String;
      final disease = p['disease'] as String;
      final area = p['area'] as String;
      final code = p['code'] as String;
      final serial = p['serial'] as String;
      final remedy = p['remedy'] as String;
      final potency = p['potency'] as String;
      final testName = p['testName'] as String;
      final isOnline = p['type'] == 'online';
      final medium = p['medium'] as String? ?? 'WhatsApp Video Call';

      final entryDate = now.subtract(Duration(days: 45 - i));

      await db.into(db.patients).insertOnConflictUpdate(
            PatientsCompanion.insert(
              id: pId,
              patientCode: Value(code),
              serialNo: Value(serial),
              name: name,
              phone: phone,
              email: Value(email != null && email.isNotEmpty ? email : null),
              age: age,
              gender: gender,
              area: Value(area),
              primaryClinicId: Value(cId),
              notes: Value(isOnline ? 'Consultation Medium: $medium' : null),
              createdAt: Value(entryDate),
              updatedAt: Value(entryDate),
            ),
          );

      // Create Full Case Taking Record using MasterCaseRecordData
      final masterCase = MasterCaseRecordData(
        patientId: pId,
        recordDate: entryDate,
        chiefComplaints: [
          ChiefComplaintDetail(
            complaint: disease,
            location: area,
            sensation: 'Characteristic discomfort aggravated by climatic stress',
            modalitiesAgg: 'Aggravated in morning and damp cold',
            modalitiesAmel: 'Relieved by warmth and rest',
            concomitants: 'Restlessness, fatigue, and mild anxiety',
            duration: '8 months',
            severity: 'Moderate',
          ),
        ],
        hpi: const HpiDetails(
          progression: 'Progressively worse with seasonal transitions',
          previousTreatment: 'Allopathic OTC painkillers gave only temporary palliation',
        ),
        pastHistory: const PastHistoryDetails(
          childhoodIllnesses: 'Recurrent measles and frequent colds',
          allergies: 'Hypersensitive to dust and strong deodorants',
        ),
        familyHistory: const FamilyHistoryDetails(
          father: 'Hypertension',
          mother: 'Joint complaints & Type 2 Diabetes',
        ),
        physicalGenerals: const PhysicalGenerals(
          appetite: 'Normal, desires warm cooked foods',
          thirst: 'Moderate, 2.5 litres per day',
          thermal: 'Chilly',
          sleep: 'Disturbed past 2 AM, refreshing on waking',
          dreams: 'Occupational stress dreams',
        ),
        mentalGenerals: const MentalGenerals(
          generalMentalState: 'Meticulous, conscientious, anxious about health recovery',
          fears: 'Fear of high places and chronic debility',
        ),
        lifestyleHabits: const LifestyleHistoryDetails(
          diet: 'Mixed non-vegetarian, regular meal timings',
          physicalActivity: 'Sedentary work desk with 30 min evening walk',
        ),
        clinicalExam: const ClinicalExamVitals(
          pulse: '74 bpm',
          bloodPressure: '124/82 mmHg',
          temperature: '98.4 F',
          respiratoryRate: '16/min',
          spo2: '99%',
          weightKg: '68 kg',
          heightCm: '168 cm',
          bmi: '24.1',
        ),
        miasmaticAnalysis: const MiasmaticAnalysis(
          dominantMiasm: 'Psora',
          secondaryMixedMiasm: 'Sycotic',
          psoricFeatures: 'Hypersensitivity to cold, skin dryness, seasonal aggravation',
          sycoticFeatures: 'Sluggish recovery, localized stiffness',
        ),
        caseTotality: CaseTotality(
          totalityOfSymptoms: 'Totality of characteristic mental and physical general symptoms',
          characteristicSymptoms: 'Thermal modality chilly, worse cold and damp, better warmth',
          generals: 'Chilly thermal, moderate thirst, fatigue on exertion',
          finalRemedySelection: '$remedy $potency selected based on constitutional totality',
        ),
        clinicalAssessment: ClinicalAssessmentDetails(
          provisionalDiagnosis: disease,
          finalWorkingDiagnosis: disease,
          differentialDiagnosis: 'Clinical examination & constitutional match confirmed',
          clinicalRemarks: 'Constitutional homoeopathic treatment initiated with lifestyle guidance',
        ),
        baselinePrescription: PrescriptionPlanDetails(
          remedyName: remedy,
          potency: potency,
          dose: '4 pills',
          repetitionFrequency: 'Twice daily before meals',
          route: 'Oral',
          pharmaceuticalForm: 'Globules / Sugar Pellets',
          quantityDispensed: '1 dram vial',
          dietRegimenAdvice: 'Avoid raw onions, strong coffee, and excessive spices during remedy action',
          lifestyleAdvice: 'Daily 30 min morning walk and 8 hours restful sleep',
        ),
        investigations: InvestigationsPlanDetails(
          investigationName: testName,
          reportSummary: 'Within clinically acceptable limits. Diagnostic report reviewed and noted in chart.',
        ),
        followUpDetails: const FollowUpDetails(
          overallResponse: 'Treatment ongoing',
        ),
        outcome: 'Active Under Treatment',
      );

      await db.into(db.patientCaseRecords).insertOnConflictUpdate(
            PatientCaseRecordsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: pId,
              recordDate: Value(entryDate),
              chiefComplaintsJson: Value(masterCase.chiefComplaintsJson),
              hpi: Value(masterCase.hpiJson),
              pastHistoryJson: Value(masterCase.pastHistoryJson),
              familyHistoryJson: Value(masterCase.familyHistoryJson),
              developmentalHistoryJson: Value(masterCase.developmentalHistoryJson),
              physicalGeneralsJson: Value(masterCase.physicalGeneralsJson),
              mentalGeneralsJson: Value(masterCase.mentalGeneralsJson),
              lifestyleJson: Value(masterCase.lifestyleJson),
              clinicalExamJson: Value(masterCase.clinicalExamJson),
              miasmaticAnalysisJson: Value(masterCase.miasmaticAnalysisJson),
              caseTotalityJson: Value(masterCase.caseTotalityJson),
              baselinePrescriptionJson: Value(masterCase.baselinePrescriptionJson),
              investigationsJson: Value(masterCase.investigationsJson),
              followUpNotes: const Value('Initial comprehensive homeopathic case taking completed.'),
              outcome: const Value('Active Under Treatment'),
              createdAt: Value(entryDate),
            ),
          );

      // Structured complaint
      await db.into(db.complaints).insertOnConflictUpdate(
            ComplaintsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: pId,
              complaintName: disease,
              location: Value(area),
              severity: const Value(6),
              status: const Value('Active'),
              createdAt: Value(entryDate),
            ),
          );

      // Structured prescription
      await db.into(db.prescriptions).insertOnConflictUpdate(
            PrescriptionsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: pId,
              prescriptionDate: Value(entryDate),
              remedyName: remedy,
              potency: potency,
              doseCount: const Value('4 globules'),
              frequency: const Value('BD (Twice daily)'),
              instructions: const Value('Take on empty stomach 15 mins before meals'),
              dietaryAdvice: const Value('Avoid raw onion, garlic, and strong camphor'),
              createdAt: Value(entryDate),
            ),
          );

      // Structured investigation
      await db.into(db.investigations).insertOnConflictUpdate(
            InvestigationsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: pId,
              testDate: Value(entryDate),
              testName: testName,
              flag: const Value('Normal'),
              notes: const Value('Baseline clinical report verified by Dr. MD Zaid'),
              createdAt: Value(entryDate),
            ),
          );
    }

    // 4. 55 Realistic Visits with Time Distribution
    // Hours distribution: 09:30, 10:15, 11:00, 11:45, 12:30 (Morning) | 14:15, 15:30 (Afternoon Online) | 17:30, 18:15, 19:00, 19:45, 20:30 (Evening Rush)
    final visitConfigs = [
      // 25 Initial Consultations
      {'pIdx': 0, 'daysAgo': 40, 'h': 10, 'm': 15, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 10},
      {'pIdx': 1, 'daysAgo': 38, 'h': 18, 'm': 30, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 8},
      {'pIdx': 2, 'daysAgo': 36, 'h': 11, 'm': 0, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 6},
      {'pIdx': 3, 'daysAgo': 35, 'h': 19, 'm': 15, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 5},
      {'pIdx': 4, 'daysAgo': 34, 'h': 17, 'm': 45, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 4},
      {'pIdx': 5, 'daysAgo': 32, 'h': 10, 'm': 45, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 2},
      {'pIdx': 6, 'daysAgo': 30, 'h': 18, 'm': 0, 'type': 'new', 'ctype': 'clinic', 'out': 'no_change', 'fuDays': 1},
      {'pIdx': 7, 'daysAgo': 28, 'h': 12, 'm': 15, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 0},
      {'pIdx': 8, 'daysAgo': 27, 'h': 17, 'm': 30, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': -2},
      {'pIdx': 9, 'daysAgo': 25, 'h': 18, 'm': 45, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': -3},
      {'pIdx': 10, 'daysAgo': 24, 'h': 19, 'm': 30, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': -4},
      {'pIdx': 11, 'daysAgo': 22, 'h': 10, 'm': 30, 'type': 'new', 'ctype': 'clinic', 'out': 'recovered', 'fuDays': -5},
      {'pIdx': 12, 'daysAgo': 20, 'h': 18, 'm': 15, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': -7},
      {'pIdx': 13, 'daysAgo': 19, 'h': 11, 'm': 45, 'type': 'new', 'ctype': 'clinic', 'out': 'no_change', 'fuDays': -8},
      {'pIdx': 14, 'daysAgo': 18, 'h': 17, 'm': 15, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': -10},
      {'pIdx': 15, 'daysAgo': 16, 'h': 19, 'm': 0, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': -12},
      {'pIdx': 16, 'daysAgo': 15, 'h': 10, 'm': 0, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': -14},
      {'pIdx': 17, 'daysAgo': 14, 'h': 18, 'm': 30, 'type': 'new', 'ctype': 'clinic', 'out': 'improved', 'fuDays': -15},
      // 7 Online Initial Consultations
      {'pIdx': 18, 'daysAgo': 26, 'h': 14, 'm': 30, 'type': 'new', 'ctype': 'online', 'out': 'improved', 'fuDays': 3},
      {'pIdx': 19, 'daysAgo': 21, 'h': 15, 'm': 15, 'type': 'new', 'ctype': 'online', 'out': 'improved', 'fuDays': 5},
      {'pIdx': 20, 'daysAgo': 17, 'h': 16, 'm': 0, 'type': 'new', 'ctype': 'online', 'out': 'improved', 'fuDays': 7},
      {'pIdx': 21, 'daysAgo': 13, 'h': 14, 'm': 0, 'type': 'new', 'ctype': 'online', 'out': 'improved', 'fuDays': 10},
      {'pIdx': 22, 'daysAgo': 9, 'h': 15, 'm': 45, 'type': 'new', 'ctype': 'online', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 23, 'daysAgo': 6, 'h': 16, 'm': 30, 'type': 'new', 'ctype': 'online', 'out': 'improved', 'fuDays': 18},
      {'pIdx': 24, 'daysAgo': 2, 'h': 14, 'm': 45, 'type': 'new', 'ctype': 'online', 'out': 'improved', 'fuDays': 21},

      // 30 Follow-Up Consultations (Spanning Recent Weeks & Today)
      {'pIdx': 0, 'daysAgo': 28, 'h': 10, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 0, 'daysAgo': 14, 'h': 10, 'm': 45, 'type': 'followup', 'ctype': 'clinic', 'out': 'recovered', 'fuDays': 28},
      {'pIdx': 1, 'daysAgo': 24, 'h': 18, 'm': 15, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 10},
      {'pIdx': 1, 'daysAgo': 10, 'h': 18, 'm': 45, 'type': 'followup', 'ctype': 'clinic', 'out': 'recovered', 'fuDays': 30},
      {'pIdx': 2, 'daysAgo': 22, 'h': 11, 'm': 15, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 12},
      {'pIdx': 2, 'daysAgo': 7, 'h': 11, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 3, 'daysAgo': 20, 'h': 19, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 10},
      {'pIdx': 3, 'daysAgo': 5, 'h': 19, 'm': 45, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 12},
      {'pIdx': 4, 'daysAgo': 19, 'h': 18, 'm': 0, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 4, 'daysAgo': 4, 'h': 17, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 5, 'daysAgo': 18, 'h': 10, 'm': 15, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 10},
      {'pIdx': 5, 'daysAgo': 3, 'h': 10, 'm': 45, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 12},
      {'pIdx': 6, 'daysAgo': 16, 'h': 18, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 8},
      {'pIdx': 7, 'daysAgo': 14, 'h': 12, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 8, 'daysAgo': 13, 'h': 17, 'm': 45, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 10},
      {'pIdx': 9, 'daysAgo': 12, 'h': 19, 'm': 0, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 12},
      {'pIdx': 10, 'daysAgo': 11, 'h': 19, 'm': 15, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 12, 'daysAgo': 9, 'h': 18, 'm': 0, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 13, 'daysAgo': 8, 'h': 12, 'm': 0, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 10},
      {'pIdx': 14, 'daysAgo': 7, 'h': 17, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 15, 'daysAgo': 6, 'h': 19, 'm': 15, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 16, 'daysAgo': 5, 'h': 10, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'recovered', 'fuDays': 30},
      {'pIdx': 17, 'daysAgo': 4, 'h': 18, 'm': 45, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      // Online Follow-ups
      {'pIdx': 18, 'daysAgo': 12, 'h': 14, 'm': 30, 'type': 'followup', 'ctype': 'online', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 19, 'daysAgo': 8, 'h': 15, 'm': 15, 'type': 'followup', 'ctype': 'online', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 20, 'daysAgo': 6, 'h': 16, 'm': 0, 'type': 'followup', 'ctype': 'online', 'out': 'improved', 'fuDays': 14},
      // Today Consultations (3 visits today for rich live experience!)
      {'pIdx': 0, 'daysAgo': 0, 'h': 10, 'm': 30, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 9, 'daysAgo': 0, 'h': 18, 'm': 15, 'type': 'followup', 'ctype': 'clinic', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 18, 'daysAgo': 0, 'h': 14, 'm': 30, 'type': 'followup', 'ctype': 'online', 'out': 'improved', 'fuDays': 14},
      {'pIdx': 21, 'daysAgo': 0, 'h': 15, 'm': 30, 'type': 'followup', 'ctype': 'online', 'out': 'improved', 'fuDays': 14},
    ];

    final createdVisitIds = <int, String>{};

    for (int v = 0; v < visitConfigs.length; v++) {
      final cfg = visitConfigs[v];
      final pIdx = cfg['pIdx'] as int;
      final daysAgo = cfg['daysAgo'] as int;
      final hour = cfg['h'] as int;
      final min = cfg['m'] as int;
      final type = cfg['type'] as String;
      final ctype = cfg['ctype'] as String;
      final outcome = cfg['out'] as String;
      final fuDays = cfg['fuDays'] as int;

      final p = patientsData[pIdx];
      final vDate = _slotTime(now.subtract(Duration(days: daysAgo)), hour, min);
      final fuDate = now.add(Duration(days: fuDays));
      final vId = IdGenerator.generate();
      createdVisitIds[v] = vId;

      await db.into(db.visits).insertOnConflictUpdate(
            VisitsCompanion.insert(
              id: vId,
              patientId: p['id'] as String,
              clinicId: p['clinicId'] as String,
              visitType: type,
              disease: p['disease'] as String,
              chiefComplaint: Value(type == 'new' ? (p['disease'] as String) : 'Follow-up review for ${p['disease']}'),
              visitDate: vDate,
              consultationType: Value(ctype),
              outcome: Value(outcome),
              nextFollowUpDate: Value(fuDate),
            ),
          );
    }

    // 5. 55 Cash Memos corresponding to visits
    final paymentMethods = ['UPI', 'Cash', 'Card', 'Bank Transfer'];

    for (int m = 0; m < visitConfigs.length; m++) {
      final cfg = visitConfigs[m];
      final pIdx = cfg['pIdx'] as int;
      final daysAgo = cfg['daysAgo'] as int;
      final hour = cfg['h'] as int;
      final min = cfg['m'] as int;
      final ctype = cfg['ctype'] as String;
      final p = patientsData[pIdx];
      final cId = p['clinicId'] as String;

      final fee = ctype == 'online' ? 350.0 : (cId == clinic2Id ? 500.0 : (cId == clinic3Id ? 400.0 : 300.0));
      final med = (m % 3 == 0) ? 250.0 : ((m % 2 == 0) ? 200.0 : 150.0);
      final disc = (m % 5 == 0) ? 50.0 : 0.0;
      final total = (fee + med) - disc;
      final method = ctype == 'online' ? 'UPI' : paymentMethods[m % paymentMethods.length];
      final memoTime = _slotTime(now.subtract(Duration(days: daysAgo)), hour, min + 15);
      final memoNum = 'CM-2026-${(m + 1).toString().padLeft(5, '0')}';

      await db.into(db.cashMemos).insertOnConflictUpdate(
            CashMemosCompanion.insert(
              id: IdGenerator.generate(),
              memoNumber: memoNum,
              patientId: p['id'] as String,
              clinicId: Value(cId),
              visitId: Value(createdVisitIds[m]),
              consultationFee: Value(fee),
              medicineFee: Value(med),
              discount: Value(disc),
              total: total,
              paidAmount: Value(total),
              paymentMethod: method,
              createdAt: Value(memoTime),
            ),
          );
    }

    // 6. 35 Footfall Inquiries (Converted + Walk-ins)
    final footfallInquiries = [
      {'name': 'Tanvi Sethi', 'phone': '9830119901', 'cId': clinic1Id, 'disease': 'Cervical Pain', 'daysAgo': 28, 'h': 11, 'm': 30, 'conv': true, 'pIdx': 7},
      {'name': 'Vikash Poddar', 'phone': '9830119902', 'cId': clinic1Id, 'disease': 'Allergic Asthma', 'daysAgo': 26, 'h': 18, 'm': 0, 'conv': true, 'pIdx': 4},
      {'name': 'Dr. K. L. Mehra', 'phone': '9830119903', 'cId': clinic2Id, 'disease': 'Renal Stone Inquiry', 'daysAgo': 25, 'h': 10, 'm': 15, 'conv': true, 'pIdx': 11},
      {'name': 'Aparna Ghosh', 'phone': '9830119904', 'cId': clinic2Id, 'disease': 'Thyroid Management', 'daysAgo': 24, 'h': 19, 'm': 0, 'conv': true, 'pIdx': 10},
      {'name': 'Manoj Bajpayee', 'phone': '9830119905', 'cId': clinic3Id, 'disease': 'Skin Eczema Consultation', 'daysAgo': 22, 'h': 17, 'm': 30, 'conv': true, 'pIdx': 14},
      {'name': 'Ritu Chawla', 'phone': '9830119906', 'cId': clinic3Id, 'disease': 'Gastric Acidity', 'daysAgo': 20, 'h': 11, 'm': 0, 'conv': true, 'pIdx': 15},
      // Non-converted Walk-in inquiries
      {'name': 'Rakesh Sharma', 'phone': '9830119911', 'cId': clinic1Id, 'disease': 'Piles Laser vs Homeopathy', 'daysAgo': 19, 'h': 10, 'm': 45, 'conv': false},
      {'name': 'Deepa Karmakar', 'phone': '9830119912', 'cId': clinic1Id, 'disease': 'Knee Arthritis in Elder Mother', 'daysAgo': 18, 'h': 18, 'm': 15, 'conv': false},
      {'name': 'Sourav Ganguly', 'phone': '9830119913', 'cId': clinic1Id, 'disease': 'Tennis Elbow & Sports Injury', 'daysAgo': 16, 'h': 19, 'm': 30, 'conv': false},
      {'name': 'Shampa Das', 'phone': '9830119914', 'cId': clinic2Id, 'disease': 'Child Immunity & Frequent Cold', 'daysAgo': 15, 'h': 11, 'm': 15, 'conv': false},
      {'name': 'Gautam Gambhir', 'phone': '9830119915', 'cId': clinic2Id, 'disease': 'Chronic Sinusitis & Snoring', 'daysAgo': 14, 'h': 17, 'm': 45, 'conv': false},
      {'name': 'Sunita Rao', 'phone': '9830119916', 'cId': clinic2Id, 'disease': 'Hair Fall after Pregnancy', 'daysAgo': 13, 'h': 18, 'm': 30, 'conv': false},
      {'name': 'Harishankar Roy', 'phone': '9830119917', 'cId': clinic3Id, 'disease': 'Prostate Enlargement / BPH', 'daysAgo': 12, 'h': 10, 'm': 30, 'conv': false},
      {'name': 'Madhumita Sen', 'phone': '9830119918', 'cId': clinic3Id, 'disease': 'Migraine with Aura', 'daysAgo': 11, 'h': 11, 'm': 45, 'conv': false},
      {'name': 'Kamal Hasan', 'phone': '9830119919', 'cId': clinic3Id, 'disease': 'Fatty Liver Grade 2', 'daysAgo': 10, 'h': 19, 'm': 0, 'conv': false},
      {'name': 'Anupam Kher', 'phone': '9830119920', 'cId': clinic1Id, 'disease': 'Vertigo & Cervical Discomfort', 'daysAgo': 8, 'h': 10, 'm': 0, 'conv': false},
      {'name': 'Sneha Chatterjee', 'phone': '9830119921', 'cId': clinic1Id, 'disease': 'Psoriasis on Scalp', 'daysAgo': 7, 'h': 18, 'm': 0, 'conv': false},
      {'name': 'Debabrata Mukherjee', 'phone': '9830119922', 'cId': clinic2Id, 'disease': 'Sciatic Nerve Pain', 'daysAgo': 6, 'h': 17, 'm': 15, 'conv': false},
      {'name': 'Priyanka Nandi', 'phone': '9830119923', 'cId': clinic2Id, 'disease': 'Menstrual Irregularities', 'daysAgo': 5, 'h': 19, 'm': 15, 'conv': false},
      {'name': 'Subrata Paul', 'phone': '9830119924', 'cId': clinic3Id, 'disease': 'Allergic Bronchitis', 'daysAgo': 4, 'h': 10, 'm': 45, 'conv': false},
      {'name': 'Tania Dutta', 'phone': '9830119925', 'cId': clinic3Id, 'disease': 'Acne Scars & Rosacea', 'daysAgo': 3, 'h': 18, 'm': 30, 'conv': false},
      {'name': 'Moumita Roy', 'phone': '9830119926', 'cId': clinic1Id, 'disease': 'Uric Acid Joint Swelling', 'daysAgo': 2, 'h': 11, 'm': 30, 'conv': false},
      {'name': 'Bikram Ghosh', 'phone': '9830119927', 'cId': clinic2Id, 'disease': 'Anxiety & Sleeplessness', 'daysAgo': 1, 'h': 18, 'm': 45, 'conv': false},
      {'name': 'Indira Banerjee', 'phone': '9830119928', 'cId': clinic3Id, 'disease': 'Child Bedwetting Inquiry', 'daysAgo': 0, 'h': 11, 'm': 0, 'conv': false},
    ];

    for (final f in footfallInquiries) {
      final daysAgo = f['daysAgo'] as int;
      final hour = f['h'] as int;
      final min = f['m'] as int;
      final isConv = f['conv'] as bool;
      final pIdx = f['pIdx'] as int?;
      final fTime = _slotTime(now.subtract(Duration(days: daysAgo)), hour, min);

      await db.into(db.footfalls).insertOnConflictUpdate(
            FootfallsCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: f['cId'] as String,
              name: f['name'] as String,
              phone: Value(f['phone'] as String?),
              disease: Value(f['disease'] as String?),
              convertedPatientId: Value(isConv && pIdx != null ? (patientsData[pIdx]['id'] as String) : null),
              notes: Value(isConv ? 'Walked in and registered as patient' : 'Walk-in inquiry for consultation details'),
              date: Value(fTime),
              createdAt: Value(fTime),
            ),
          );
    }

    // 7. 32 Expenses across all 11 Categories with Realistic Dates & Time Slots
    final expensesList = [
      // Medicine stock
      {'cId': clinic1Id, 'cat': 'Medicine', 'sub': 'Schwabe Mother Tinctures Batch', 'amt': 4800.0, 'method': 'UPI', 'rec': false, 'notes': 'Bulk order Q tinctures (Crataegus, Berberis, Rauwolfia)', 'daysAgo': 38, 'h': 14},
      {'cId': clinic2Id, 'cat': 'Medicine', 'sub': 'SBL Biochemic Tissue Salts', 'amt': 3500.0, 'method': 'UPI', 'rec': false, 'notes': 'Complete 12 Tissue Salts 6X & 12X assortment', 'daysAgo': 32, 'h': 15},
      {'cId': clinic3Id, 'cat': 'Medicine', 'sub': 'Sugar Globules & Droppers', 'amt': 2200.0, 'method': 'Cash', 'rec': false, 'notes': 'Pharmaceutical grade sugar globules #30 & #40, glass vials', 'daysAgo': 25, 'h': 12},
      {'cId': clinic1Id, 'cat': 'Medicine', 'sub': 'Dr. Reckeweg German Dilutions', 'amt': 5600.0, 'method': 'UPI', 'rec': false, 'notes': 'German specialty R-series drops and 200C potencies', 'daysAgo': 12, 'h': 14},

      // Packaging
      {'cId': clinic1Id, 'cat': 'Packaging', 'sub': 'Envelopes & Dosage Labels', 'amt': 1200.0, 'method': 'Cash', 'rec': false, 'notes': 'Custom printed clinic paper envelopes with timing checkboxes', 'daysAgo': 30, 'h': 16},
      {'cId': clinic2Id, 'cat': 'Packaging', 'sub': 'Courier Corrugated Boxes', 'amt': 1600.0, 'method': 'UPI', 'rec': false, 'notes': 'Padded bubble mailers and boxes for remote patient remedies', 'daysAgo': 20, 'h': 13},
      {'cId': clinic3Id, 'cat': 'Packaging', 'sub': 'Ziplock Prescription Pouches', 'amt': 850.0, 'method': 'Cash', 'rec': false, 'notes': 'Moisture-proof pouches for medicine storage', 'daysAgo': 10, 'h': 11},

      // Staff Salaries
      {'cId': clinic1Id, 'cat': 'Staff Salary', 'sub': 'Receptionist Monthly Salary', 'amt': 6000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'City Care front desk clinic assistant', 'daysAgo': 29, 'h': 10},
      {'cId': clinic2Id, 'cat': 'Staff Salary', 'sub': 'Dispensary Compounder', 'amt': 7000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'Apex Health compounding assistant', 'daysAgo': 29, 'h': 10},
      {'cId': clinic3Id, 'cat': 'Staff Salary', 'sub': 'Clinic Attendant Wages', 'amt': 4500.0, 'method': 'Cash', 'rec': true, 'notes': 'Healing Touch clinic assistant', 'daysAgo': 29, 'h': 10},

      // Clinic Rent
      {'cId': clinic1Id, 'cat': 'Rent', 'sub': 'Monthly Commercial Rent', 'amt': 5000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'City Care Market Complex suite rent', 'daysAgo': 30, 'h': 9},
      {'cId': clinic2Id, 'cat': 'Rent', 'sub': 'Monthly Commercial Rent', 'amt': 8000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'Apex Health 2nd floor medical center rent', 'daysAgo': 30, 'h': 9},
      {'cId': clinic3Id, 'cat': 'Rent', 'sub': 'Monthly Commercial Rent', 'amt': 6000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'Healing Touch Lake Road space rent', 'daysAgo': 30, 'h': 9},

      // Camp Expenditures
      {'cId': clinic1Id, 'cat': 'Camp', 'sub': 'Free Arthritis & Joint Camp', 'amt': 2800.0, 'method': 'UPI', 'rec': false, 'notes': 'Community park health camp banner, canopy, sound & logistics', 'daysAgo': 21, 'h': 8},
      {'cId': clinic3Id, 'cat': 'Camp', 'sub': 'School Immunity Camp', 'amt': 1900.0, 'method': 'Cash', 'rec': false, 'notes': 'School Children allergy testing kits and health booklets', 'daysAgo': 14, 'h': 8},
      {'cId': clinic2Id, 'cat': 'Camp', 'sub': 'Geriatric Health Camp', 'amt': 2400.0, 'method': 'UPI', 'rec': false, 'notes': 'Senior citizen bone health awareness leaflets & BP check kits', 'daysAgo': 7, 'h': 9},

      // Marketing
      {'cId': clinic1Id, 'cat': 'Marketing', 'sub': 'Local Health Awareness Pamphlets', 'amt': 1500.0, 'method': 'UPI', 'rec': false, 'notes': 'Distribution in Central Avenue & Park Street market', 'daysAgo': 27, 'h': 16},
      {'cId': clinic2Id, 'cat': 'Marketing', 'sub': 'Google Business Profile Promotion', 'amt': 2000.0, 'method': 'Card', 'rec': false, 'notes': 'Local SEO practice visibility campaign', 'daysAgo': 18, 'h': 15},
      {'cId': clinic3Id, 'cat': 'Marketing', 'sub': 'Newspaper Health Column Insertion', 'amt': 1800.0, 'method': 'UPI', 'rec': false, 'notes': 'Homeopathic allergy care feature article print fee', 'daysAgo': 11, 'h': 14},

      // Equipment
      {'cId': clinic1Id, 'cat': 'Equipment', 'sub': 'Digital BP Monitor & Oximeter', 'amt': 3200.0, 'method': 'Card', 'rec': false, 'notes': 'Omron automatic blood pressure monitor & fingertip SpO2', 'daysAgo': 35, 'h': 11},
      {'cId': clinic2Id, 'cat': 'Equipment', 'sub': 'Diagnostic ENT Pen Torch & Stethoscope', 'amt': 1800.0, 'method': 'UPI', 'rec': false, 'notes': 'Stainless steel diagnostic examination instruments', 'daysAgo': 26, 'h': 12},
      {'cId': clinic3Id, 'cat': 'Equipment', 'sub': 'Digital Weighing Scale & Height Meter', 'amt': 1400.0, 'method': 'Card', 'rec': false, 'notes': 'Precision electronic medical scale for pediatric/geriatric', 'daysAgo': 17, 'h': 13},

      // Utilities
      {'cId': clinic1Id, 'cat': 'Utilities', 'sub': 'CESC Electricity Bill', 'amt': 2400.0, 'method': 'UPI', 'rec': true, 'notes': 'Monthly electricity bill for clinic space', 'daysAgo': 28, 'h': 10},
      {'cId': clinic2Id, 'cat': 'Utilities', 'sub': 'CESC Electricity Bill', 'amt': 3100.0, 'method': 'UPI', 'rec': true, 'notes': 'Air conditioned consultation room power charges', 'daysAgo': 28, 'h': 10},
      {'cId': clinic3Id, 'cat': 'Utilities', 'sub': 'CESC Electricity & Water', 'amt': 2100.0, 'method': 'UPI', 'rec': true, 'notes': 'Monthly utility bill', 'daysAgo': 28, 'h': 10},

      // Maintenance
      {'cId': clinic1Id, 'cat': 'Maintenance', 'sub': 'Deep Sanitization & Pest Control', 'amt': 1200.0, 'method': 'Cash', 'rec': false, 'notes': 'Quarterly clinic hygiene and sanitization treatment', 'daysAgo': 22, 'h': 17},
      {'cId': clinic2Id, 'cat': 'Maintenance', 'sub': 'Air Conditioner Servicing', 'amt': 1500.0, 'method': 'UPI', 'rec': false, 'notes': 'Dual split AC gas top-up & coil wash', 'daysAgo': 15, 'h': 14},
      {'cId': clinic3Id, 'cat': 'Maintenance', 'sub': 'Plumbing & Water Filter Servicing', 'amt': 900.0, 'method': 'Cash', 'rec': false, 'notes': 'Water purifier candle replacement and wash basin repair', 'daysAgo': 9, 'h': 16},

      // Miscellaneous
      {'cId': clinic1Id, 'cat': 'Miscellaneous', 'sub': 'High Speed Fiber Broadband', 'amt': 1100.0, 'method': 'UPI', 'rec': true, 'notes': 'Monthly internet broadband for clinic software & records', 'daysAgo': 25, 'h': 11},
      {'cId': clinic2Id, 'cat': 'Miscellaneous', 'sub': 'Doctor & Patient Refreshments', 'amt': 850.0, 'method': 'Cash', 'rec': false, 'notes': 'Green tea, coffee, and packaged water bottles', 'daysAgo': 16, 'h': 12},
      {'cId': clinic3Id, 'cat': 'Miscellaneous', 'sub': 'Clinical Stationary & Thermal Rolls', 'amt': 650.0, 'method': 'UPI', 'rec': false, 'notes': 'Thermal receipt paper rolls and prescription pads', 'daysAgo': 6, 'h': 15},
      {'cId': clinic1Id, 'cat': 'Miscellaneous', 'sub': 'Courier Charges for Remote Medicines', 'amt': 750.0, 'method': 'UPI', 'rec': false, 'notes': 'Speed Post delivery for Patna & Pune teleconsultation remedies', 'daysAgo': 3, 'h': 16},
    ];

    for (final exp in expensesList) {
      final daysAgo = exp['daysAgo'] as int;
      final hour = exp['h'] as int;
      final expTime = _slotTime(now.subtract(Duration(days: daysAgo)), hour, 30);

      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: exp['cId'] as String,
              category: exp['cat'] as String,
              subcategory: Value(exp['sub'] as String?),
              amount: exp['amt'] as double,
              paymentMethod: Value(exp['method'] as String),
              isRecurring: Value(exp['rec'] as bool),
              notes: Value(exp['notes'] as String?),
              date: expTime,
              createdAt: Value(expTime),
            ),
          );
    }

    // 8. 3 Health Camps in database
    final campsList = [
      {
        'id': IdGenerator.generate(),
        'name': 'Free Community Arthritis & Joint Health Camp',
        'location': 'Central Avenue Park Pavilion, Kolkata',
        'date': now.subtract(const Duration(days: 21)),
        'cost': 2800.0,
        'attendance': 45,
        'clinicId': clinic1Id,
        'notes': 'Screened 45 senior citizens for osteoarthritis and rheumatic complaints. 8 converted to clinic patients.',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'School Children Allergy & Immunity Awareness Camp',
        'location': 'South Point Model School Campus',
        'date': now.subtract(const Duration(days: 14)),
        'cost': 1900.0,
        'attendance': 60,
        'clinicId': clinic3Id,
        'notes': 'Childhood asthma and allergic rhinitis awareness session with parent counseling.',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Senior Citizen Lifestyle & Preventive Health Camp',
        'location': 'Lake Road Community Hall',
        'date': now.add(const Duration(days: 10)),
        'cost': 2400.0,
        'attendance': 50,
        'clinicId': clinic2Id,
        'notes': 'Upcoming geriatric health check camp focusing on blood pressure, joint health, and digestion.',
      },
    ];

    for (final c in campsList) {
      await db.into(db.camps).insertOnConflictUpdate(
            CampsCompanion.insert(
              id: c['id'] as String,
              name: c['name'] as String,
              date: Value(c['date'] as DateTime),
              location: Value(c['location'] as String?),
              cost: Value(c['cost'] as double),
              attendance: Value(c['attendance'] as int),
              clinicId: Value(c['clinicId'] as String?),
              notes: Value(c['notes'] as String?),
              createdAt: Value(now.subtract(const Duration(days: 30))),
            ),
          );
    }

    // 9. Referral Network CRM Partners
    final referralPartners = [
      {
        'name': 'City Care Pharmacy & Chemist',
        'person': 'Arif Munshi',
        'category': 'Pharmacy',
        'phone': '9830114477',
        'address': '12 Central Avenue, Near City Care Clinic',
        'visits': 4,
        'referrals': 12,
        'daysAgo': 5,
        'notes': 'Active pharmacy partner. Stocking dilutions and referring patients for arthritis & chronic care.',
      },
      {
        'name': 'Apex Diagnostic & Pathology Center',
        'person': 'Dr. S. K. Roy (Pathologist)',
        'category': 'Diagnostic Lab',
        'phone': '9830225588',
        'address': '78 Park Street, Ground Floor',
        'visits': 3,
        'referrals': 9,
        'daysAgo': 8,
        'notes': 'Conducts AEC, Thyroid panels, and Blood glucose tests for practice patients.',
      },
      {
        'name': 'Lake View Physiotherapy Clinic',
        'person': 'Dr. Priya Sen (PT)',
        'category': 'Physiotherapy',
        'phone': '9830336699',
        'address': '18 Lake Road, Suite 3B',
        'visits': 3,
        'referrals': 7,
        'daysAgo': 12,
        'notes': 'Mutual referral for cervical spondylosis and joint pain rehabilitation.',
      },
      {
        'name': 'HealthPlus Dental & Oral Care',
        'person': 'Dr. Anisur Rahman (BDS)',
        'category': 'Dentist',
        'phone': '9830447700',
        'address': '24/1 Ripon Street',
        'visits': 2,
        'referrals': 5,
        'daysAgo': 15,
        'notes': 'Referred recurrent aphthae and trigeminal neuralgia cases for homoeopathy.',
      },
      {
        'name': 'Pulse Fitness & Yoga Studio',
        'person': 'Coach Vikram Singh',
        'category': 'Gym / Fitness',
        'phone': '9830558811',
        'address': '52 Ballygunge Circular Rd',
        'visits': 2,
        'referrals': 8,
        'daysAgo': 18,
        'notes': 'Recommends homeopathic lifestyle management for obesity and PCOS members.',
      },
      {
        'name': 'Suraksha Specialist Polyclinic',
        'person': 'Dr. R. Bannerjee (MD General Medicine)',
        'category': 'Specialist Doctor',
        'phone': '9830669922',
        'address': '102 Southern Avenue',
        'visits': 2,
        'referrals': 6,
        'daysAgo': 7,
        'notes': 'Co-manages chronic allergy, asthma, and skin cases with homoeopathy.',
      },
      {
        'name': 'Holistic Ayurveda & Wellness',
        'person': 'Dr. Meenakshi Sundaram (BAMS)',
        'category': 'Ayurveda / AYUSH',
        'phone': '9830771122',
        'address': '34 Gariahat Road',
        'visits': 1,
        'referrals': 4,
        'daysAgo': 14,
        'notes': 'Collaborates on integrated lifestyle protocols for metabolic syndrome.',
      },
      {
        'name': 'Mother & Child Care Polyclinic',
        'person': 'Dr. Suniti Devi (DGO)',
        'category': 'Gynecologist',
        'phone': '9830882233',
        'address': '90 Hazra Road',
        'visits': 2,
        'referrals': 5,
        'daysAgo': 9,
        'notes': 'Refers adolescent PCOD and post-partum alopecia cases for gentle homeopathic management.',
      },
    ];

    for (final partner in referralPartners) {
      final daysAgo = partner['daysAgo'] as int;
      await db.into(db.referralContacts).insertOnConflictUpdate(
            ReferralContactsCompanion.insert(
              id: IdGenerator.generate(),
              name: partner['name'] as String,
              contactPerson: Value(partner['person'] as String?),
              category: Value(partner['category'] as String),
              phone: Value(partner['phone'] as String?),
              address: Value(partner['address'] as String?),
              visitCount: Value(partner['visits'] as int),
              referralCount: Value(partner['referrals'] as int),
              lastVisitedDate: Value(now.subtract(Duration(days: daysAgo))),
              notes: Value(partner['notes'] as String?),
              isActive: const Value(true),
              createdAt: Value(now.subtract(Duration(days: daysAgo + 20))),
              updatedAt: Value(now.subtract(Duration(days: daysAgo))),
            ),
          );
    }
  }
}
