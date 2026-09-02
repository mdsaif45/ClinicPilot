import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../patients/providers/recall_provider.dart';
import 'camp_provider.dart';
import 'disease_analytics_provider.dart';
import 'growth_provider.dart';
import 'profit_provider.dart';
import 'review_provider.dart';

class CoachInsight {
  final String id;
  final String title;
  final String message;
  final String actionLabel;
  final String actionRoute;
  final IconData icon;
  final int priority; // higher = higher priority

  const CoachInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionRoute,
    required this.icon,
    this.priority = 1,
  });
}

final dailyInsightProvider = Provider<CoachInsight?>((ref) {
  final growth = ref.watch(growthAnalyticsProvider).value;
  final profit = ref.watch(profitSummaryProvider).value;
  final recall = ref.watch(recallListProvider).value;
  final reviewStats = ref.watch(reviewStatsProvider).value;
  final diseaseSummary = ref.watch(diseaseAnalyticsProvider).value;
  final campStats = ref.watch(campStatsProvider).value;

  final generatedInsights = <CoachInsight>[];

  // Rule 1: Overdue follow-up patients
  final overdueCount = recall?.overdue.length ?? 0;
  if (overdueCount > 0) {
    generatedInsights.add(CoachInsight(
      id: 'recall_overdue',
      title: '$overdueCount ${overdueCount == 1 ? 'Patient' : 'Patients'} Overdue for Follow-up',
      message: 'Send WhatsApp check-ins or follow-up reminders to ensure uninterrupted homeopathic treatment.',
      actionLabel: 'View Follow-ups',
      actionRoute: '/patients?tab=follow-ups',
      icon: Icons.notifications_active_outlined,
      priority: 5,
    ));
  }

  // Rule 2: Referral Source Concentration
  if (growth != null && growth.referralSourceCount.isNotEmpty) {
    final totalRefs = growth.referralSourceCount.values.fold<int>(0, (a, b) => a + b);
    if (totalRefs >= 3) {
      final sortedRefs = growth.referralSourceCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topRef = sortedRefs.first;
      final pct = (topRef.value / totalRefs) * 100;
      if (pct >= 35) {
        generatedInsights.add(CoachInsight(
          id: 'referral_concentration',
          title: '${pct.toStringAsFixed(0)}% of New Patients from ${topRef.key}',
          message: '${topRef.key} is your strongest patient acquisition channel this period.',
          actionLabel: 'See Referral Mix',
          actionRoute: '/growth/referral',
          icon: Icons.share_outlined,
          priority: 4,
        ));
      }
    }
  }

  // Rule 3: Top Value Condition
  if (diseaseSummary != null && diseaseSummary.stats.isNotEmpty && diseaseSummary.totalRevenue > 0) {
    final top = diseaseSummary.stats.first;
    final pct = (top.totalRevenue / diseaseSummary.totalRevenue) * 100;
    if (pct >= 25 && top.totalRevenue >= 1000) {
      generatedInsights.add(CoachInsight(
        id: 'disease_top_value',
        title: '${top.disease} Generated ${pct.toStringAsFixed(0)}% of Revenue',
        message: 'Yielded ${Formatters.formatCurrency(top.totalRevenue)} across ${top.patientCount} patients with a ${top.repeatRate.toStringAsFixed(0)}% repeat rate.',
        actionLabel: 'Analyze Diseases',
        actionRoute: '/growth/diseases',
        icon: Icons.medical_services_outlined,
        priority: 3,
      ));
    }
  }

  // Rule 4: Reputation & Review Milestone
  if (reviewStats != null && reviewStats.totalReviewed > 0) {
    generatedInsights.add(CoachInsight(
      id: 'review_milestone',
      title: '${reviewStats.totalReviewed} Google Reviews Logged (${reviewStats.averageRating.toStringAsFixed(1)} ★)',
      message: 'Positive patient testimonials build online authority and attract high-trust organic leads.',
      actionLabel: 'View Growth Hub',
      actionRoute: '/growth',
      icon: Icons.star_rate_rounded,
      priority: 3,
    ));
  }

  // Rule 5: Camp ROI Milestone
  if (campStats != null && campStats.totalCamps > 0 && campStats.aggregateRoi > 0) {
    generatedInsights.add(CoachInsight(
      id: 'camp_roi',
      title: 'Health Camps Yielded +${campStats.aggregateRoi.toStringAsFixed(0)}% ROI',
      message: '${campStats.totalPatientsAcquired} patients acquired generated ${Formatters.formatCurrency(campStats.totalFollowUpRevenue)} in 90-day follow-up revenue.',
      actionLabel: 'Open Camp Manager',
      actionRoute: '/growth/camps',
      icon: Icons.campaign_outlined,
      priority: 4,
    ));
  }

  // Rule 6: Profit Margin / Operating Efficiency
  if (profit != null && profit.totalIncome >= 5000) {
    final margin = (profit.netProfit / profit.totalIncome) * 100;
    if (margin >= 50) {
      generatedInsights.add(CoachInsight(
        id: 'strong_profit_margin',
        title: 'Strong Operating Margin: ${margin.toStringAsFixed(0)}%',
        message: 'Practice earned ${Formatters.formatCurrency(profit.netProfit)} net after clinic rent and expenses.',
        actionLabel: 'View Profit Summary',
        actionRoute: '/growth/profit',
        icon: Icons.trending_up_outlined,
        priority: 2,
      ));
    }
  }

  // Default baseline insight if no trigger fired
  if (generatedInsights.isEmpty) {
    generatedInsights.add(const CoachInsight(
      id: 'default_coach_tip',
      title: 'Practice Growth Tip',
      message: 'Record every walk-in inquiry and send timely follow-up messages to build high-retention care loops.',
      actionLabel: 'Open Growth Hub',
      actionRoute: '/growth',
      icon: Icons.psychology_outlined,
      priority: 1,
    ));
  }

  // Pick top priority insight or rotate based on day of year
  generatedInsights.sort((a, b) => b.priority.compareTo(a.priority));

  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  final index = dayOfYear % generatedInsights.length;

  return generatedInsights[index];
});
