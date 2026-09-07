import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/features/clinical/models/dental_chart_model.dart';

void main() {
  group('DentalNotationUtils Tests', () {
    test('all32Teeth contains exactly 32 adult permanent teeth', () {
      expect(DentalNotationUtils.all32Teeth.length, equals(32));
      expect(DentalNotationUtils.all32Teeth.toSet().length, equals(32));
    });

    test('Quadrant tooth lists have 8 teeth each', () {
      expect(DentalNotationUtils.upperRightTeeth.length, equals(8));
      expect(DentalNotationUtils.upperLeftTeeth.length, equals(8));
      expect(DentalNotationUtils.lowerLeftTeeth.length, equals(8));
      expect(DentalNotationUtils.lowerRightTeeth.length, equals(8));
    });

    test('FDI to Universal numbering mapping matches ADA standards', () {
      // Quadrant 1 (Upper Right: 18..11 -> 1..8)
      expect(DentalNotationUtils.fdiToUniversal(18), equals(1));
      expect(DentalNotationUtils.fdiToUniversal(16), equals(3));
      expect(DentalNotationUtils.fdiToUniversal(11), equals(8));

      // Quadrant 2 (Upper Left: 21..28 -> 9..16)
      expect(DentalNotationUtils.fdiToUniversal(21), equals(9));
      expect(DentalNotationUtils.fdiToUniversal(26), equals(14));
      expect(DentalNotationUtils.fdiToUniversal(28), equals(16));

      // Quadrant 3 (Lower Left: 31..38 -> 24..17)
      expect(DentalNotationUtils.fdiToUniversal(38), equals(17));
      expect(DentalNotationUtils.fdiToUniversal(36), equals(19));
      expect(DentalNotationUtils.fdiToUniversal(31), equals(24));

      // Quadrant 4 (Lower Right: 41..48 -> 25..32)
      expect(DentalNotationUtils.fdiToUniversal(41), equals(25));
      expect(DentalNotationUtils.fdiToUniversal(46), equals(30));
      expect(DentalNotationUtils.fdiToUniversal(48), equals(32));
    });

    test('Universal to FDI inverse mapping works correctly', () {
      for (final fdi in DentalNotationUtils.all32Teeth) {
        final univ = DentalNotationUtils.fdiToUniversal(fdi);
        expect(DentalNotationUtils.universalToFdi(univ), equals(fdi));
      }
    });

    test('formatToothNumber formats correctly according to notation', () {
      expect(
        DentalNotationUtils.formatToothNumber(16, DentalNotation.fdi),
        equals('16'),
      );
      expect(
        DentalNotationUtils.formatToothNumber(16, DentalNotation.universal),
        equals('#3'),
      );
      expect(
        DentalNotationUtils.formatToothNumber(36, DentalNotation.universal),
        equals('#19'),
      );
    });

    test('getToothName returns accurate anatomical descriptions', () {
      expect(
        DentalNotationUtils.getToothName(11),
        equals('Upper Right Central Incisor'),
      );
      expect(DentalNotationUtils.getToothName(23), equals('Upper Left Canine'));
      expect(
        DentalNotationUtils.getToothName(36),
        equals('Lower Left First Molar'),
      );
      expect(
        DentalNotationUtils.getToothName(48),
        equals('Lower Right Third Molar (Wisdom)'),
      );
    });

    test('getQuadrantName returns accurate quadrant labels', () {
      expect(
        DentalNotationUtils.getQuadrantName(16),
        contains('Upper Right (Maxillary Q1)'),
      );
      expect(
        DentalNotationUtils.getQuadrantName(26),
        contains('Upper Left (Maxillary Q2)'),
      );
      expect(
        DentalNotationUtils.getQuadrantName(36),
        contains('Lower Left (Mandibular Q3)'),
      );
      expect(
        DentalNotationUtils.getQuadrantName(46),
        contains('Lower Right (Mandibular Q4)'),
      );
    });
  });

  group('ToothData Tests', () {
    test('default ToothData is healthy with no affected surfaces', () {
      const tooth = ToothData(fdiNumber: 16);
      expect(tooth.isHealthy, isTrue);
      expect(tooth.hasCaries, isFalse);
      expect(tooth.affectedSurfaces, isEmpty);
      expect(tooth.surfacesSummary, isEmpty);
      expect(tooth.notes, isEmpty);
    });

    test('surfacesSummary orders surfaces as MODBL', () {
      final tooth = const ToothData(fdiNumber: 16).copyWith(
        condition: ToothCondition.caries,
        affectedSurfaces: {
          ToothSurface.distal,
          ToothSurface.mesial,
          ToothSurface.occlusal,
        },
      );
      expect(tooth.surfacesSummary, equals('MOD'));
    });

    test('ToothData JSON serialization round-trip preserves state', () {
      final tooth = const ToothData(
        fdiNumber: 26,
        condition: ToothCondition.filled,
        affectedSurfaces: {ToothSurface.mesial, ToothSurface.occlusal},
        notes: 'Composite restoration intact',
      );

      final json = tooth.toJson();
      final reconstructed = ToothData.fromJson(json);

      expect(reconstructed.fdiNumber, equals(26));
      expect(reconstructed.condition, equals(ToothCondition.filled));
      expect(reconstructed.affectedSurfaces.length, equals(2));
      expect(reconstructed.surfacesSummary, equals('MO'));
      expect(reconstructed.notes, equals('Composite restoration intact'));
    });
  });

  group('DentalProcedure Tests', () {
    test('status helper flags return correct boolean', () {
      final p1 = DentalProcedure(
        id: 'p1',
        title: 'RCT',
        toothNumbers: [16],
        status: 'planned',
      );
      expect(p1.isPlanned, isTrue);
      expect(p1.isCompleted, isFalse);

      final p2 = p1.copyWith(status: 'completed');
      expect(p2.isCompleted, isTrue);
      expect(p2.isPlanned, isFalse);
    });

    test('toothSummary returns Full Mouth if empty or lists tooth numbers', () {
      final p1 = DentalProcedure(
        id: 'p1',
        title: 'Scaling',
        toothNumbers: const [],
      );
      expect(p1.toothSummary, equals('Full Mouth'));

      final p2 = DentalProcedure(
        id: 'p2',
        title: 'Composite',
        toothNumbers: const [16, 26],
      );
      expect(p2.toothSummary, equals('16, 26'));
    });

    test('DentalProcedure JSON serialization round-trip', () {
      final proc = DentalProcedure(
        id: 'proc-101',
        title: 'Zirconia Crown',
        toothNumbers: [46],
        estimatedFee: 6500.0,
        status: 'in_progress',
        notes: 'Margin subgingival',
        appointmentDate: DateTime(2026, 9, 15),
      );

      final json = proc.toJson();
      final reconstructed = DentalProcedure.fromJson(json);

      expect(reconstructed.id, equals('proc-101'));
      expect(reconstructed.title, equals('Zirconia Crown'));
      expect(reconstructed.toothNumbers, equals([46]));
      expect(reconstructed.estimatedFee, equals(6500.0));
      expect(reconstructed.isInProgress, isTrue);
      expect(reconstructed.notes, equals('Margin subgingival'));
    });
  });

  group('DentalChartData Tests', () {
    test('initializes with 32 teeth all healthy', () {
      final chart = DentalChartData();
      expect(chart.teeth.length, equals(32));
      expect(chart.totalTeethPresent, equals(32));
      expect(chart.cariesCount, equals(0));
      expect(chart.filledCount, equals(0));
      expect(chart.rootCanalCount, equals(0));
      expect(chart.crownCount, equals(0));
      expect(chart.missingCount, equals(0));
      expect(chart.hasFindings, isFalse);
    });

    test('updating tooth conditions accurately updates counts', () {
      var chart = DentalChartData();

      // Tooth 16: Caries (MOD)
      chart = chart.withUpdatedTooth(
        const ToothData(
          fdiNumber: 16,
          condition: ToothCondition.caries,
          affectedSurfaces: {
            ToothSurface.mesial,
            ToothSurface.occlusal,
            ToothSurface.distal,
          },
        ),
      );

      // Tooth 21: Root Canal
      chart = chart.withUpdatedTooth(
        const ToothData(fdiNumber: 21, condition: ToothCondition.rootCanal),
      );

      // Tooth 46: Crown
      chart = chart.withUpdatedTooth(
        const ToothData(fdiNumber: 46, condition: ToothCondition.crown),
      );

      // Tooth 18: Missing
      chart = chart.withUpdatedTooth(
        const ToothData(fdiNumber: 18, condition: ToothCondition.missing),
      );

      expect(chart.cariesCount, equals(1));
      expect(chart.rootCanalCount, equals(1));
      expect(chart.crownCount, equals(1));
      expect(chart.missingCount, equals(1));
      expect(chart.totalTeethPresent, equals(31)); // 32 - 1 missing
      expect(chart.hasFindings, isTrue);

      expect(chart.summaryBadgeText, contains('31 Teeth Present'));
      expect(chart.summaryBadgeText, contains('1 Caries'));
      expect(chart.summaryBadgeText, contains('1 RCT'));
      expect(chart.summaryBadgeText, contains('1 Crowns'));
      expect(chart.summaryBadgeText, contains('1 Missing'));
    });

    test('procedure management and total fee calculation', () {
      var chart = DentalChartData();

      chart = chart.withAddedProcedure(
        const DentalProcedure(
          id: 'proc-1',
          title: 'Root Canal Treatment',
          toothNumbers: [21],
          estimatedFee: 4000.0,
        ),
      );

      chart = chart.withAddedProcedure(
        const DentalProcedure(
          id: 'proc-2',
          title: 'Zirconia Crown',
          toothNumbers: [21],
          estimatedFee: 7000.0,
        ),
      );

      expect(chart.procedures.length, equals(2));
      expect(chart.totalPlannedFees, equals(11000.0));

      // Remove procedure
      chart = chart.withRemovedProcedure('proc-1');
      expect(chart.procedures.length, equals(1));
      expect(chart.totalPlannedFees, equals(7000.0));
    });

    test('JSON serialization round-trip', () {
      var chart = DentalChartData(
        notation: DentalNotation.universal,
        generalNotes: 'Patient has mild fluorosis',
      );

      chart = chart.withUpdatedTooth(
        const ToothData(
          fdiNumber: 36,
          condition: ToothCondition.caries,
          affectedSurfaces: {ToothSurface.occlusal},
        ),
      );

      chart = chart.withAddedProcedure(
        const DentalProcedure(
          id: 'p-1',
          title: 'Composite Filling',
          toothNumbers: [36],
          estimatedFee: 1500.0,
        ),
      );

      final json = chart.toJson();
      final reconstructed = DentalChartData.fromJson(json);

      expect(reconstructed.notation, equals(DentalNotation.universal));
      expect(reconstructed.generalNotes, equals('Patient has mild fluorosis'));
      expect(reconstructed.teeth[36]?.hasCaries, isTrue);
      expect(reconstructed.cariesCount, equals(1));
      expect(reconstructed.procedures.length, equals(1));
      expect(reconstructed.totalPlannedFees, equals(1500.0));
    });

    test(
      'Integration with MasterCaseRecordData saves and restores without loss',
      () {
        var dental = DentalChartData(generalNotes: 'Dentition stable');
        dental = dental.withUpdatedTooth(
          const ToothData(
            fdiNumber: 16,
            condition: ToothCondition.caries,
            affectedSurfaces: {ToothSurface.occlusal},
          ),
        );
        dental = dental.withAddedProcedure(
          const DentalProcedure(
            id: 'd-1',
            title: 'Extraction',
            toothNumbers: [18],
            estimatedFee: 1200.0,
          ),
        );

        // Convert to MasterCaseRecordData
        final record = dental.toMasterCaseRecord(patientId: 'patient-42');

        expect(record.patientId, equals('patient-42'));
        expect(record.clinicalExam.dentalChartJson, isNotEmpty);
        expect(
          record.clinicalExam.entOralExamination,
          contains('DENTAL ODONTOGRAM'),
        );

        // Reconstruct back from MasterCaseRecordData
        final restored = DentalChartData.fromMasterCaseRecord(record);

        expect(restored.cariesCount, equals(1));
        expect(restored.teeth[16]?.hasCaries, isTrue);
        expect(restored.teeth[16]?.surfacesSummary, equals('O'));
        expect(restored.procedures.length, equals(1));
        expect(restored.procedures.first.title, equals('Extraction'));
        expect(restored.totalPlannedFees, equals(1200.0));
      },
    );
  });
}
