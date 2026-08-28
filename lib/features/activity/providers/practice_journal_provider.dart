import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

enum JournalEventType {
  consultation,
  dispense,
  expense,
}

class PracticeJournalEntry {
  final String id;
  final DateTime timestamp;
  final JournalEventType type;
  final String title;
  final String? subtitle;
  final double? amount;
  final String? paymentMethod;
  final String? patientName;
  final String? category;

  const PracticeJournalEntry({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    this.subtitle,
    this.amount,
    this.paymentMethod,
    this.patientName,
    this.category,
  });
}

class JournalDayGroup {
  final DateTime date;
  final String dayLabel;
  final double totalRevenue;
  final int totalPatients;
  final double totalExpense;
  final List<PracticeJournalEntry> entries;

  const JournalDayGroup({
    required this.date,
    required this.dayLabel,
    required this.totalRevenue,
    required this.totalPatients,
    required this.totalExpense,
    required this.entries,
  });
}

/// Category filter provider for the Practice Journal (All, Consultations, Dispenses, Expenses)
final journalCategoryFilterProvider = StateProvider<JournalEventType?>((ref) => null);

/// Search query provider for the Practice Journal
final journalSearchQueryProvider = StateProvider<String>((ref) => '');

/// Synchronously aggregates historical clinical events into grouped daily buckets
final practiceJournalProvider = Provider<List<JournalDayGroup>>((ref) {
  final rawData = ref.watch(dashboardRawStreamsProvider).valueOrNull;
  final activeClinic = ref.watch(activeClinicProvider);
  final clinicId = activeClinic?.id;
  final categoryFilter = ref.watch(journalCategoryFilterProvider);
  final searchQuery = ref.watch(journalSearchQueryProvider).trim().toLowerCase();

  if (rawData == null) return const [];

  bool inClinic(String? rowClinicId) => clinicId == null || rowClinicId == clinicId;

  final patientMap = {for (final p in rawData.patients) p.id: p.name};

  final allEntries = <PracticeJournalEntry>[];

  // 1. Visits / Consultations
  for (final v in rawData.visits) {
    if (!inClinic(v.clinicId)) continue;
    final patientName = patientMap[v.patientId] ?? 'Patient';
    final isNew = v.visitType.toLowerCase() == 'new';
    final visitTypeLabel = isNew ? 'New Consultation' : 'Follow-up Consultation';

    allEntries.add(
      PracticeJournalEntry(
        id: 'v_${v.id}',
        timestamp: v.visitDate,
        type: JournalEventType.consultation,
        title: '$patientName • $visitTypeLabel',
        subtitle: v.disease.isNotEmpty ? 'Condition: ${v.disease}' : 'General Consultation',
        patientName: patientName,
        category: 'Consultation',
      ),
    );
  }

  // 2. Cash Memos / Dispenses & Invoices
  for (final m in rawData.memos) {
    if (!inClinic(m.clinicId)) continue;
    final patientName = patientMap[m.patientId] ?? 'Patient';
    final pMethod = m.paymentMethod.toUpperCase();

    allEntries.add(
      PracticeJournalEntry(
        id: 'm_${m.id}',
        timestamp: m.memoDate,
        type: JournalEventType.dispense,
        title: 'Invoice #${m.memoNumber} • $patientName',
        subtitle: 'Payment: $pMethod',
        amount: m.total,
        paymentMethod: pMethod,
        patientName: patientName,
        category: 'Dispense',
      ),
    );
  }

  // 3. Expenses
  for (final e in rawData.expenses) {
    if (!inClinic(e.clinicId)) continue;

    allEntries.add(
      PracticeJournalEntry(
        id: 'e_${e.id}',
        timestamp: e.date,
        type: JournalEventType.expense,
        title: 'Clinic Expense • ${e.category}',
        subtitle: e.notes?.isNotEmpty == true ? e.notes : 'Operational Cost',
        amount: e.amount,
        category: e.category,
      ),
    );
  }

  // Filter by category
  var filteredEntries = allEntries;
  if (categoryFilter != null) {
    filteredEntries = filteredEntries.where((e) => e.type == categoryFilter).toList();
  }

  // Filter by search query
  if (searchQuery.isNotEmpty) {
    filteredEntries = filteredEntries.where((e) {
      final matchesTitle = e.title.toLowerCase().contains(searchQuery);
      final matchesSubtitle = e.subtitle?.toLowerCase().contains(searchQuery) ?? false;
      final matchesPatient = e.patientName?.toLowerCase().contains(searchQuery) ?? false;
      return matchesTitle || matchesSubtitle || matchesPatient;
    }).toList();
  }

  // Sort all entries descending by timestamp
  filteredEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // Group by Date (Midnight normalized)
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);
  final yesterdayMidnight = todayMidnight.subtract(const Duration(days: 1));

  final Map<DateTime, List<PracticeJournalEntry>> groupedMap = {};

  for (final entry in filteredEntries) {
    final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
    groupedMap.putIfAbsent(entryDate, () => []).add(entry);
  }

  final sortedDates = groupedMap.keys.toList()..sort((a, b) => b.compareTo(a));

  final dayGroups = <JournalDayGroup>[];

  for (final date in sortedDates) {
    final entries = groupedMap[date]!;
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    String dayLabel;
    if (date.year == todayMidnight.year &&
        date.month == todayMidnight.month &&
        date.day == todayMidnight.day) {
      dayLabel = 'Today';
    } else if (date.year == yesterdayMidnight.year &&
        date.month == yesterdayMidnight.month &&
        date.day == yesterdayMidnight.day) {
      dayLabel = 'Yesterday';
    } else if (date.year == now.year) {
      dayLabel = DateFormat('EEE, d MMM').format(date);
    } else {
      dayLabel = DateFormat('d MMM yyyy').format(date);
    }

    double dayRevenue = 0.0;
    double dayExpense = 0.0;
    int dayPatients = 0;

    for (final e in entries) {
      if (e.type == JournalEventType.dispense && e.amount != null) {
        dayRevenue += e.amount!;
      } else if (e.type == JournalEventType.expense && e.amount != null) {
        dayExpense += e.amount!;
      } else if (e.type == JournalEventType.consultation) {
        dayPatients++;
      }
    }

    dayGroups.add(
      JournalDayGroup(
        date: date,
        dayLabel: dayLabel,
        totalRevenue: dayRevenue,
        totalPatients: dayPatients,
        totalExpense: dayExpense,
        entries: entries,
      ),
    );
  }

  return dayGroups;
});
