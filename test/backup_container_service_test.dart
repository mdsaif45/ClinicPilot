import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/backup_container_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BackupContainerService backupService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backupService = BackupContainerService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupContainerService Unit & Round-Trip Tests', () {
    test(
      'buildBackupBytes exports all 14 tables into valid .cpbak container',
      () async {
        final now = DateTime.now();

        // 1. Seed realistic practice data into db
        await db
            .into(db.clinics)
            .insert(
              Clinic(
                id: 'clinic-1',
                name: 'Apex Homeopathy Center',
                monthlyRent: 15000,
                defaultConsultationFee: 500,
                openDays: 'Mon,Tue,Wed,Thu,Fri,Sat',
                colorHex: '#1976D2',
                isActive: true,
                isDeleted: false,
                createdAt: now,
              ),
            );

        await db
            .into(db.patients)
            .insert(
              Patient(
                id: 'patient-1',
                patientCode: 'P001',
                serialNo: '1',
                name: 'Rohan Verma',
                phone: '9876543210',
                age: 34,
                gender: 'Male',
                primaryClinicId: 'clinic-1',
                reviewGiven: false,
                isDeleted: false,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.patientCaseRecords)
            .insert(
              PatientCaseRecord(
                id: 'case-1',
                patientId: 'patient-1',
                recordDate: now,
                chiefComplaintsJson: '[]',
                hpi: 'Chronic migraine since 2 years',
                isDeleted: false,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.complaints)
            .insert(
              Complaint(
                id: 'comp-1',
                patientId: 'patient-1',
                complaintIndex: 1,
                complaintName: 'Migraine headache',
                location: 'Right temporal',
                severity: 7,
                status: 'Active',
                beforeImages: jsonEncode([
                  '/old/phone/storage/clinic_pilot/patient_media/patient-1/photo1.jpg',
                ]),
                isDeleted: false,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.prescriptions)
            .insert(
              Prescription(
                id: 'rx-1',
                patientId: 'patient-1',
                remedyIndex: 1,
                remedyName: 'Belladonna',
                potency: '200C',
                vehicle: 'Pills',
                doseCount: '4 pills',
                frequency: 'TDS',
                durationDays: '7',
                isDeleted: false,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.investigations)
            .insert(
              Investigation(
                id: 'inv-1',
                patientId: 'patient-1',
                testName: 'Complete Blood Count (CBC)',
                testCategory: 'Hematology',
                stringValue: '14.2',
                unit: 'g/dL',
                flag: 'Normal',
                reportAttachments: jsonEncode([
                  '/old/phone/storage/clinic_pilot/patient_media/patient-1/cbc_report.pdf',
                ]),
                testDate: now,
                isDeleted: false,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.visits)
            .insert(
              Visit(
                id: 'visit-1',
                patientId: 'patient-1',
                clinicId: 'clinic-1',
                visitDate: now,
                disease: 'Migraine',
                visitType: 'New',
                consultationType: 'Clinic',
                isDeleted: false,
                createdAt: now,
              ),
            );

        await db
            .into(db.cashMemos)
            .insert(
              CashMemo(
                id: 'memo-1',
                memoNumber: 'MEMO-001',
                patientId: 'patient-1',
                clinicId: 'clinic-1',
                consultationFee: 500,
                medicineFee: 200,
                otherFee: 0,
                discount: 0,
                total: 700,
                paidAmount: 700,
                paymentMethod: 'Cash',
                memoDate: now,
                isDeleted: false,
                createdAt: now,
              ),
            );

        await db
            .into(db.expenses)
            .insert(
              Expense(
                id: 'exp-1',
                clinicId: 'clinic-1',
                category: 'Rent',
                amount: 15000,
                paymentMethod: 'UPI',
                isRecurring: true,
                date: now,
                isDeleted: false,
                createdAt: now,
              ),
            );

        await db
            .into(db.referralContacts)
            .insert(
              ReferralContact(
                id: 'ref-1',
                name: 'Dr. S. K. Sharma',
                category: 'Doctor',
                visitCount: 2,
                referralCount: 5,
                isActive: true,
                isDeleted: false,
                createdAt: now,
                updatedAt: now,
              ),
            );

        // 2. Build backup bytes
        final backupBytes = await backupService.buildBackupBytes();
        expect(backupBytes.isNotEmpty, isTrue);

        // 3. Inspect backup metadata
        final metadata = BackupContainerService.inspectBackup(backupBytes);
        expect(metadata.app, equals('ClinicPilot'));
        expect(metadata.formatVersion, equals(2));
        expect(metadata.counts['clinics'], equals(1));
        expect(metadata.counts['patients'], equals(1));
        expect(metadata.counts['patientCaseRecords'], equals(1));
        expect(metadata.counts['complaints'], equals(1));
        expect(metadata.counts['prescriptions'], equals(1));
        expect(metadata.counts['investigations'], equals(1));
        expect(metadata.counts['visits'], equals(1));
        expect(metadata.counts['cashMemos'], equals(1));
        expect(metadata.counts['expenses'], equals(1));
        expect(metadata.counts['referralContacts'], equals(1));
        expect(metadata.checksumSha256.isNotEmpty, isTrue);

        // 4. Wipe DB completely
        await db.clearAllPracticeData();
        final wipedPatients = await db.select(db.patients).get();
        expect(wipedPatients.isEmpty, isTrue);

        // 5. Restore from backup
        final restoreResult = await backupService.restoreFromBackupBytes(
          backupBytes,
        );
        expect(restoreResult.success, isTrue);

        // 6. Verify full data restored accurately
        final restoredClinics = await db.select(db.clinics).get();
        expect(restoredClinics.length, equals(1));
        expect(restoredClinics.first.name, equals('Apex Homeopathy Center'));

        final restoredPatients = await db.select(db.patients).get();
        expect(restoredPatients.length, equals(1));
        expect(restoredPatients.first.name, equals('Rohan Verma'));
        expect(restoredPatients.first.phone, equals('9876543210'));

        final restoredCaseRecords =
            await db.select(db.patientCaseRecords).get();
        expect(restoredCaseRecords.length, equals(1));
        expect(
          restoredCaseRecords.first.hpi,
          equals('Chronic migraine since 2 years'),
        );

        final restoredComplaints = await db.select(db.complaints).get();
        expect(restoredComplaints.length, equals(1));
        expect(
          restoredComplaints.first.complaintName,
          equals('Migraine headache'),
        );
        expect(restoredComplaints.first.beforeImages, isNotNull);

        final restoredRx = await db.select(db.prescriptions).get();
        expect(restoredRx.length, equals(1));
        expect(restoredRx.first.remedyName, equals('Belladonna'));
        expect(restoredRx.first.potency, equals('200C'));

        final restoredInvestigations = await db.select(db.investigations).get();
        expect(restoredInvestigations.length, equals(1));
        expect(restoredInvestigations.first.reportAttachments, isNotNull);

        final restoredMemos = await db.select(db.cashMemos).get();
        expect(restoredMemos.length, equals(1));
        expect(restoredMemos.first.total, equals(700));

        final restoredReferrals = await db.select(db.referralContacts).get();
        expect(restoredReferrals.length, equals(1));
        expect(restoredReferrals.first.name, equals('Dr. S. K. Sharma'));
      },
    );

    test('inspectBackup rejects invalid or non-ClinicPilot JSON files', () {
      final invalidJson = utf8.encode(
        jsonEncode({'app': 'OtherApp', 'data': []}),
      );
      expect(
        () => BackupContainerService.inspectBackup(invalidJson),
        throwsA(isA<BackupCorruptedException>()),
      );
    });

    test(
      'restoreFromBackupBytes detects corrupted checksum in archive and aborts',
      () async {
        // 1. Build a legitimate backup
        await db
            .into(db.clinics)
            .insert(
              Clinic(
                id: 'clinic-temp',
                name: 'Temp Clinic',
                monthlyRent: 5000,
                defaultConsultationFee: 300,
                openDays: 'Mon,Wed,Fri',
                colorHex: '#1976D2',
                isActive: true,
                isDeleted: false,
                createdAt: DateTime.now(),
              ),
            );

        final validBytes = await backupService.buildBackupBytes();

        // 2. Decode archive and tamper manifest checksum
        final archive = ZipDecoder().decodeBytes(validBytes);
        final manifestFile = archive.findFile('manifest.json')!;
        final manifestMap =
            jsonDecode(utf8.decode(manifestFile.content as List<int>))
                as Map<String, dynamic>;
        manifestMap['checksumSha256'] =
            'tampered_invalid_sha256_checksum_value';

        final tamperedManifestBytes = utf8.encode(jsonEncode(manifestMap));
        archive.addFile(
          ArchiveFile(
            'manifest.json',
            tamperedManifestBytes.length,
            tamperedManifestBytes,
          ),
        );

        final tamperedZipBytes = ZipEncoder().encode(archive)!;

        // 3. Attempt restore and verify checksum failure
        expect(
          () => backupService.restoreFromBackupBytes(tamperedZipBytes),
          throwsA(isA<BackupCorruptedException>()),
        );
      },
    );
  });
}
