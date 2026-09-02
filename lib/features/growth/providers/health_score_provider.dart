import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'growth_provider.dart';
import 'profit_provider.dart';
import 'review_provider.dart';

class HealthScorePillar {
  final String title;
  final double score;
  final double maxScore;
  final String detail;

  const HealthScorePillar({
    required this.title,
    required this.score,
    required this.maxScore,
    required this.detail,
  });

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0.0;
}

class ClinicHealthScore {
  final int totalScore; // 0-100
  final String grade;
  final String summaryReason;
  final List<HealthScorePillar> pillars;

  const ClinicHealthScore({
    required this.totalScore,
    required this.grade,
    required this.summaryReason,
    required this.pillars,
  });
}

final clinicHealthScoreProvider = Provider<AsyncValue<ClinicHealthScore>>((ref) {
  final growthAsync = ref.watch(growthAnalyticsProvider);
  final profitAsync = ref.watch(profitSummaryProvider);
  final reviewStatsAsync = ref.watch(reviewStatsProvider);

  // If initial load and no data available yet, return loading
  if (!growthAsync.hasValue || !profitAsync.hasValue) {
    if (growthAsync.hasError) {
      return AsyncError(growthAsync.error!, growthAsync.stackTrace!);
    }
    if (profitAsync.hasError) {
      return AsyncError(profitAsync.error!, profitAsync.stackTrace!);
    }
    return const AsyncLoading();
  }

  final growth = growthAsync.value!;
  final profit = profitAsync.value!;
  final reviewStats = reviewStatsAsync.value;

  // 1. Revenue Growth / Volume (25 pts)
  // Base: Total revenue in period compared to target base (>= 25,000 = 25 pts)
  final double revenueScore;
  if (profit.totalIncome >= 25000) {
    revenueScore = 25.0;
  } else if (profit.totalIncome <= 0) {
    revenueScore = 0.0;
  } else {
    revenueScore = (profit.totalIncome / 25000) * 25.0;
  }
  final revenuePillar = HealthScorePillar(
    title: 'Revenue Performance',
    score: revenueScore.clamp(0.0, 25.0),
    maxScore: 25.0,
    detail: '₹${profit.totalIncome.toStringAsFixed(0)} earned in selected period',
  );

  // 2. New Patient Acquisition (25 pts)
  // Target: >= 10 new patients = 25 pts
  final double newPtScore;
  if (growth.totalNewPatients >= 10) {
    newPtScore = 25.0;
  } else {
    newPtScore = (growth.totalNewPatients / 10.0) * 25.0;
  }
  final newPtPillar = HealthScorePillar(
    title: 'New Patient Flow',
    score: newPtScore.clamp(0.0, 25.0),
    maxScore: 25.0,
    detail: '${growth.totalNewPatients} new patients registered',
  );

  // 3. Patient Retention & Repeat Rate (20 pts)
  // Target: >= 40% repeat rate = 20 pts
  final double retentionScore;
  if (growth.repeatRate >= 40.0) {
    retentionScore = 20.0;
  } else {
    retentionScore = (growth.repeatRate / 40.0) * 20.0;
  }
  final retentionPillar = HealthScorePillar(
    title: 'Patient Retention',
    score: retentionScore.clamp(0.0, 20.0),
    maxScore: 20.0,
    detail: '${growth.repeatRate.toStringAsFixed(1)}% repeat consultation rate',
  );

  // 4. Profit Margin (15 pts)
  // Target: >= 50% net profit margin = 15 pts
  final double margin = profit.totalIncome > 0
      ? (profit.netProfit / profit.totalIncome) * 100
      : 0.0;
  final double profitScore;
  if (margin >= 50.0) {
    profitScore = 15.0;
  } else if (margin <= 0.0) {
    profitScore = 0.0;
  } else {
    profitScore = (margin / 50.0) * 15.0;
  }
  final profitPillar = HealthScorePillar(
    title: 'Operating Profit Margin',
    score: profitScore.clamp(0.0, 15.0),
    maxScore: 15.0,
    detail: '${margin.toStringAsFixed(1)}% margin (Net profit ₹${profit.netProfit.toStringAsFixed(0)})',
  );

  // 5. Reputation & Growth Engagement (15 pts)
  // Target: reviews collected or patient follow-ups active
  final double reviewScore;
  final reviewsCount = reviewStats?.totalReviewed ?? 0;
  if (reviewsCount >= 5) {
    reviewScore = 15.0;
  } else {
    reviewScore = (reviewsCount / 5.0) * 15.0;
  }
  final reviewPillar = HealthScorePillar(
    title: 'Reputation & Growth',
    score: reviewScore.clamp(0.0, 15.0),
    maxScore: 15.0,
    detail: '$reviewsCount Google reviews logged',
  );

  final pillars = [
    revenuePillar,
    newPtPillar,
    retentionPillar,
    profitPillar,
    reviewPillar,
  ];

  final totalDouble = pillars.fold<double>(0.0, (sum, p) => sum + p.score);
  final totalScore = totalDouble.round().clamp(0, 100);

  final String grade;
  if (totalScore >= 80) {
    grade = 'Excellent';
  } else if (totalScore >= 60) {
    grade = 'Good & Stable';
  } else if (totalScore >= 40) {
    grade = 'Needs Attention';
  } else {
    grade = 'Critical Focus';
  }

  final summaryReason =
      '$totalScore / 100 ($grade) • ${growth.totalNewPatients} new pts, ${growth.repeatRate.toStringAsFixed(0)}% repeat, ₹${profit.netProfit.toStringAsFixed(0)} net';

  return AsyncData(ClinicHealthScore(
    totalScore: totalScore,
    grade: grade,
    summaryReason: summaryReason,
    pillars: pillars,
  ));
});
