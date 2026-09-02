import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class ReviewWithDetails {
  final ReviewRequest request;
  final Patient patient;
  final Clinic? clinic;

  const ReviewWithDetails({
    required this.request,
    required this.patient,
    this.clinic,
  });

  bool get isCompleted => request.reviewedAt != null;
}

class ReviewStats {
  final int totalAsked;
  final int totalReviewed;
  final int thisMonthReviewed;
  final double averageRating;
  final double conversionRate;

  const ReviewStats({
    required this.totalAsked,
    required this.totalReviewed,
    required this.thisMonthReviewed,
    required this.averageRating,
    required this.conversionRate,
  });
}

final reviewsStreamProvider = StreamProvider<List<ReviewWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  final activeClinic = ref.watch(activeClinicProvider);

  final query =
      db.select(db.reviewRequests).join([
          innerJoin(
            db.patients,
            db.patients.id.equalsExp(db.reviewRequests.patientId),
          ),
          leftOuterJoin(
            db.clinics,
            db.clinics.id.equalsExp(db.reviewRequests.clinicId),
          ),
        ])
        ..where(db.reviewRequests.isDeleted.equals(false))
        ..orderBy([OrderingTerm.desc(db.reviewRequests.requestedAt)]);

  return query.watch().map((rows) {
    var items =
        rows.map((row) {
          return ReviewWithDetails(
            request: row.readTable(db.reviewRequests),
            patient: row.readTable(db.patients),
            clinic: row.readTableOrNull(db.clinics),
          );
        }).toList();

    if (activeClinic != null) {
      items =
          items
              .where(
                (r) =>
                    r.request.clinicId == activeClinic.id ||
                    r.request.clinicId == null,
              )
              .toList();
    }

    return items;
  });
});

final reviewStatsProvider = Provider<AsyncValue<ReviewStats>>((ref) {
  final reviewsAsync = ref.watch(reviewsStreamProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  return reviewsAsync.whenData((reviews) {
    final totalAsked = reviews.length;
    final reviewed = reviews.where((r) => r.isCompleted).toList();
    final totalReviewed = reviewed.length;

    final thisMonthReviewed =
        reviewed
            .where(
              (r) =>
                  r.request.reviewedAt != null &&
                  !r.request.reviewedAt!.isBefore(monthStart),
            )
            .length;

    double ratingSum = 0;
    int ratingCount = 0;
    for (final r in reviewed) {
      if (r.request.rating != null && r.request.rating! > 0) {
        ratingSum += r.request.rating!;
        ratingCount++;
      }
    }

    final avgRating = ratingCount > 0 ? ratingSum / ratingCount : 0.0;
    final conversion =
        totalAsked > 0 ? (totalReviewed / totalAsked) * 100 : 0.0;

    return ReviewStats(
      totalAsked: totalAsked,
      totalReviewed: totalReviewed,
      thisMonthReviewed: thisMonthReviewed,
      averageRating: avgRating,
      conversionRate: conversion,
    );
  });
});

class ReviewNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ReviewNotifier(this._db) : super(const AsyncData(null));

  Future<void> requestReview({
    required String patientId,
    String? clinicId,
    String platform = 'google',
    String? notes,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    final companion = ReviewRequestsCompanion.insert(
      id: IdGenerator.generate(),
      patientId: patientId,
      clinicId: Value(clinicId),
      requestedAt: Value(now),
      platform: Value(platform),
      notes: Value(notes),
      createdAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.reviewRequests).insert(companion);
      // Mark review asked on patient table too
      await (_db.update(_db.patients)
        ..where((t) => t.id.equals(patientId))).write(
        PatientsCompanion(reviewAskedAt: Value(now), updatedAt: Value(now)),
      );
    });
  }

  Future<void> recordReviewSubmitted({
    required String requestId,
    required String patientId,
    int? rating,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.reviewRequests)
        ..where((t) => t.id.equals(requestId))).write(
        ReviewRequestsCompanion(
          reviewedAt: Value(now),
          rating: Value(rating),
          notes: Value(notes),
        ),
      );

      // Mark review given on patient table
      await (_db.update(_db.patients)
        ..where((t) => t.id.equals(patientId))).write(
        PatientsCompanion(
          reviewGiven: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> deleteRequest(String requestId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.reviewRequests)..where(
        (t) => t.id.equals(requestId),
      )).write(const ReviewRequestsCompanion(isDeleted: Value(true)));
    });
  }
}

final reviewNotifierProvider =
    StateNotifierProvider<ReviewNotifier, AsyncValue<void>>((ref) {
      final db = ref.watch(databaseProvider);
      return ReviewNotifier(db);
    });
